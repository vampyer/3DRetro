namespace EmulationMenu.Core.Enums;

/// <summary>
/// Available UI Interface Layout Models for the frontend.
/// </summary>
public enum InterfaceModel
{
    /// <summary>
    /// Standard 3-column desktop layout (Sidebar Nav, Grid, Detail Panel).
    /// </summary>
    ClassicDesktop = 0,

    /// <summary>
    /// Fullscreen 10-foot Couch / TV / Gamepad interface with horizontal scrolling hero banners.
    /// </summary>
    CouchBigPicture = 1,

    /// <summary>
    /// High-density compact list view for ultra-fast searching across 10,000+ ROMs.
    /// </summary>
    MinimalistList = 2,

    /// <summary>
    /// Immersive 3D curved cover wall carousel with studio lighting.
    /// </summary>
    Arcade3DCarousel = 3
}

/// <summary>
/// Available UI Color Themes.
/// </summary>
public enum UIThemeMode
{
    CyberpunkDark = 0,
    SynthwaveRetro = 1,
    ModernCleanDark = 2,
    CleanLight = 3
}
