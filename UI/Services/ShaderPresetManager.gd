class_name ShaderPresetManager
extends RefCounted

## Shader Preset Manager in GDScript for standard Godot 4.7.
## Generates and attaches CRT scanlines and visual shaders.

static func create_crt_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type canvas_item;

    uniform float scanline_count : hint_range(100.0, 1000.0) = 300.0;
    uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.25;

    void fragment() {
        vec4 color = texture(TEXTURE, UV);
        float scanline = sin(UV.y * scanline_count * 3.14159) * 0.5 + 0.5;
        color.rgb -= scanline * scanline_opacity * color.rgb;
        COLOR = color;
    }
    """
    return shader

static func apply_crt_material(node: Control) -> void:
    var mat = ShaderMaterial.new()
    mat.shader = create_crt_shader()
    node.material = mat
