using System;
using System.IO;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Models;
using Godot;

using HttpClient = System.Net.Http.HttpClient;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// ScreenScraper API client for fetching high-resolution boxart, wheel logos,
/// synopsis metadata, and video previews for games.
/// </summary>
public class ScreenScraperClient
{
    private readonly HttpClient _httpClient;
    private readonly string _cacheBaseDir;
    private readonly string _devId;
    private readonly string _devPassword;

    public ScreenScraperClient(HttpClient httpClient, string devId = "demo", string devPassword = "demo")
    {
        _httpClient = httpClient;
        _devId = devId;
        _devPassword = devPassword;
        _cacheBaseDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Cache", "Media");
        Directory.CreateDirectory(_cacheBaseDir);
    }

    public async Task<ScrapedMediaResult> FetchMediaAsync(GameRom rom, CancellationToken cancellationToken = default)
    {
        string safeName = string.Concat(rom.Title.Split(Path.GetInvalidFileNameChars()));
        string coverPath = Path.Combine(_cacheBaseDir, $"{rom.Platform}_{safeName}_cover.png");
        string videoPath = Path.Combine(_cacheBaseDir, $"{rom.Platform}_{safeName}_preview.mp4");

        if (File.Exists(coverPath))
        {
            return new ScrapedMediaResult(coverPath, File.Exists(videoPath) ? videoPath : null);
        }

        try
        {
            // Build ScreenScraper request URL
            string systemId = MapPlatformToScreenScraperSystemId(rom.Platform);
            string url = $"https://api.screenscraper.fr/api/jeuInfos.php?devid={_devId}&devpassword={_devPassword}&softname=EmulationMenu&output=json&systemeid={systemId}&nom={Uri.EscapeDataString(rom.Title)}";

            using var response = await _httpClient.GetAsync(url, cancellationToken);
            if (response.IsSuccessStatusCode)
            {
                using var doc = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(cancellationToken), cancellationToken: cancellationToken);
                var root = doc.RootElement;

                if (root.TryGetProperty("response", out var resp) && resp.TryGetProperty("jeu", out var jeu))
                {
                    if (jeu.TryGetProperty("medias", out var medias) && medias.ValueKind == JsonValueKind.Array)
                    {
                        foreach (var media in medias.EnumerateArray())
                        {
                            string type = media.GetProperty("type").GetString() ?? "";
                            string mediaUrl = media.GetProperty("url").GetString() ?? "";

                            if (type == "box-2d" && !File.Exists(coverPath))
                            {
                                await DownloadFileStreamAsync(mediaUrl, coverPath, cancellationToken);
                            }
                            else if (type == "video" && !File.Exists(videoPath))
                            {
                                await DownloadFileStreamAsync(mediaUrl, videoPath, cancellationToken);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            GD.PrintErr($"ScreenScraper query failed for '{rom.Title}': {ex.Message}");
        }

        return new ScrapedMediaResult(
            File.Exists(coverPath) ? coverPath : null,
            File.Exists(videoPath) ? videoPath : null
        );
    }

    private async Task DownloadFileStreamAsync(string url, string targetPath, CancellationToken cancellationToken)
    {
        using var response = await _httpClient.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();

        await using var contentStream = await response.Content.ReadAsStreamAsync(cancellationToken);
        await using var fileStream = File.Create(targetPath);
        await contentStream.CopyToAsync(fileStream, cancellationToken);
    }

    private static string MapPlatformToScreenScraperSystemId(Enums.PlatformType platform) => platform switch
    {
        Enums.PlatformType.GameCube => "13",
        Enums.PlatformType.PlayStation2 => "19",
        Enums.PlatformType.PlayStation3 => "28",
        Enums.PlatformType.SNES => "4",
        Enums.PlatformType.NES => "3",
        Enums.PlatformType.GameBoyAdvance => "12",
        Enums.PlatformType.Genesis => "1",
        _ => "4"
    };
}

public record ScrapedMediaResult(string? CoverArtPath, string? VideoPreviewPath);
