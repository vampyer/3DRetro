using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;
using EmulationMenu.Core.Models;

namespace EmulationMenu.Core.Services.Interfaces;

public interface IEmulatorDownloader
{
    /// <summary>
    /// Evaluates business logic for platform emulator setup:
    /// Downloads standalone binary if available/preferred, or falls back to Libretro core DLL.
    /// Progress updates stream via progress reporter without blocking UI.
    /// </summary>
    Task<string> EnsureEmulatorInstalledAsync(
        EmulatorDefinition emulator,
        IProgress<DownloadProgressReport>? progress = null,
        CancellationToken cancellationToken = default);
}

public interface IEmulatorLauncher
{
    event EventHandler<TimeSpan>? GameExited;
    
    bool IsRunning { get; }
    
    /// <summary>
    /// Launches a game ROM using configured Standalone binary or Libretro core fallback on Windows.
    /// Safely controls window state, listens for exit codes, and calculates play session time.
    /// </summary>
    Task<bool> LaunchGameAsync(GameRom game, EmulatorDefinition emulatorConfig, string retroArchBasePath);

    /// <summary>
    /// Forces termination of active child emulator process if necessary.
    /// </summary>
    void ForceKillActiveProcess();
}

public interface IRomScanner
{
    /// <summary>
    /// Recursively scans directory paths asynchronously, streaming discovered ROM entries via System.Threading.Channels.
    /// </summary>
    ChannelReader<GameRom> ScanDirectoryAsync(
        IEnumerable<string> directoryPaths,
        IReadOnlyList<string> supportedExtensions,
        CancellationToken cancellationToken = default);
}

public interface IMediaScraper
{
    Task<GameRom> ScrapeMetadataAndArtAsync(GameRom rom, CancellationToken cancellationToken = default);
}
