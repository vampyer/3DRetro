using System;
using System.IO;
using System.IO.Compression;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Interfaces;
using SharpCompress.Archives;
using SharpCompress.Common;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Production-ready Emulator Downloader & Management Service.
/// Implements hybrid download prioritization (Standalone Windows binaries vs Libretro Cores)
/// with non-blocking stream downloads, progress tracking, and robust decompression.
/// </summary>
public class EmulatorDownloader : IEmulatorDownloader
{
    private readonly HttpClient _httpClient;
    private readonly string _baseAppDataPath;

    public EmulatorDownloader(HttpClient httpClient, string? baseAppDataPath = null)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _baseAppDataPath = baseAppDataPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Emulators");
        Directory.CreateDirectory(_baseAppDataPath);
    }

    public async Task<string> EnsureEmulatorInstalledAsync(
        EmulatorDefinition emulator,
        IProgress<DownloadProgressReport>? progress = null,
        CancellationToken cancellationToken = default)
    {
        string targetDir = Path.Combine(_baseAppDataPath, emulator.TargetPlatform.ToString());
        Directory.CreateDirectory(targetDir);

        // Business Logic Priority 1: Check Standalone Windows Executable
        if (emulator.PreferredMode == ExecutionMode.Standalone && !string.IsNullOrEmpty(emulator.StandaloneDownloadUrl))
        {
            string exePath = Path.Combine(targetDir, emulator.StandaloneExePath ?? $"{emulator.DisplayName}.exe");
            if (File.Exists(exePath))
            {
                progress?.Report(new DownloadProgressReport("Standalone emulator already installed.", 100.0, 0, 0, false));
                return exePath;
            }

            // Download Standalone Archive (.zip or .7z)
            string archivePath = Path.Combine(targetDir, "standalone_download.tmp");
            await DownloadFileWithProgressAsync(emulator.StandaloneDownloadUrl, archivePath, progress, cancellationToken);
            
            // Extract Archive
            progress?.Report(new DownloadProgressReport("Extracting Standalone Emulator...", 99.0, 0, 0, true));
            await ExtractArchiveAsync(archivePath, targetDir, cancellationToken);
            
            if (File.Exists(archivePath))
                File.Delete(archivePath);

            return exePath;
        }

        // Business Logic Priority 2: Fallback to Libretro Core (.dll) from Buildbot
        if (!string.IsNullOrEmpty(emulator.LibretroCoreName))
        {
            string coreDllPath = Path.Combine(targetDir, $"{emulator.LibretroCoreName}.dll");
            if (File.Exists(coreDllPath))
            {
                progress?.Report(new DownloadProgressReport("Libretro core already installed.", 100.0, 0, 0, false));
                return coreDllPath;
            }

            string downloadUrl = emulator.LibretroDownloadUrl 
                ?? $"https://buildbot.libretro.com/nightly/windows/x86_64/latest/{emulator.LibretroCoreName}.dll.zip";

            string archivePath = Path.Combine(targetDir, "core_download.zip");
            await DownloadFileWithProgressAsync(downloadUrl, archivePath, progress, cancellationToken);

            progress?.Report(new DownloadProgressReport("Extracting Libretro Core...", 99.0, 0, 0, true));
            await ExtractArchiveAsync(archivePath, targetDir, cancellationToken);

            if (File.Exists(archivePath))
                File.Delete(archivePath);

            return coreDllPath;
        }

        throw new InvalidOperationException($"No valid installation source found for emulator: {emulator.DisplayName}");
    }

    private async Task DownloadFileWithProgressAsync(
        string downloadUrl,
        string destinationFilePath,
        IProgress<DownloadProgressReport>? progress,
        CancellationToken cancellationToken)
    {
        using HttpResponseMessage response = await _httpClient.GetAsync(downloadUrl, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();

        long totalBytes = response.Content.Headers.ContentLength ?? -1L;
        using Stream contentStream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using FileStream fileStream = new(destinationFilePath, FileMode.Create, FileAccess.Write, FileShare.None, 81920, true);

        byte[] buffer = new byte[81920];
        long totalBytesRead = 0;
        int bytesRead;

        while ((bytesRead = await contentStream.ReadAsync(buffer, cancellationToken)) > 0)
        {
            await fileStream.WriteAsync(buffer.AsMemory(0, bytesRead), cancellationToken);
            totalBytesRead += bytesRead;

            if (totalBytes > 0 && progress != null)
            {
                double percentage = Math.Round((double)totalBytesRead / totalBytes * 100.0, 2);
                progress.Report(new DownloadProgressReport(
                    $"Downloading: {percentage:F1}% ({totalBytesRead / 1024 / 1024} MB / {totalBytes / 1024 / 1024} MB)",
                    percentage,
                    totalBytesRead,
                    totalBytes,
                    false));
            }
        }
    }

    private static Task ExtractArchiveAsync(string archivePath, string destinationDirectory, CancellationToken cancellationToken)
    {
        return Task.Run(() =>
        {
            string extension = Path.GetExtension(archivePath).ToLowerInvariant();
            if (extension == ".zip")
            {
                ZipFile.ExtractToDirectory(archivePath, destinationDirectory, overwriteFiles: true);
            }
            else
            {
                // SharpCompress fallback for .7z, .tar.gz, etc.
                using var archive = ArchiveFactory.Open(archivePath);
                foreach (var entry in archive.Entries)
                {
                    if (!entry.IsDirectory)
                    {
                        entry.WriteToDirectory(destinationDirectory, new ExtractionOptions
                        {
                            ExtractFullPath = true,
                            Overwrite = true
                        });
                    }
                }
            }
        }, cancellationToken);
    }
}
