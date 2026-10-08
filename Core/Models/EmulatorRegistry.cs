using System.Collections.Generic;
using EmulationMenu.Core.Enums;

namespace EmulationMenu.Core.Models;

/// <summary>
/// Pre-configured definitions for Standalone and Libretro Core download sources across supported platforms.
/// </summary>
public static class EmulatorRegistry
{
    private static readonly Dictionary<PlatformType, EmulatorDefinition> Definitions = new()
    {
        [PlatformType.GameCube] = new(
            Id: "dolphin",
            DisplayName: "Dolphin Emulator (GameCube / Wii)",
            TargetPlatform: PlatformType.GameCube,
            PreferredMode: ExecutionMode.Standalone,
            StandaloneDownloadUrl: "https://dl.dolphin-emu.org/builds/dolphin-master-latest-x64.7z",
            StandaloneExePath: "Dolphin.exe",
            LibretroCoreName: "dolphin_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/dolphin_libretro.dll.zip",
            DefaultLaunchArgs: "-b -e \"{0}\""
        ),
        [PlatformType.PlayStation2] = new(
            Id: "pcsx2",
            DisplayName: "PCSX2 Emulator (PlayStation 2)",
            TargetPlatform: PlatformType.PlayStation2,
            PreferredMode: ExecutionMode.Standalone,
            StandaloneDownloadUrl: "https://github.com/PCSX2/pcsx2/releases/download/v2.2.0/pcsx2-v2.2.0-windows-x64-Qt.7z",
            StandaloneExePath: "pcsx2-qt.exe",
            LibretroCoreName: "pcsx2_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/pcsx2_libretro.dll.zip",
            DefaultLaunchArgs: "-fullscreen -batch \"{0}\""
        ),
        [PlatformType.SNES] = new(
            Id: "snes9x",
            DisplayName: "Snes9x (Super Nintendo)",
            TargetPlatform: PlatformType.SNES,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: "https://github.com/snes9xgit/snes9x/releases/download/1.63/snes9x-1.63-win32-x64.zip",
            StandaloneExePath: "snes9x-x64.exe",
            LibretroCoreName: "snes9x_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        ),
        [PlatformType.NES] = new(
            Id: "mesen",
            DisplayName: "Mesen (NES / Famicom)",
            TargetPlatform: PlatformType.NES,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: "https://github.com/SourMesen/Mesen/releases/download/0.9.9/Mesen.v0.9.9.zip",
            StandaloneExePath: "Mesen.exe",
            LibretroCoreName: "mesen_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/mesen_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        ),
        [PlatformType.Genesis] = new(
            Id: "genesis_plus_gx",
            DisplayName: "Genesis Plus GX (Sega Genesis / CD / Master System)",
            TargetPlatform: PlatformType.Genesis,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: null,
            StandaloneExePath: null,
            LibretroCoreName: "genesis_plus_gx_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/genesis_plus_gx_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        ),
        [PlatformType.GameBoyAdvance] = new(
            Id: "mgba",
            DisplayName: "mGBA (Game Boy Advance)",
            TargetPlatform: PlatformType.GameBoyAdvance,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: "https://github.com/mgba-emu/mgba/releases/download/0.10.3/mGBA-0.10.3-win64.7z",
            StandaloneExePath: "mGBA.exe",
            LibretroCoreName: "mgba_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/mgba_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        ),
        [PlatformType.PlayStation1] = new(
            Id: "pcsx_rearmed",
            DisplayName: "PCSX ReARMed / DuckStation (PSX)",
            TargetPlatform: PlatformType.PlayStation1,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: "https://github.com/stenzek/duckstation/releases/download/v0.1-7000/duckstation-windows-x64-release.zip",
            StandaloneExePath: "duckstation-qt-x64-Release.exe",
            LibretroCoreName: "pcsx_rearmed_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/pcsx_rearmed_libretro.dll.zip",
            DefaultLaunchArgs: "-fullscreen \"{0}\""
        ),
        [PlatformType.Nintendo64] = new(
            Id: "mupen64plus",
            DisplayName: "Mupen64Plus-Next (Nintendo 64)",
            TargetPlatform: PlatformType.Nintendo64,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: null,
            StandaloneExePath: null,
            LibretroCoreName: "mupen64plus_next_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/mupen64plus_next_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        ),
        [PlatformType.PlayStationPortable] = new(
            Id: "ppsspp",
            DisplayName: "PPSSPP (PlayStation Portable)",
            TargetPlatform: PlatformType.PlayStationPortable,
            PreferredMode: ExecutionMode.Standalone,
            StandaloneDownloadUrl: "https://www.ppsspp.org/files/1_17_1/ppsspp_win.zip",
            StandaloneExePath: "PPSSPPWindows64.exe",
            LibretroCoreName: "ppsspp_libretro",
            LibretroDownloadUrl: "https://buildbot.libretro.com/nightly/windows/x86_64/latest/ppsspp_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        )
    };

    public static EmulatorDefinition GetDefinitionOrDefault(PlatformType platform)
    {
        if (Definitions.TryGetValue(platform, out var def)) return def;

        // Fallback default definition for any platform
        return new EmulatorDefinition(
            Id: platform.ToString().ToLowerInvariant(),
            DisplayName: $"{platform} Emulator",
            TargetPlatform: platform,
            PreferredMode: ExecutionMode.LibretroCore,
            StandaloneDownloadUrl: null,
            StandaloneExePath: null,
            LibretroCoreName: $"{platform.ToString().ToLowerInvariant()}_libretro",
            LibretroDownloadUrl: $"https://buildbot.libretro.com/nightly/windows/x86_64/latest/{platform.ToString().ToLowerInvariant()}_libretro.dll.zip",
            DefaultLaunchArgs: "\"{0}\""
        );
    }
}
