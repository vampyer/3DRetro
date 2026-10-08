using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using EmulationMenu.Core.Enums;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Information record mapping a system platform to its default folder name, RetroArch core, and supported ROM extensions.
/// </summary>
public record PlatformFolderInfo(
    PlatformType Platform,
    string FolderName,
    string SystemDisplayName,
    string? DefaultLibretroCore,
    IReadOnlyList<string> SupportedExtensions,
    string Description
);

/// <summary>
/// Service responsible for automatically creating and organizing supported ROM platform directories.
/// Covers Standalone desktop systems, RetroArch cores, and Classic 8/16-bit vintage computers and consoles.
/// </summary>
public class RomDirectoryManager
{
    private static readonly Dictionary<PlatformType, PlatformFolderInfo> PlatformFolderRegistry = new()
    {
        // Modern / Standalone Preferred Systems
        [PlatformType.GameCube] = new(
            PlatformType.GameCube,
            "GameCube",
            "Nintendo GameCube",
            "dolphin_libretro",
            [".iso", ".gcz", ".rvz", ".nkit.iso", ".zip", ".7z"],
            "Place Nintendo GameCube ROMs/ISOs here (Dolphin)."
        ),
        [PlatformType.PlayStation2] = new(
            PlatformType.PlayStation2,
            "PlayStation2",
            "Sony PlayStation 2",
            "pcsx2_libretro",
            [".iso", ".chd", ".bin", ".cue", ".gz", ".zip", ".7z"],
            "Place PS2 ISOs or CHD images here (PCSX2)."
        ),
        [PlatformType.PlayStation3] = new(
            PlatformType.PlayStation3,
            "PlayStation3",
            "Sony PlayStation 3",
            null,
            [".iso", ".pkg", ".zip", ".7z"],
            "Place PS3 ISOs or PKG dumps here (RPCS3)."
        ),
        [PlatformType.NintendoSwitch] = new(
            PlatformType.NintendoSwitch,
            "Switch",
            "Nintendo Switch",
            null,
            [".nsp", ".xci", ".zip", ".7z"],
            "Place Switch NSP or XCI dumps here."
        ),

        // Core Consoles
        [PlatformType.SNES] = new(
            PlatformType.SNES,
            "SNES",
            "Super Nintendo Entertainment System",
            "snes9x_libretro",
            [".sfc", ".smc", ".fig", ".zip", ".7z"],
            "Place Super Nintendo ROMs here (Core: Snes9x)."
        ),
        [PlatformType.NES] = new(
            PlatformType.NES,
            "NES",
            "Nintendo Entertainment System",
            "mesen_libretro",
            [".nes", ".unf", ".zip", ".7z"],
            "Place NES ROMs here (Core: Mesen / FCEUmm)."
        ),
        [PlatformType.Genesis] = new(
            PlatformType.Genesis,
            "Genesis",
            "Sega Genesis / Mega Drive",
            "genesis_plus_gx_libretro",
            [".md", ".smd", ".gen", ".zip", ".7z"],
            "Place Sega Genesis ROMs here (Core: Genesis Plus GX)."
        ),
        [PlatformType.GameBoyAdvance] = new(
            PlatformType.GameBoyAdvance,
            "GBA",
            "Game Boy Advance",
            "mgba_libretro",
            [".gba", ".zip", ".7z"],
            "Place Game Boy Advance ROMs here (Core: mGBA)."
        ),
        [PlatformType.Arcade] = new(
            PlatformType.Arcade,
            "Arcade",
            "Arcade (MAME / FBNeo)",
            "fbneo_libretro",
            [".zip", ".7z", ".chd"],
            "Place Arcade MAME or FBNeo ROM sets here (Core: FinalBurn Neo / MAME)."
        ),
        [PlatformType.PlayStation1] = new(
            PlatformType.PlayStation1,
            "PlayStation1",
            "Sony PlayStation 1 (PSX)",
            "pcsx_rearmed_libretro",
            [".cue", ".bin", ".chd", ".iso", ".pbp", ".zip", ".7z"],
            "Place PS1 ISO/BIN/CUE/CHD images here (Core: PCSX ReARMed)."
        ),
        [PlatformType.Nintendo64] = new(
            PlatformType.Nintendo64,
            "N64",
            "Nintendo 64",
            "mupen64plus_next_libretro",
            [".n64", ".z64", ".v64", ".zip", ".7z"],
            "Place N64 ROMs here (Core: Mupen64Plus-Next)."
        ),
        [PlatformType.GameBoy] = new(
            PlatformType.GameBoy,
            "GameBoy",
            "Nintendo Game Boy",
            "gambatte_libretro",
            [".gb", ".zip", ".7z"],
            "Place Game Boy ROMs here (Core: Gambatte)."
        ),
        [PlatformType.GameBoyColor] = new(
            PlatformType.GameBoyColor,
            "GameBoyColor",
            "Nintendo Game Boy Color",
            "gambatte_libretro",
            [".gbc", ".zip", ".7z"],
            "Place Game Boy Color ROMs here (Core: Gambatte)."
        ),
        [PlatformType.NintendoDS] = new(
            PlatformType.NintendoDS,
            "NDS",
            "Nintendo DS",
            "melonds_libretro",
            [".nds", ".zip", ".7z"],
            "Place Nintendo DS ROMs here (Core: melonDS)."
        ),
        [PlatformType.Nintendo3DS] = new(
            PlatformType.Nintendo3DS,
            "3DS",
            "Nintendo 3DS",
            "citra_libretro",
            [".3ds", ".cia", ".zip", ".7z"],
            "Place 3DS ROMs here (Core: Citra)."
        ),
        [PlatformType.PlayStationPortable] = new(
            PlatformType.PlayStationPortable,
            "PSP",
            "Sony PlayStation Portable",
            "ppsspp_libretro",
            [".iso", ".cso", ".pbp", ".zip", ".7z"],
            "Place PSP ISO/CSO images here (Core: PPSSPP)."
        ),
        [PlatformType.SegaSaturn] = new(
            PlatformType.SegaSaturn,
            "Saturn",
            "Sega Saturn",
            "beetle_saturn_libretro",
            [".cue", ".bin", ".chd", ".iso", ".zip", ".7z"],
            "Place Sega Saturn BIN/CUE/CHD images here (Core: Beetle Saturn)."
        ),
        [PlatformType.SegaDreamcast] = new(
            PlatformType.SegaDreamcast,
            "Dreamcast",
            "Sega Dreamcast",
            "flycast_libretro",
            [".cdi", ".gdi", ".chd", ".zip", ".7z"],
            "Place Dreamcast CDI/GDI/CHD images here (Core: Flycast)."
        ),
        [PlatformType.Atari2600] = new(
            PlatformType.Atari2600,
            "Atari2600",
            "Atari 2600",
            "stella_libretro",
            [".a26", ".bin", ".zip", ".7z"],
            "Place Atari 2600 ROMs here (Core: Stella)."
        ),
        [PlatformType.NeoGeo] = new(
            PlatformType.NeoGeo,
            "NeoGeo",
            "SNK Neo Geo",
            "fbneo_libretro",
            [".zip", ".7z", ".neo"],
            "Place Neo Geo ROM sets here (Core: FinalBurn Neo)."
        ),
        [PlatformType.PCEngine] = new(
            PlatformType.PCEngine,
            "PCEngine",
            "PC Engine / TurboGrafx-16",
            "beetle_pce_fast_libretro",
            [".pce", ".cue", ".ccd", ".chd", ".zip", ".7z"],
            "Place PC Engine ROMs here (Core: Beetle PCE Fast)."
        ),
        [PlatformType.MasterSystem] = new(
            PlatformType.MasterSystem,
            "MasterSystem",
            "Sega Master System",
            "genesis_plus_gx_libretro",
            [".sms", ".zip", ".7z"],
            "Place Sega Master System ROMs here (Core: Genesis Plus GX)."
        ),
        [PlatformType.GameGear] = new(
            PlatformType.GameGear,
            "GameGear",
            "Sega Game Gear",
            "genesis_plus_gx_libretro",
            [".gg", ".zip", ".7z"],
            "Place Sega Game Gear ROMs here (Core: Genesis Plus GX)."
        ),

        // Classic Computers & Vintage Consoles
        [PlatformType.Commodore64] = new(
            PlatformType.Commodore64,
            "Commodore64",
            "Commodore 64 (C64)",
            "vice_x64sc_libretro",
            [".d64", ".t64", ".crt", ".prg", ".tap", ".zip", ".7z"],
            "Place Commodore 64 disk images (.d64) and cartridges (.crt) here (Core: VICE)."
        ),
        [PlatformType.CommodoreAmiga] = new(
            PlatformType.CommodoreAmiga,
            "Amiga",
            "Commodore Amiga (500/1200)",
            "puaae_libretro",
            [".adf", ".hdf", ".lha", ".ipf", ".zip", ".7z"],
            "Place Amiga disk images (.adf) and WHDLoad archives (.lha) here (Core: PUAE)."
        ),
        [PlatformType.AtariST] = new(
            PlatformType.AtariST,
            "AtariST",
            "Atari ST / STE",
            "hatari_libretro",
            [".st", ".stx", ".msa", ".zip", ".7z"],
            "Place Atari ST floppy disk images (.st / .msa) here (Core: Hatari)."
        ),
        [PlatformType.Atari5200] = new(
            PlatformType.Atari5200,
            "Atari5200",
            "Atari 5200",
            "atari800_libretro",
            [".a52", ".bin", ".zip", ".7z"],
            "Place Atari 5200 ROMs here (Core: Atari800)."
        ),
        [PlatformType.Atari7800] = new(
            PlatformType.Atari7800,
            "Atari7800",
            "Atari 7800",
            "prosystem_libretro",
            [".a78", ".bin", ".zip", ".7z"],
            "Place Atari 7800 ROMs here (Core: ProSystem)."
        ),
        [PlatformType.MSX] = new(
            PlatformType.MSX,
            "MSX",
            "MSX / MSX2 Computer",
            "bluemsx_libretro",
            [".rom", ".mx1", ".mx2", ".dsk", ".zip", ".7z"],
            "Place MSX / MSX2 ROM cartridges (.rom) or disks (.dsk) here (Core: blueMSX)."
        ),
        [PlatformType.ZXSpectrum] = new(
            PlatformType.ZXSpectrum,
            "ZXSpectrum",
            "Sinclair ZX Spectrum",
            "fuse_libretro",
            [".tzx", ".tap", ".z80", ".sna", ".zip", ".7z"],
            "Place ZX Spectrum tape files (.tap/.tzx) or snapshots (.z80) here (Core: Fuse)."
        ),
        [PlatformType.AppleII] = new(
            PlatformType.AppleII,
            "AppleII",
            "Apple II Computer",
            "applewin_libretro",
            [".dsk", ".do", ".po", ".nib", ".zip", ".7z"],
            "Place Apple II disk images (.dsk / .po) here (Core: AppleWin)."
        ),
        [PlatformType.ColecoVision] = new(
            PlatformType.ColecoVision,
            "ColecoVision",
            "ColecoVision",
            "gearcoleco_libretro",
            [".col", ".bin", ".rom", ".zip", ".7z"],
            "Place ColecoVision ROMs here (Core: Gearcoleco)."
        ),
        [PlatformType.Intellivision] = new(
            PlatformType.Intellivision,
            "Intellivision",
            "Mattel Intellivision",
            "freeintv_libretro",
            [".int", ".bin", ".rom", ".zip", ".7z"],
            "Place Intellivision (.int / .bin) ROMs here (Core: FreeIntv)."
        ),
        [PlatformType.VirtualBoy] = new(
            PlatformType.VirtualBoy,
            "VirtualBoy",
            "Nintendo Virtual Boy",
            "mednafen_vb_libretro",
            [".vb", ".vboy", ".zip", ".7z"],
            "Place Virtual Boy (.vb) ROMs here (Core: Beetle VB)."
        ),
        [PlatformType.WonderSwan] = new(
            PlatformType.WonderSwan,
            "WonderSwan",
            "Bandai WonderSwan / Color",
            "mednafen_wswan_libretro",
            [".ws", ".wsc", ".zip", ".7z"],
            "Place WonderSwan (.ws / .wsc) ROMs here (Core: Beetle Cygne)."
        ),
        [PlatformType.SegaCD] = new(
            PlatformType.SegaCD,
            "SegaCD",
            "Sega CD / Mega CD",
            "genesis_plus_gx_libretro",
            [".cue", ".bin", ".chd", ".iso", ".zip", ".7z"],
            "Place Sega CD ISO/CHD images here (Core: Genesis Plus GX)."
        ),
        [PlatformType.Sega32X] = new(
            PlatformType.Sega32X,
            "Sega32X",
            "Sega 32X",
            "picodrive_libretro",
            [".32x", ".bin", ".zip", ".7z"],
            "Place Sega 32X (.32x) ROMs here (Core: PicoDrive)."
        )
    };

    private readonly string _baseRomDirectory;

    public RomDirectoryManager(string? baseRomDirectory = null)
    {
        _baseRomDirectory = baseRomDirectory ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ROMS");
    }

    /// <summary>
    /// Scans all registered platform definitions (Standalone, Modern, RetroArch, and Classic Vintage Systems) 
    /// and automatically creates the corresponding directory structure along with an informational README.txt file.
    /// </summary>
    public IReadOnlyList<string> EnsureSupportedDirectoriesExist()
    {
        Directory.CreateDirectory(_baseRomDirectory);
        List<string> createdDirectories = [];

        foreach (var (platform, info) in PlatformFolderRegistry)
        {
            string platformDirPath = Path.Combine(_baseRomDirectory, info.FolderName);
            Directory.CreateDirectory(platformDirPath);
            createdDirectories.Add(platformDirPath);

            string readmePath = Path.Combine(platformDirPath, "README.txt");
            if (!File.Exists(readmePath))
            {
                var sb = new StringBuilder();
                sb.AppendLine($"=========================================");
                sb.AppendLine($"  {info.SystemDisplayName} ROM Directory");
                sb.AppendLine($"=========================================");
                sb.AppendLine();
                sb.AppendLine(info.Description);
                if (!string.IsNullOrEmpty(info.DefaultLibretroCore))
                {
                    sb.AppendLine($"Default Libretro Core: {info.DefaultLibretroCore}.dll");
                }
                sb.AppendLine();
                sb.AppendLine("Supported File Extensions:");
                foreach (string ext in info.SupportedExtensions)
                {
                    sb.AppendLine($"  - {ext}");
                }
                sb.AppendLine();
                sb.AppendLine("Front-end Auto-Scanning:");
                sb.AppendLine("Any ROM placed in this folder will be automatically detected");
                sb.AppendLine("and added to your library grid on launch.");

                File.WriteAllText(readmePath, sb.ToString());
            }
        }

        return createdDirectories;
    }

    public static PlatformFolderInfo? GetFolderInfo(PlatformType platform)
    {
        return PlatformFolderRegistry.TryGetValue(platform, out var info) ? info : null;
    }

    public static IEnumerable<PlatformFolderInfo> GetAllSupportedPlatforms()
    {
        return PlatformFolderRegistry.Values;
    }
}
