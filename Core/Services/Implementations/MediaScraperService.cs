using System;
using System.IO;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Interfaces;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Media Scraper infrastructure template targeting APIs like ScreenScraper or IGDB.
/// Streams media downloads asynchronously and caches boxart/video previews locally.
/// </summary>
public class MediaScraperService : IMediaScraper
{
    private readonly HttpClient _httpClient;
    private readonly string _cacheDirectory;

    public MediaScraperService(HttpClient httpClient)
    {
        _httpClient = httpClient;
        _cacheDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Cache", "Media");
        Directory.CreateDirectory(_cacheDirectory);
    }

    public async Task<GameRom> ScrapeMetadataAndArtAsync(GameRom rom, CancellationToken cancellationToken = default)
    {
        string safeTitle = string.Concat(rom.Title.Split(Path.GetInvalidFileNameChars()));
        string targetArtPath = Path.Combine(_cacheDirectory, $"{rom.Platform}_{safeTitle}_cover.png");

        if (File.Exists(targetArtPath))
        {
            rom.CoverArtPath = targetArtPath;
            return rom;
        }

        try
        {
            // Placeholder URL structure - template for ScreenScraper / IGDB API endpoints
            string requestUrl = $"https://api.screenscraper.fr/api/jeuInfos.php?devid=demo&devpassword=demo&softname=EmulationMenu&output=json&nom={Uri.EscapeDataString(rom.Title)}";

            // In production: Query API JSON response, extract media URL
            // Here we show robust async stream caching pattern:
            string dummyCoverUrl = "https://raw.githubusercontent.com/godotengine/godot-design/master/logo/icon_color.png";
            
            using var response = await _httpClient.GetAsync(dummyCoverUrl, cancellationToken);
            if (response.IsSuccessStatusCode)
            {
                await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
                await using var fileStream = File.Create(targetArtPath);
                await stream.CopyToAsync(fileStream, cancellationToken);

                rom.CoverArtPath = targetArtPath;
            }
        }
        catch (Exception ex)
        {
            Godot.GD.PrintErr($"Failed to scrape media for {rom.Title}: {ex.Message}");
        }

        return rom;
    }
}
