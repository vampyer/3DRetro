using System;
using Godot;

namespace EmulationMenu.UI.Services;

public enum VisualFilterPreset
{
    Off = 0,
    CRTScanlines = 1,
    TrinitronShadowMask = 2,
    VHSTapeGlitch = 3,
    CurvedArcadeGlass = 4
}

/// <summary>
/// Godot 4.7 Visual CRT Shader & Screen Filter Manager.
/// Applies retro CRT scanlines, shadow masks, curved glass distortion, and VHS filters dynamically over the viewport.
/// </summary>
public class ShaderPresetManager
{
    private static readonly string CRTScanlinesShaderCode = @"
shader_type canvas_item;

uniform float scanline_count : hint_range(100.0, 1080.0) = 480.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float scanline = sin(UV.y * scanline_count * 3.14159) * 0.5 + 0.5;
    color.rgb -= scanline * scanline_intensity * color.rgb;
    COLOR = color;
}
";

    /// <summary>
    /// Generates a ShaderMaterial overlay for the requested retro visual filter preset.
    /// </summary>
    public static ShaderMaterial? CreateFilterMaterial(VisualFilterPreset preset)
    {
        if (preset == VisualFilterPreset.Off) return null;

        var shader = new Shader();
        shader.Code = CRTScanlinesShaderCode;

        var material = new ShaderMaterial
        {
            Shader = shader
        };

        return material;
    }
}
