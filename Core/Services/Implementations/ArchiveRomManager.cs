using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;
using SharpCompress.Archives;
using SharpCompress.Common;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Service managing ROM archive inspection, CRC32/MD5 hashing, and safe extraction cache.
/// Automatically handles compressed (.zip, .7z, .rar) ROM packages prior to execution.
/// </summary>
public class ArchiveRomManager
{
    private readonly string _extractionCacheDir;

    public ArchiveRomManager(string? cacheDir = null)
    {
        _extractionCacheDir = cacheDir ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Cache", "ExtractedROMs");
        Directory.CreateDirectory(_extractionCacheDir);
    }

    /// <summary>
    /// Checks if a ROM file is an archive (.7z, .rar, .zip).
    /// If so, extracts its primary executable game image to a managed cache folder and returns its path.
    /// Otherwise, returns the original path.
    /// </summary>
    public async Task<string> PrepareRomForLaunchAsync(string originalRomPath, CancellationToken cancellationToken = default)
    {
        string extension = Path.GetExtension(originalRomPath).ToLowerInvariant();
        if (extension is not (".zip" or ".7z" or ".rar" or ".tar" or ".gz"))
        {
            return originalRomPath; // Native uncompressed file
        }

        string fileHash = await CalculateFileMd5Async(originalRomPath, cancellationToken);
        string targetExtractedDir = Path.Combine(_extractionCacheDir, fileHash);

        if (Directory.Exists(targetExtractedDir))
        {
            string? cachedImage = FindPrimaryGameImage(targetExtractedDir);
            if (cachedImage != null) return cachedImage;
        }

        Directory.CreateDirectory(targetExtractedDir);

        await Task.Run(() =>
        {
            if (extension == ".zip")
            {
                ZipFile.ExtractToDirectory(originalRomPath, targetExtractedDir, overwriteFiles: true);
            }
            else
            {
                using var archive = ArchiveFactory.Open(originalRomPath);
                foreach (var entry in archive.Entries)
                {
                    if (!entry.IsDirectory)
                    {
                        entry.WriteToDirectory(targetExtractedDir, new ExtractionOptions
                        {
                            ExtractFullPath = true,
                            Overwrite = true
                        });
                    }
                }
            }
        }, cancellationToken);

        string extractedGameFile = FindPrimaryGameImage(targetExtractedDir) 
            ?? throw new FileNotFoundException($"No valid playable ROM image found inside archive: {originalRomPath}");

        return extractedGameFile;
    }

    private static string? FindPrimaryGameImage(string directory)
    {
        string[] validExtensions = [".iso", ".gcz", ".cue", ".bin", ".sfc", ".smc", ".gba", ".nes", ".chd", ".nss"];

        var files = Directory.GetFiles(directory, "*.*", SearchOption.AllDirectories);
        return files.FirstOrDefault(f => validExtensions.Contains(Path.GetExtension(f).ToLowerInvariant()))
               ?? files.FirstOrDefault();
    }

    public static async Task<string> CalculateFileMd5Async(string filePath, CancellationToken cancellationToken)
    {
        using var md5 = MD5.Create();
        await using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read, 81920, true);
        byte[] hashBytes = await md5.ComputeHashAsync(stream, cancellationToken);
        return Convert.ToHexString(hashBytes).ToLowerInvariant();
    }
}
