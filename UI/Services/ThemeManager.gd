class_name ThemeManager
extends RefCounted

## Theme & Skin Manager Service for Godot 4.7 Standard GDScript.
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
				"background": Color(0.14, 0.05, 0.20),
				"surface": Color(0.24, 0.10, 0.34),
				"accent": Color(0.98, 0.22, 0.76),
				"text": Color(1.0, 0.92, 0.96),
				"secondary": Color(0.85, 0.45, 0.75)
			}
		UIThemeMode.MODERN_CLEAN_DARK:
			return {
				"background": Color(0.10, 0.10, 0.13),
				"surface": Color(0.18, 0.18, 0.22),
				"accent": Color(0.30, 0.60, 1.0),
				"text": Color(0.92, 0.92, 0.95),
				"secondary": Color(0.60, 0.60, 0.68)
			}
		UIThemeMode.CLEAN_LIGHT:
			return {
				"background": Color(0.92, 0.92, 0.95),
				"surface": Color(0.98, 0.98, 1.0),
				"accent": Color(0.10, 0.45, 0.90),
				"text": Color(0.10, 0.10, 0.15),
				"secondary": Color(0.40, 0.40, 0.50)
			}
		_:
			return get_theme_colors(UIThemeMode.CYBERPUNK_DARK)

static func apply_theme(target: Node, mode: int) -> void:
	var colors = get_theme_colors(mode)
	if target is Control:
		target.self_modulate = colors["background"]
	_recursive_apply_colors(target, colors)

static func _recursive_apply_colors(node: Node, colors: Dictionary) -> void:
	if node is PanelContainer or node is Panel:
		var sb = StyleBoxFlat.new()
		sb.bg_color = colors["surface"]
		sb.set_corner_radius_all(6)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = colors["accent"].darkened(0.5)
		node.add_theme_stylebox_override("panel", sb)
	elif node is Button:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("font_hover_color", colors["accent"])
		var sb_norm = StyleBoxFlat.new()
		sb_norm.bg_color = colors["surface"]
		sb_norm.set_corner_radius_all(4)
		node.add_theme_stylebox_override("normal", sb_norm)
		var sb_hover = StyleBoxFlat.new()
		sb_hover.bg_color = colors["surface"].lightened(0.15)
		sb_hover.border_width_bottom = 2
		sb_hover.border_color = colors["accent"]
		sb_hover.set_corner_radius_all(4)
		node.add_theme_stylebox_override("hover", sb_hover)
	elif node is Label:
		node.add_theme_color_override("font_color", colors["text"])
	elif node is LineEdit:
		node.add_theme_color_override("font_color", colors["text"])
		node.add_theme_color_override("placeholder_color", colors["secondary"])

	for child in node.get_children():
		_recursive_apply_colors(child, colors)
