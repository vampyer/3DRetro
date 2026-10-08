using System;
using System.Collections.Generic;
using EmulationMenu.Core.Enums;

namespace EmulationMenu.Core.Models;

/// <summary>
/// Definition for an emulator system (Standalone or Libretro Core fallback).
/// </summary>
public record EmulatorDefinition(
    string Id,
    string DisplayName,
    PlatformType TargetPlatform,
    ExecutionMode PreferredMode,
    string? StandaloneDownloadUrl,
    string? StandaloneExePath,
    string? LibretroCoreName,
    string? LibretroDownloadUrl,
    string DefaultLaunchArgs
);

/// <summary>
/// Progress reporting model for downloading and decompressing assets.
/// </summary>
public record DownloadProgressReport(
    string StatusMessage,
    double ProgressPercentage,
    long BytesDownloaded,
    long TotalBytes,
    bool IsDecompressing
);

/// <summary>
/// Entity representing a scanned game ROM on disk with rich scraped metadata, playtime statistics, and favorites status.
/// </summary>
public class GameRom
{
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public required string Title { get; set; }
    public required string FilePath { get; set; }
    public required PlatformType Platform { get; set; }
    public long FileSizeBytes { get; set; }

    // Rich Scraped Metadata
    public string? Description { get; set; }
    public string? Developer { get; set; }
    public string? Publisher { get; set; }
    public int? ReleaseYear { get; set; }
    public string? Genre { get; set; }
    public double? CommunityRating { get; set; }

    // Media Paths
    public string? CoverArtPath { get; set; }
    public string? LogoArtPath { get; set; }
    public string? VideoPreviewPath { get; set; }
    public string? BezelPath { get; set; }

    // User State & Play Analytics
    public bool IsFavorite { get; set; }
    public int PlayCount { get; set; }
    public DateTime LastPlayed { get; set; }
    public TimeSpan TotalPlayTime { get; set; }
    public ExecutionMode ActiveExecutionMode { get; set; }

    // RetroBat Advanced Features
    public int MaxPlayers { get; set; } = 1;
    public List<string> CustomCollections { get; set; } = new();
    public string? CustomEmulatorOverride { get; set; }
    public string? CustomShaderOverride { get; set; }
}

/// <summary>
/// RetroBat per-system override configuration (Aspect ratio, Bezels, Shaders, Default Emulator Engine).
/// </summary>
public class SystemConfigOverride
{
    public PlatformType TargetPlatform { get; set; }
    public ExecutionMode PreferredMode { get; set; } = ExecutionMode.Standalone;
    public string AspectRatio { get; set; } = "4:3"; // "4:3", "16:9", "Integer", "Auto"
    public string BezelStyle { get; set; } = "ConsoleThemed"; // "ConsoleThemed", "ArcadeCabinet", "RetroTV", "CleanGlass", "Disabled"
    public string ShaderPreset { get; set; } = "CRT-Scanlines"; // "CRT-Scanlines", "Subtle-Glow", "Cyberpunk", "None"
    public bool AutoControllerConfig { get; set; } = true;
    public string AdditionalLaunchArgs { get; set; } = "";
}

