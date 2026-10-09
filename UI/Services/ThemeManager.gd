class_name ThemeManager
extends RefCounted

## Theme & Skin Manager Service with High-Fidelity RetroBat & EmulationStation UI Styling for Godot 4.7 Standard GDScript.

enum UIThemeMode {
	CYBERPUNK_DARK = 0,
	SYNTHWAVE_RETRO = 1,
	VAPORWAVE_MATRIX = 2,
	NES_CRIMSON_GOLD = 3,
	RETROBAT_CARBON_DARK = 4,
	ALGERO_SNES_CLASSIC = 5,
	NEOGEO_ARCADE_CABINET = 6,
	GAMEBOY_POCKET_MONOCHROME = 7
}

static func get_theme_colors(mode: int) -> Dictionary:
	match mode:
		UIThemeMode.CYBERPUNK_DARK:
			return {
				"background": Color(0.04, 0.04, 0.08),
				"surface": Color(0.07, 0.08, 0.16, 0.98),
				"accent": Color(0.0, 0.92, 1.0), # Electric Cyan
				"accent_secondary": Color(1.0, 0.0, 0.55), # Neon Pink
				"text": Color(0.96, 0.97, 1.0),
				"secondary": Color(0.55, 0.62, 0.78),
				"border_color": Color(0.0, 0.92, 1.0, 0.85)
			}
		UIThemeMode.SYNTHWAVE_RETRO:
			return {
				"background": Color(0.08, 0.02, 0.12),
				"surface": Color(0.10, 0.03, 0.16, 0.98),
				"accent": Color(1.0, 0.08, 0.58), # Hot Magenta
				"accent_secondary": Color(1.0, 0.67, 0.0), # Sunburst Gold
				"text": Color(1.0, 0.94, 0.98),
				"secondary": Color(0.82, 0.52, 0.78),
				"border_color": Color(1.0, 0.08, 0.58, 0.85)
			}
		UIThemeMode.VAPORWAVE_MATRIX:
			return {
				"background": Color(0.03, 0.07, 0.05),
				"surface": Color(0.04, 0.09, 0.07, 0.98),
				"accent": Color(0.0, 1.0, 0.62), # Electric Mint Emerald
				"accent_secondary": Color(0.65, 1.0, 0.0), # Lime Neon
				"text": Color(0.94, 1.0, 0.96),
				"secondary": Color(0.52, 0.76, 0.64),
				"border_color": Color(0.0, 1.0, 0.62, 0.85)
			}
		UIThemeMode.NES_CRIMSON_GOLD:
			return {
				"background": Color(0.08, 0.02, 0.03),
				"surface": Color(0.11, 0.03, 0.05, 0.98),
				"accent": Color(1.0, 0.84, 0.0), # Imperial Royal Gold
				"accent_secondary": Color(1.0, 0.13, 0.31), # Ruby Crimson
				"text": Color(1.0, 0.96, 0.88),
				"secondary": Color(0.78, 0.66, 0.52),
				"border_color": Color(1.0, 0.84, 0.0, 0.85)
			}
		UIThemeMode.RETROBAT_CARBON_DARK:
			return {
				"background": Color(0.06, 0.07, 0.09),
				"surface": Color(0.10, 0.12, 0.15, 0.98),
				"accent": Color(0.0, 0.82, 0.95), # RetroBat Electric Teal
				"accent_secondary": Color(0.95, 0.35, 0.1), # Ember Orange
				"text": Color(0.95, 0.96, 0.98),
				"secondary": Color(0.58, 0.64, 0.72),
				"border_color": Color(0.0, 0.82, 0.95, 0.85)
			}
		UIThemeMode.ALGERO_SNES_CLASSIC:
			return {
				"background": Color(0.82, 0.82, 0.84), # SNES Light Grey Shell
				"surface": Color(0.90, 0.90, 0.92, 0.98), # Console Light Beige
				"accent": Color(0.42, 0.28, 0.65), # SNES Purple
				"accent_secondary": Color(0.85, 0.15, 0.25), # Nintendo Crimson
				"text": Color(0.12, 0.12, 0.16), # Dark Slate Text
				"secondary": Color(0.45, 0.45, 0.52),
				"border_color": Color(0.42, 0.28, 0.65, 0.85)
			}
		UIThemeMode.NEOGEO_ARCADE_CABINET:
			return {
				"background": Color(0.08, 0.02, 0.02),
				"surface": Color(0.14, 0.03, 0.04, 0.98),
				"accent": Color(1.0, 0.78, 0.0), # NeoGeo Gold
				"accent_secondary": Color(0.95, 0.15, 0.0), # Cabinet Red
				"text": Color(1.0, 0.98, 0.92),
				"secondary": Color(0.82, 0.65, 0.45),
				"border_color": Color(1.0, 0.78, 0.0, 0.85)
			}
		UIThemeMode.GAMEBOY_POCKET_MONOCHROME:
			return {
				"background": Color(0.08, 0.12, 0.08), # LCD Dark Matrix
				"surface": Color(0.12, 0.18, 0.12, 0.98),
				"accent": Color(0.55, 0.78, 0.22), # Game Boy Olive Green
				"accent_secondary": Color(0.85, 0.95, 0.45), # Bright Lime LCD
				"text": Color(0.92, 0.98, 0.88),
				"secondary": Color(0.58, 0.72, 0.52),
				"border_color": Color(0.55, 0.78, 0.22, 0.85)
			}
		_:
			return get_theme_colors(UIThemeMode.RETROBAT_CARBON_DARK)

static func generate_skin_background_texture(mode: int) -> Texture2D:
	var grad = Gradient.new()
	var fill_type = GradientTexture2D.FILL_RADIAL

	match mode:
		UIThemeMode.CYBERPUNK_DARK:
			grad.colors = PackedColorArray([Color(0.14, 0.08, 0.28), Color(0.06, 0.04, 0.14), Color(0.02, 0.02, 0.06)])
			grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		UIThemeMode.SYNTHWAVE_RETRO:
			grad.colors = PackedColorArray([Color(0.42, 0.04, 0.32), Color(0.20, 0.02, 0.22), Color(0.05, 0.01, 0.10)])
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
			fill_type = GradientTexture2D.FILL_LINEAR
		UIThemeMode.VAPORWAVE_MATRIX:
			grad.colors = PackedColorArray([Color(0.04, 0.20, 0.14), Color(0.03, 0.09, 0.07), Color(0.01, 0.03, 0.02)])
			grad.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
		UIThemeMode.NES_CRIMSON_GOLD:
			grad.colors = PackedColorArray([Color(0.28, 0.05, 0.09), Color(0.12, 0.03, 0.05), Color(0.04, 0.01, 0.02)])
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		UIThemeMode.RETROBAT_CARBON_DARK:
			grad.colors = PackedColorArray([Color(0.12, 0.14, 0.18), Color(0.06, 0.07, 0.09), Color(0.02, 0.03, 0.04)])
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		UIThemeMode.ALGERO_SNES_CLASSIC:
			grad.colors = PackedColorArray([Color(0.92, 0.92, 0.94), Color(0.82, 0.82, 0.84), Color(0.72, 0.72, 0.75)])
			grad.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
		UIThemeMode.NEOGEO_ARCADE_CABINET:
			grad.colors = PackedColorArray([Color(0.22, 0.05, 0.06), Color(0.08, 0.02, 0.02), Color(0.02, 0.0, 0.01)])
			grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		UIThemeMode.GAMEBOY_POCKET_MONOCHROME:
			grad.colors = PackedColorArray([Color(0.18, 0.25, 0.16), Color(0.08, 0.12, 0.08), Color(0.02, 0.04, 0.02)])
			grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])

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
	elif node is MenuBar:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("font_hover_color", colors["accent"])
		node.add_theme_color_override("font_pressed_color", colors.get("accent_secondary", colors["accent"]))
		var sb_mb = StyleBoxFlat.new()
		sb_mb.bg_color = colors["surface"].darkened(0.1)
		sb_mb.border_width_left = 1
		sb_mb.border_width_top = 1
		sb_mb.border_width_right = 1
		sb_mb.border_width_bottom = 1
		sb_mb.border_color = colors["border_color"]
		sb_mb.set_corner_radius_all(4)
		sb_mb.content_margin_left = 10
		sb_mb.content_margin_right = 10
		node.add_theme_stylebox_override("normal", sb_mb)
	elif node is OptionButton or node is Button:
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

		if node is OptionButton:
			var popup = node.get_popup()
			if popup:
				popup.add_theme_color_override("font_color", colors["text"])
				popup.add_theme_color_override("font_hover_color", colors["accent"])
				var sb_popup = StyleBoxFlat.new()
				sb_popup.bg_color = colors["surface"]
				sb_popup.border_width_left = 1
				sb_popup.border_width_top = 1
				sb_popup.border_width_right = 1
				sb_popup.border_width_bottom = 1
				sb_popup.border_color = colors["border_color"]
				sb_popup.set_corner_radius_all(6)
				popup.add_theme_stylebox_override("panel", sb_popup)
	elif node is PopupMenu:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("font_hover_color", colors["accent"])
		var sb_popup = StyleBoxFlat.new()
		sb_popup.bg_color = colors["surface"]
		sb_popup.border_width_left = 1
		sb_popup.border_width_top = 1
		sb_popup.border_width_right = 1
		sb_popup.border_width_bottom = 1
		sb_popup.border_color = colors["border_color"]
		sb_popup.set_corner_radius_all(6)
		node.add_theme_stylebox_override("panel", sb_popup)
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
