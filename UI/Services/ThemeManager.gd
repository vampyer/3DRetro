class_name ThemeManager
extends RefCounted

## Theme & Skin Manager Service with High-Fidelity UI Styling & Procedural Wallpapers for Godot 4.7 Standard GDScript.

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
				"background": Color(0.05, 0.05, 0.09),
				"surface": Color(0.10, 0.11, 0.18, 0.92),
				"accent": Color(0.0, 0.90, 1.0), # Electric Cyan
				"text": Color(0.95, 0.96, 1.0),
				"secondary": Color(0.55, 0.60, 0.75)
			}
		UIThemeMode.SYNTHWAVE_RETRO:
			return {
				"background": Color(0.09, 0.02, 0.15),
				"surface": Color(0.18, 0.06, 0.28, 0.92),
				"accent": Color(1.0, 0.16, 0.75), # Neon Magenta
				"text": Color(1.0, 0.92, 0.97),
				"secondary": Color(0.85, 0.45, 0.75)
			}
		UIThemeMode.MODERN_CLEAN_DARK:
			return {
				"background": Color(0.06, 0.07, 0.10),
				"surface": Color(0.12, 0.14, 0.20, 0.92),
				"accent": Color(0.24, 0.55, 1.0), # Sapphire Blue
				"text": Color(0.92, 0.94, 0.98),
				"secondary": Color(0.55, 0.58, 0.68)
			}
		UIThemeMode.CLEAN_LIGHT:
			return {
				"background": Color(0.92, 0.94, 0.97),
				"surface": Color(1.0, 1.0, 1.0, 0.95),
				"accent": Color(0.08, 0.42, 0.92), # Cobalt Blue
				"text": Color(0.08, 0.10, 0.16),
				"secondary": Color(0.40, 0.45, 0.55)
			}
		_:
			return get_theme_colors(UIThemeMode.CYBERPUNK_DARK)

static func generate_skin_background_texture(mode: int) -> Texture2D:
	var grad = Gradient.new()
	var fill_type = GradientTexture2D.FILL_RADIAL

	match mode:
		UIThemeMode.CYBERPUNK_DARK:
			grad.colors = PackedColorArray([Color(0.12, 0.08, 0.24), Color(0.03, 0.03, 0.07)])
			grad.offsets = PackedFloat32Array([0.0, 1.0])
		UIThemeMode.SYNTHWAVE_RETRO:
			grad.colors = PackedColorArray([Color(0.48, 0.06, 0.38), Color(0.10, 0.01, 0.18)])
			grad.offsets = PackedFloat32Array([0.0, 1.0])
			fill_type = GradientTexture2D.FILL_LINEAR
		UIThemeMode.MODERN_CLEAN_DARK:
			grad.colors = PackedColorArray([Color(0.15, 0.17, 0.25), Color(0.04, 0.05, 0.08)])
			grad.offsets = PackedFloat32Array([0.0, 1.0])
		UIThemeMode.CLEAN_LIGHT:
			grad.colors = PackedColorArray([Color(0.98, 0.99, 1.0), Color(0.84, 0.88, 0.95)])
			grad.offsets = PackedFloat32Array([0.0, 1.0])

	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = fill_type
	tex.fill_from = Vector2(0.5, 0.3)
	tex.fill_to = Vector2(1.0, 1.0)
	tex.width = 1920
	tex.height = 1080
	return tex

static func apply_theme(target: Node, mode: int) -> void:
	var colors = get_theme_colors(mode)
	_recursive_apply_colors(target, colors)

static func _recursive_apply_colors(node: Node, colors: Dictionary) -> void:
	if node is PanelContainer or node is Panel:
		var sb = StyleBoxFlat.new()
		sb.bg_color = colors["surface"]
		sb.set_corner_radius_all(8)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = colors["accent"].darkened(0.5)
		sb.shadow_color = Color(0, 0, 0, 0.3)
		sb.shadow_size = 4
		node.add_theme_stylebox_override("panel", sb)
	elif node is Button:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("font_hover_color", colors["accent"])
		var sb_norm = StyleBoxFlat.new()
		sb_norm.bg_color = colors["surface"]
		sb_norm.set_corner_radius_all(6)
		sb_norm.content_margin_left = 8
		sb_norm.content_margin_right = 8
		node.add_theme_stylebox_override("normal", sb_norm)
		var sb_hover = StyleBoxFlat.new()
		sb_hover.bg_color = colors["surface"].lightened(0.18)
		sb_hover.border_width_bottom = 2
		sb_hover.border_color = colors["accent"]
		sb_hover.set_corner_radius_all(6)
		sb_hover.content_margin_left = 8
		sb_hover.content_margin_right = 8
		node.add_theme_stylebox_override("hover", sb_hover)
	elif node is Label:
		node.add_theme_color_override("font_color", colors["text"])
	elif node is LineEdit:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("placeholder_color", colors["secondary"])

	for child in node.get_children():
		_recursive_apply_colors(child, colors)
