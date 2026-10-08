namespace EmulationMenu.Core.Enums;

/// <summary>
/// Specifies whether a platform game is launched via a standalone Windows binary
/// or embedded inside RetroArch using a Libretro core DLL.
/// </summary>
public enum ExecutionMode
{
    Standalone = 0,
    LibretroCore = 1
}

/// <summary>
/// Comprehensive list of supported gaming systems, retro consoles, classic computers, and arcade hardware.
/// </summary>
public enum PlatformType
{
    // Modern & Standalone Systems
    GameCube,
    PlayStation2,
    PlayStation3,
    NintendoSwitch,

    // Libretro & Classic Console Systems
    SNES,
    NES,
    Genesis,
    GameBoyAdvance,
    Arcade,
    PlayStation1,
    Nintendo64,
    GameBoy,
    GameBoyColor,
    NintendoDS,
    Nintendo3DS,
    PlayStationPortable,
    SegaSaturn,
    SegaDreamcast,
    Atari2600,
    NeoGeo,
    PCEngine,
    MasterSystem,
    GameGear,

    // Classic Home Computers & Vintage Systems
    Commodore64,
    CommodoreAmiga,
    AtariST,
    Atari5200,
    Atari7800,
    MSX,
    ZXSpectrum,
    AppleII,
    ColecoVision,
    Intellivision,
    VirtualBoy,
    WonderSwan,
    SegaCD,
    Sega32X
}
