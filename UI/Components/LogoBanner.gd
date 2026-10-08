class_name LogoBanner
extends PanelContainer

## Stylized 3D Retro Neon Logo Header Badge Component for Godot 4.7.

var _logo_text: Label
var _icon_label: Label

func _init() -> void:
	_setup_style()
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var surface = colors.get("surface", Color(0.08, 0.08, 0.16, 0.95))

	var sb = StyleBoxFlat.new()
	sb.bg_color = surface
	sb.set_corner_radius_all(12)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = accent
	sb.shadow_color = Color(accent.r, accent.g, accent.b, 0.5)
	sb.shadow_size = 12
	sb.content_margin_left = 12
	sb.content_margin_right = 16
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	add_theme_stylebox_override("panel", sb)

	if _logo_text:
		_logo_text.add_theme_color_override("font_shadow_color", Color(accent.r, accent.g, accent.b, 0.8))

func _setup_style() -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.16, 0.95)
	sb.set_corner_radius_all(12)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.0, 0.85, 0.95) # Cyan Neon Glow Border
	sb.shadow_color = Color(0.0, 0.85, 0.95, 0.45)
	sb.shadow_size = 10
	sb.content_margin_left = 12
	sb.content_margin_right = 16
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	add_theme_stylebox_override("panel", sb)

func _build_ui() -> void:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	_icon_label = Label.new()
	_icon_label.text = "🕹️"
	_icon_label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(_icon_label)

	_logo_text = Label.new()
	_logo_text.text = "3D RETRO"
	_logo_text.add_theme_font_size_override("font_size", 22)
	_logo_text.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	_logo_text.add_theme_color_override("font_shadow_color", Color(0.0, 0.85, 0.95, 0.8))
	_logo_text.add_theme_constant_override("shadow_offset_x", 2)
	_logo_text.add_theme_constant_override("shadow_offset_y", 2)
	hbox.add_child(_logo_text)
