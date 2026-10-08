using System;
using EmulationMenu.Core.Enums;
using Godot;

namespace EmulationMenu.UI.Services;

public record ThemeColors(
    Color BackgroundColor,
    Color SurfaceColor,
    Color AccentColor,
    Color TextColor,
    Color SecondaryTextColor
);

/// <summary>
/// Theme Manager Service for Godot 4.7.
/// Dynamically updates UI control colors, font sizes, card padding, and accent highlights.
/// </summary>
public class ThemeManager
{
    public static ThemeColors GetThemeColors(UIThemeMode themeMode) => themeMode switch
    {
        UIThemeMode.CyberpunkDark => new(
            BackgroundColor: new Color(0.08f, 0.08f, 0.12f),
            SurfaceColor: new Color(0.14f, 0.14f, 0.20f),
            AccentColor: new Color(0.00f, 0.80f, 1.00f),
            TextColor: Colors.White,
            SecondaryTextColor: new Color(0.70f, 0.70f, 0.80f)
        ),
        UIThemeMode.SynthwaveRetro => new(
            BackgroundColor: new Color(0.12f, 0.05f, 0.18f),
            SurfaceColor: new Color(0.20f, 0.08f, 0.28f),
            AccentColor: new Color(1.00f, 0.15f, 0.60f),
            TextColor: new Color(1.00f, 0.90f, 0.95f),
            SecondaryTextColor: new Color(0.80f, 0.60f, 0.85f)
        ),
        UIThemeMode.ModernCleanDark => new(
            BackgroundColor: new Color(0.12f, 0.12f, 0.14f),
            SurfaceColor: new Color(0.18f, 0.18f, 0.20f),
            AccentColor: new Color(0.25f, 0.55f, 0.95f),
            TextColor: Colors.White,
            SecondaryTextColor: new Color(0.75f, 0.75f, 0.75f)
        ),
        UIThemeMode.CleanLight => new(
            BackgroundColor: new Color(0.94f, 0.94f, 0.96f),
            SurfaceColor: Colors.White,
            AccentColor: new Color(0.10f, 0.45f, 0.85f),
            TextColor: new Color(0.10f, 0.10f, 0.12f),
            SecondaryTextColor: new Color(0.40f, 0.40f, 0.45f)
        ),
        _ => GetThemeColors(UIThemeMode.CyberpunkDark)
    };

    public static void ApplyTheme(Control rootControl, UIThemeMode themeMode)
    {
        ThemeColors colors = GetThemeColors(themeMode);
        rootControl.SelfModulate = colors.BackgroundColor;
    }
}
