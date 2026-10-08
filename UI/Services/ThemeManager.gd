class_name ThemeManager
extends RefCounted

## Theme & Skin Manager Service with High-Fidelity UI Styling & Procedural Wallpapers for Godot 4.7 Standard GDScript.

enum UIThemeMode {
	CYBERPUNK_DARK = 0,
	SYNTHWAVE_RETRO = 1,
	VAPORWAVE_MATRIX = 2,
	NES_CRIMSON_GOLD = 3
}

static func get_theme_colors(mode: int) -> Dictionary:
	match mode:
		UIThemeMode.CYBERPUNK_DARK:
			return {
				"background": Color(0.04, 0.04, 0.08),
				"surface": Color(0.08, 0.09, 0.16, 0.90),
				"accent": Color(0.0, 0.92, 1.0), # Electric Cyan
				"accent_secondary": Color(1.0, 0.0, 0.55), # Neon Pink
				"text": Color(0.96, 0.97, 1.0),
				"secondary": Color(0.55, 0.62, 0.78),
				"border_color": Color(0.0, 0.92, 1.0, 0.4)
			}
		UIThemeMode.SYNTHWAVE_RETRO:
			return {
				"background": Color(0.08, 0.02, 0.12),
				"surface": Color(0.14, 0.05, 0.22, 0.90),
				"accent": Color(1.0, 0.08, 0.58), # Hot Magenta
				"accent_secondary": Color(1.0, 0.67, 0.0), # Sunburst Gold
				"text": Color(1.0, 0.94, 0.98),
				"secondary": Color(0.82, 0.52, 0.78),
				"border_color": Color(1.0, 0.08, 0.58, 0.4)
			}
		UIThemeMode.VAPORWAVE_MATRIX:
			return {
				"background": Color(0.03, 0.07, 0.05),
				"surface": Color(0.06, 0.12, 0.09, 0.90),
				"accent": Color(0.0, 1.0, 0.62), # Electric Mint Emerald
				"accent_secondary": Color(0.65, 1.0, 0.0), # Lime Neon
				"text": Color(0.94, 1.0, 0.96),
				"secondary": Color(0.52, 0.76, 0.64),
				"border_color": Color(0.0, 1.0, 0.62, 0.4)
			}
		UIThemeMode.NES_CRIMSON_GOLD:
			return {
				"background": Color(0.08, 0.02, 0.03),
				"surface": Color(0.15, 0.05, 0.08, 0.90),
				"accent": Color(1.0, 0.84, 0.0), # Imperial Royal Gold
				"accent_secondary": Color(1.0, 0.13, 0.31), # Ruby Crimson
				"text": Color(1.0, 0.96, 0.88),
				"secondary": Color(0.78, 0.66, 0.52),
				"border_color": Color(1.0, 0.84, 0.0, 0.4)
			}
		_:
			return get_theme_colors(UIThemeMode.CYBERPUNK_DARK)

static func generate_skin_background_texture(mode: int) -> Texture2D:
	var grad = Gradient.new()
	var fill_type = GradientTexture2D.FILL_RADIAL

	match mode:
		UIThemeMode.CYBERPUNK_DARK:
			grad.colors = PackedColorArray([
				Color(0.14, 0.08, 0.28), # Deep indigo center
				Color(0.06, 0.04, 0.14),
				Color(0.02, 0.02, 0.06)  # Dark midnight perimeter
			])
			grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
			fill_type = GradientTexture2D.FILL_RADIAL
		UIThemeMode.SYNTHWAVE_RETRO:
			grad.colors = PackedColorArray([
				Color(0.42, 0.04, 0.32), # Sunset Magenta upper center
				Color(0.20, 0.02, 0.22), # Deep Outrun Violet
				Color(0.05, 0.01, 0.10)  # Dark Synthwave Void
			])
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
			fill_type = GradientTexture2D.FILL_LINEAR
		UIThemeMode.VAPORWAVE_MATRIX:
			grad.colors = PackedColorArray([
				Color(0.04, 0.20, 0.14), # Mint Emerald Center Glow
				Color(0.03, 0.09, 0.07),
				Color(0.01, 0.03, 0.02)  # Obsidian Onyx Perimeter
			])
			grad.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
			fill_type = GradientTexture2D.FILL_RADIAL
		UIThemeMode.NES_CRIMSON_GOLD:
			grad.colors = PackedColorArray([
				Color(0.28, 0.05, 0.09), # Rich Burgundy Crimson Center
				Color(0.12, 0.03, 0.05),
				Color(0.04, 0.01, 0.02)  # Dark Mahogany Perimeter
			])
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
			fill_type = GradientTexture2D.FILL_RADIAL

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
	if node.has_method("apply_theme_colors"):
		node.call("apply_theme_colors", colors)
		for child in node.get_children():
			_recursive_apply_colors(child, colors)
		return

	if node is PanelContainer or node is Panel:
		var sb = StyleBoxFlat.new()
		sb.bg_color = colors["surface"]
		sb.set_corner_radius_all(8)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = colors["border_color"]
		sb.shadow_color = Color(0, 0, 0, 0.4)
		sb.shadow_size = 6
		node.add_theme_stylebox_override("panel", sb)
	elif node is Button:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("font_hover_color", colors["accent"])
		node.add_theme_color_override("font_pressed_color", colors.get("accent_secondary", colors["accent"]))
		var sb_norm = StyleBoxFlat.new()
		sb_norm.bg_color = colors["surface"]
		sb_norm.border_width_left = 1
		sb_norm.border_width_top = 1
		sb_norm.border_width_right = 1
		sb_norm.border_width_bottom = 1
		sb_norm.border_color = colors["border_color"]
		sb_norm.set_corner_radius_all(6)
		sb_norm.content_margin_left = 8
		sb_norm.content_margin_right = 8
		node.add_theme_stylebox_override("normal", sb_norm)
		var sb_hover = StyleBoxFlat.new()
		sb_hover.bg_color = colors["surface"].lightened(0.15)
		sb_hover.border_width_left = 1
		sb_hover.border_width_top = 1
		sb_hover.border_width_right = 1
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
		var sb_le = StyleBoxFlat.new()
		sb_le.bg_color = colors["surface"].darkened(0.2)
		sb_le.border_width_left = 1
		sb_le.border_width_top = 1
		sb_le.border_width_right = 1
		sb_le.border_width_bottom = 1
		sb_le.border_color = colors["border_color"]
		sb_le.set_corner_radius_all(6)
		node.add_theme_stylebox_override("normal", sb_le)

	for child in node.get_children():
		_recursive_apply_colors(child, colors)
