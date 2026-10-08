using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Interfaces;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Pre-installation Bootstrapper Service.
/// Automatically provisions and pre-installs RetroArch backend binaries, default Libretro core DLLs,
/// and ROM directory trees during application startup.
/// </summary>
public class PreinstallBootstrapper
{
    private readonly RetroArchInstallerService _retroArchInstaller;
    private readonly IEmulatorDownloader _downloader;
    private readonly RomDirectoryManager _romDirectoryManager;

    private static readonly PlatformType[] DefaultPreinstallPlatforms =
    [
        PlatformType.SNES,
        PlatformType.NES,
        PlatformType.Genesis,
        PlatformType.GameBoyAdvance,
        PlatformType.PlayStation1,
        PlatformType.Nintendo64,
        PlatformType.Arcade
    ];

    public PreinstallBootstrapper(
        RetroArchInstallerService retroArchInstaller,
        IEmulatorDownloader downloader,
        RomDirectoryManager romDirectoryManager)
    {
        _retroArchInstaller = retroArchInstaller;
        _downloader = downloader;
        _romDirectoryManager = romDirectoryManager;
    }

    /// <summary>
    /// Executes full system pre-installation boot process on application launch:
    /// 1. Ensures all 33 ROM directories exist.
    /// 2. Pre-installs central RetroArch backend (retroarch.exe).
    /// 3. Pre-downloads popular default Libretro core DLLs.
    /// </summary>
    public async Task RunPreinstallBootSequenceAsync(
        IProgress<DownloadProgressReport>? progress = null,
        CancellationToken cancellationToken = default)
    {
        // Step 1: Pre-build ROM directories
        progress?.Report(new DownloadProgressReport("Pre-building ROM system directory tree...", 5.0, 0, 0, false));
        _romDirectoryManager.EnsureSupportedDirectoriesExist();

        // Step 2: Pre-install RetroArch Backend
        progress?.Report(new DownloadProgressReport("Pre-installing RetroArch backend runtime...", 15.0, 0, 0, false));
        await _retroArchInstaller.EnsureRetroArchInstalledAsync(progress, cancellationToken);

        // Step 3: Pre-install default core DLLs for major systems
        double stepPercentage = 80.0 / DefaultPreinstallPlatforms.Length;
        double currentProgress = 20.0;

        foreach (PlatformType platform in DefaultPreinstallPlatforms)
        {
            cancellationToken.ThrowIfCancellationRequested();

            EmulatorDefinition def = EmulatorRegistry.GetDefinitionOrDefault(platform);
            progress?.Report(new DownloadProgressReport($"Pre-installing default core for {platform}...", currentProgress, 0, 0, false));

            try
            {
                await _downloader.EnsureEmulatorInstalledAsync(def, progress, cancellationToken);
            }
            catch (Exception ex)
            {
                Godot.GD.PrintErr($"Pre-installation warning for {platform}: {ex.Message}");
            }

            currentProgress += stepPercentage;
        }

        progress?.Report(new DownloadProgressReport("System pre-installation complete. Engine ready.", 100.0, 0, 0, false));
    }
}
