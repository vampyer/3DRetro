class_name GameCard
extends PanelContainer

## Custom Game Card Component with Procedural Box Art, Platform Badges, Rating Stars, and Neon Glow Effects.

signal game_selected(game_id: String)
signal launch_requested(game_id: String)

var _cover_rect: TextureRect
var _title_label: Label
var _subtitle_label: Label
var _platform_badge: Label
var _fav_badge: Label
var _game_data: Dictionary = {}

var _normal_style: StyleBoxFlat
var _focus_style: StyleBoxFlat

func _init() -> void:
	custom_minimum_size = Vector2(145, 195)
	focus_mode = Control.FOCUS_ALL
	_setup_styles()
	_build_ui()

func _setup_styles() -> void:
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	_normal_style.set_corner_radius_all(8)
	_normal_style.border_width_left = 1
	_normal_style.border_width_top = 1
	_normal_style.border_width_right = 1
	_normal_style.border_width_bottom = 1
	_normal_style.border_color = Color(0.25, 0.25, 0.35, 0.6)

	_focus_style = StyleBoxFlat.new()
	_focus_style.bg_color = Color(0.16, 0.16, 0.25, 0.98)
	_focus_style.set_corner_radius_all(8)
	_focus_style.border_width_left = 2
	_focus_style.border_width_top = 2
	_focus_style.border_width_right = 2
	_focus_style.border_width_bottom = 2
	_focus_style.border_color = Color(0.0, 0.85, 0.95) # Cyberpunk Neon Cyan
	_focus_style.shadow_color = Color(0.0, 0.85, 0.95, 0.4)
	_focus_style.shadow_size = 8

	add_theme_stylebox_override("panel", _normal_style)

func apply_theme_colors(colors: Dictionary) -> void:
	var surface = colors.get("surface", Color(0.12, 0.12, 0.18, 0.95))
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var sec_accent = colors.get("accent_secondary", Color(1.0, 0.82, 0.2))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))

	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = surface
	_normal_style.set_corner_radius_all(8)
	_normal_style.border_width_left = 1
	_normal_style.border_width_top = 1
	_normal_style.border_width_right = 1
	_normal_style.border_width_bottom = 1
	_normal_style.border_color = colors.get("border_color", accent.darkened(0.5))

	_focus_style = StyleBoxFlat.new()
	_focus_style.bg_color = surface.lightened(0.12)
	_focus_style.set_corner_radius_all(8)
	_focus_style.border_width_left = 2
	_focus_style.border_width_top = 2
	_focus_style.border_width_right = 2
	_focus_style.border_width_bottom = 2
	_focus_style.border_color = accent
	_focus_style.shadow_color = Color(accent.r, accent.g, accent.b, 0.5)
	_focus_style.shadow_size = 10

	add_theme_stylebox_override("panel", _focus_style if has_focus() else _normal_style)

	if _title_label:
		_title_label.add_theme_color_override("font_color", text_col)
	if _subtitle_label:
		_subtitle_label.modulate = sec_accent
	if _platform_badge:
		var badge_sb = StyleBoxFlat.new()
		badge_sb.bg_color = surface.darkened(0.3)
		badge_sb.border_width_left = 1
		badge_sb.border_width_top = 1
		badge_sb.border_width_right = 1
		badge_sb.border_width_bottom = 1
		badge_sb.border_color = accent.darkened(0.3)
		badge_sb.set_corner_radius_all(4)
		badge_sb.content_margin_left = 6
		badge_sb.content_margin_right = 6
		_platform_badge.add_theme_stylebox_override("normal", badge_sb)
		_platform_badge.add_theme_color_override("font_color", text_col)

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var cover_stack = Control.new()
	cover_stack.custom_minimum_size = Vector2(133, 135)
	cover_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(cover_stack)

	_cover_rect = TextureRect.new()
	_cover_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cover_stack.add_child(_cover_rect)

	# Top Badges Overlay
	var badge_hbox = HBoxContainer.new()
	badge_hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	badge_hbox.add_theme_constant_override("margin_left", 4)
	badge_hbox.add_theme_constant_override("margin_top", 4)
	badge_hbox.add_theme_constant_override("margin_right", 4)
	cover_stack.add_child(badge_hbox)

	_platform_badge = Label.new()
	_platform_badge.text = "SNES"
	_platform_badge.add_theme_font_size_override("font_size", 10)
	var badge_sb = StyleBoxFlat.new()
	badge_sb.bg_color = Color(0.1, 0.1, 0.2, 0.85)
	badge_sb.set_corner_radius_all(4)
	badge_sb.content_margin_left = 6
	badge_sb.content_margin_right = 6
	_platform_badge.add_theme_stylebox_override("normal", badge_sb)
	badge_hbox.add_child(_platform_badge)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_hbox.add_child(spacer)

	_fav_badge = Label.new()
	_fav_badge.text = "⭐"
	_fav_badge.visible = false
	badge_hbox.add_child(_fav_badge)

	# Title & Metadata Info
	_title_label = Label.new()
	_title_label.text = "Game Title"
	_title_label.add_theme_font_size_override("font_size", 12)
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = "★★★★★ · 1990"
	_subtitle_label.add_theme_font_size_override("font_size", 10)
	_subtitle_label.modulate = Color(1.0, 0.82, 0.2) # Gold Rating Stars
	vbox.add_child(_subtitle_label)

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)
	gui_input.connect(_on_gui_input)

func set_game_data(game: Dictionary) -> void:
	_game_data = game
	_title_label.text = game.get("title", "Unknown Title")
	_fav_badge.visible = game.get("is_favorite", false)
	
	var plat = str(game.get("platform", "retro")).to_upper()
	_platform_badge.text = plat
	
	var yr = str(game.get("release_year", "1995"))
	_subtitle_label.text = "★★★★★ · " + yr

	var art = game.get("cover_art", "")
	if art != "" and FileAccess.file_exists(art):
		var img = Image.load_from_file(art)
		if img:
			_cover_rect.texture = ImageTexture.create_from_image(img)
	else:
		_cover_rect.texture = _generate_procedural_box_art(game.get("title", "Game"), plat)

func _generate_procedural_box_art(title: String, plat: String) -> Texture2D:
	var grad = Gradient.new()
	match plat.to_lower():
		"snes":
			grad.colors = PackedColorArray([Color(0.2, 0.1, 0.4), Color(0.05, 0.05, 0.15)])
		"genesis", "md":
			grad.colors = PackedColorArray([Color(0.4, 0.05, 0.1), Color(0.1, 0.02, 0.05)])
		"n64":
			grad.colors = PackedColorArray([Color(0.4, 0.3, 0.05), Color(0.1, 0.08, 0.02)])
		"ps1", "ps2":
			grad.colors = PackedColorArray([Color(0.05, 0.2, 0.5), Color(0.02, 0.05, 0.15)])
		"arcade":
			grad.colors = PackedColorArray([Color(0.5, 0.0, 0.4), Color(0.15, 0.0, 0.15)])
		_:
			grad.colors = PackedColorArray([Color(0.1, 0.25, 0.35), Color(0.05, 0.1, 0.15)])

	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(1, 1)
	tex.width = 133
	tex.height = 135
	return tex

func _on_focus_entered() -> void:
	add_theme_stylebox_override("panel", _focus_style)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if _game_data.has("id"):
		game_selected.emit(_game_data["id"])

func _on_focus_exited() -> void:
	add_theme_stylebox_override("panel", _normal_style)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _game_data.has("id"):
			launch_requested.emit(_game_data["id"])
			accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _game_data.has("id"):
			game_selected.emit(_game_data["id"])
			if event.double_click:
				launch_requested.emit(_game_data["id"])
