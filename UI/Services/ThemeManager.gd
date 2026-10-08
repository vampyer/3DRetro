class_name ThemeManager
extends RefCounted

## Theme Manager Service for Godot 4.7 Standard GDScript.
## Dynamically updates UI control colors, font sizes, card padding, and accent highlights.

enum UIThemeMode {
    CYBERPUNK_DARK = 0,
    SYNTHWAVE_RETRO = 1,
    MODERN_CLEAN_DARK = 2,
    CLEAN_LIGHT = 3
}

static func get_theme_colors(mode: int) -> Dictionary:
    match mode:
        UIThemeMode.CYBERPUNK_DARK:
            return {
                "background": Color(0.08, 0.08, 0.12),
                "surface": Color(0.14, 0.14, 0.20),
                "accent": Color(0.0, 0.85, 0.95),
                "text": Color(0.95, 0.95, 1.0),
                "secondary": Color(0.6, 0.6, 0.75)
            }
        UIThemeMode.SYNTHWAVE_RETRO:
            return {
                "background": Color(0.12, 0.06, 0.16),
                "surface": Color(0.20, 0.10, 0.28),
                "accent": Color(0.98, 0.22, 0.76),
                "text": Color(1.0, 0.92, 0.96),
                "secondary": Color(0.8, 0.5, 0.7)
            }
        UIThemeMode.MODERN_CLEAN_DARK:
            return {
                "background": Color(0.1, 0.1, 0.12),
                "surface": Color(0.16, 0.16, 0.18),
                "accent": Color(0.3, 0.6, 1.0),
                "text": Color(0.92, 0.92, 0.95),
                "secondary": Color(0.6, 0.6, 0.65)
            }
        UIThemeMode.CLEAN_LIGHT:
            return {
                "background": Color(0.94, 0.94, 0.96),
                "surface": Color(1.0, 1.0, 1.0),
                "accent": Color(0.1, 0.45, 0.9),
                "text": Color(0.1, 0.1, 0.15),
                "secondary": Color(0.45, 0.45, 0.5)
            }
        _:
            return get_theme_colors(UIThemeMode.CYBERPUNK_DARK)

static func apply_theme(target: Control, mode: int) -> void:
    var colors = get_theme_colors(mode)
    target.self_modulate = colors["background"]
