using System;
using System.IO;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// RetroBat-style Bezel and Artwork Overlay Manager.
/// Automatically creates and configures 16:9 side borders and decorative frame overlays
/// for 4:3 retro platforms (SNES, NES, Genesis, PS1, N64, Arcade, GBA, etc.) when running in RetroArch or Standalone emulators.
/// </summary>
public class BezelDecorationManager
{
    private readonly string _bezelRootPath;

    public BezelDecorationManager(string baseDir)
    {
        _bezelRootPath = Path.Combine(baseDir, "App", "bezels");
        EnsureBezelDirectoryStructure();
    }

    private void EnsureBezelDirectoryStructure()
    {
        if (!Directory.Exists(_bezelRootPath))
        {
            Directory.CreateDirectory(_bezelRootPath);
        }

        foreach (PlatformType platform in Enum.GetValues<PlatformType>())
        {
            string platformDir = Path.Combine(_bezelRootPath, platform.ToString().ToLowerInvariant());
            if (!Directory.Exists(platformDir))
            {
                Directory.CreateDirectory(platformDir);
                GenerateDefaultBezelConfig(platformDir, platform);
            }
        }
    }

    private void GenerateDefaultBezelConfig(string platformDir, PlatformType platform)
    {
        string cfgPath = Path.Combine(platformDir, "bezel.cfg");
        if (File.Exists(cfgPath)) return;

        string cfgContent = $"""
            # System Overlay Bezel for {platform}

            overlays = 1
            overlay0_overlay = bezel.png
            overlay0_full_screen = true
            overlay0_descs = 0
            """;

        File.WriteAllText(cfgPath, cfgContent);
    }

    /// <summary>
    /// Evaluates game & system settings and returns the RetroArch launch argument overlay flags if bezels are enabled.
    /// </summary>
    public string GetRetroArchBezelLaunchArgs(PlatformType platform, SystemConfigOverride systemConfig, GameRom game)
    {
        string bezelStyle = game.BezelPath != null ? "Custom" : systemConfig.BezelStyle;
        if (bezelStyle.Equals("Disabled", StringComparison.OrdinalIgnoreCase))
        {
            return "";
        }

        string platformName = platform.ToString().ToLowerInvariant();
        string platformBezelDir = Path.Combine(_bezelRootPath, platformName);
        string cfgPath = Path.Combine(platformBezelDir, "bezel.cfg");

        if (File.Exists(cfgPath))
        {
            return $"--appendconfig \"{cfgPath}\"";
        }

        return "";
    }
}
