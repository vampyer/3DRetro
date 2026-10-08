using System;
using System.IO;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Models;
using SharpCompress.Archives;
using SharpCompress.Common;

using HttpClient = System.Net.Http.HttpClient;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Service responsible for automatically downloading, installing, and configuring
/// the central RetroArch frontend runtime (retroarch.exe) for Libretro core execution.
/// </summary>
public class RetroArchInstallerService
{
    private readonly HttpClient _httpClient;
    private readonly string _retroArchDirectory;

    public string RetroArchExecutablePath => Path.Combine(_retroArchDirectory, "retroarch.exe");

    public RetroArchInstallerService(HttpClient httpClient, string? customDirectory = null)
    {
        _httpClient = httpClient;
        _retroArchDirectory = customDirectory ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "RetroArch");
        Directory.CreateDirectory(_retroArchDirectory);
    }

    /// <summary>
    /// Verifies if retroarch.exe exists locally. If missing, streams the official 64-bit Windows 
    /// RetroArch build from Libretro Buildbot and extracts it automatically.
    /// </summary>
    public async Task<string> EnsureRetroArchInstalledAsync(
        IProgress<DownloadProgressReport>? progress = null,
        CancellationToken cancellationToken = default)
    {
        if (File.Exists(RetroArchExecutablePath))
        {
            progress?.Report(new DownloadProgressReport("RetroArch backend ready.", 100.0, 0, 0, false));
            return RetroArchExecutablePath;
        }

        string downloadUrl = "https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z";
        string tempArchivePath = Path.Combine(_retroArchDirectory, "RetroArch_download.7z");

        try
        {
            progress?.Report(new DownloadProgressReport("Downloading RetroArch Backend...", 0.0, 0, 0, false));

            using HttpResponseMessage response = await _httpClient.GetAsync(downloadUrl, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            response.EnsureSuccessStatusCode();

            long totalBytes = response.Content.Headers.ContentLength ?? -1L;
            await using Stream contentStream = await response.Content.ReadAsStreamAsync(cancellationToken);
            await using FileStream fileStream = new(tempArchivePath, FileMode.Create, FileAccess.Write, FileShare.None, 81920, true);

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
                        $"Downloading RetroArch: {percentage:F1}% ({totalBytesRead / 1024 / 1024} MB / {totalBytes / 1024 / 1024} MB)",
                        percentage,
                        totalBytesRead,
                        totalBytes,
                        false));
                }
            }

            fileStream.Close();

            // Extract RetroArch archive
            progress?.Report(new DownloadProgressReport("Extracting RetroArch Backend...", 99.0, 0, 0, true));
            await Task.Run(() =>
            {
                using var archive = ArchiveFactory.Open(tempArchivePath);
                foreach (var entry in archive.Entries)
                {
                    if (!entry.IsDirectory)
                    {
                        entry.WriteToDirectory(_retroArchDirectory, new ExtractionOptions
                        {
                            ExtractFullPath = true,
                            Overwrite = true
                        });
                    }
                }
            }, cancellationToken);

            if (File.Exists(tempArchivePath))
                File.Delete(tempArchivePath);

            progress?.Report(new DownloadProgressReport("RetroArch backend installed successfully.", 100.0, totalBytes, totalBytes, false));

            return RetroArchExecutablePath;
        }
        catch (Exception ex)
        {
            if (File.Exists(tempArchivePath)) File.Delete(tempArchivePath);
            throw new InvalidOperationException($"Failed to auto-install RetroArch backend: {ex.Message}", ex);
        }
    }
}
