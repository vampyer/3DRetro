class_name CouchBigPictureView
extends PanelContainer

## 10-Foot Console Couch Big Picture View in GDScript for standard Godot 4.7.

signal game_selected(game_id: String)
signal big_picture_game_selected(game_id: String)
signal launch_requested(game_id: String)
signal big_picture_launch_requested(game_id: String)

const GameCardScript = preload("res://UI/Components/GameCard.gd")

var _hero_art_rect: TextureRect
var _hero_title_lbl: Label
var _hero_platform_lbl: Label
var _hero_synopsis_lbl: Label
var _horizontal_row: HBoxContainer
var _games: Array = []
var _current_theme_colors: Dictionary = {}

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_theme_colors = colors
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))

	if _hero_title_lbl:
		_hero_title_lbl.add_theme_color_override("font_color", text_col)
	if _hero_platform_lbl:
		_hero_platform_lbl.modulate = accent
	if _hero_synopsis_lbl:
		_hero_synopsis_lbl.add_theme_color_override("font_color", text_col)

	for card in _horizontal_row.get_children():
		if card.has_method("apply_theme_colors"):
			card.call("apply_theme_colors", colors)

func _build_ui() -> void:
	var main_stack = Control.new()
	main_stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_stack)

	_hero_art_rect = TextureRect.new()
	_hero_art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_hero_art_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_stack.add_child(_hero_art_rect)

	var overlay = ColorRect.new()
	overlay.color = Color(0.06, 0.06, 0.10, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_stack.add_child(overlay)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 40)
	vbox.add_theme_constant_override("margin_top", 40)
	overlay.add_child(vbox)

	_hero_title_lbl = Label.new()
	_hero_title_lbl.text = "Select a Game"
	_hero_title_lbl.add_theme_font_size_override("font_size", 36)
	vbox.add_child(_hero_title_lbl)

	_hero_platform_lbl = Label.new()
	_hero_platform_lbl.text = "Platform: --"
	_hero_platform_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_hero_platform_lbl)

	_hero_synopsis_lbl = Label.new()
	_hero_synopsis_lbl.text = "Press Left/Right on Gamepad D-Pad to browse library."
	_hero_synopsis_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_hero_synopsis_lbl)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 260)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_horizontal_row = HBoxContainer.new()
	_horizontal_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_horizontal_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_horizontal_row.add_theme_constant_override("separation", 20)
	scroll.add_child(_horizontal_row)

func set_games(games: Array) -> void:
	_games = games
	for child in _horizontal_row.get_children():
		child.queue_free()

	for game in games:
		var card = GameCardScript.new()
		card.custom_minimum_size = Vector2(180, 240)
		card.set_game_data(game)
		if not _current_theme_colors.is_empty() and card.has_method("apply_theme_colors"):
			card.call("apply_theme_colors", _current_theme_colors)
		card.game_selected.connect(func(id):
			_display_hero(game)
			game_selected.emit(id)
			big_picture_game_selected.emit(id)
		)
		card.launch_requested.connect(func(id):
			launch_requested.emit(id)
			big_picture_launch_requested.emit(id)
		)
		_horizontal_row.add_child(card)

func _display_hero(game: Dictionary) -> void:
	_hero_title_lbl.text = game.get("title", "Game Title")
	_hero_platform_lbl.text = "Platform: " + game.get("platform", "SNES")
	_hero_synopsis_lbl.text = game.get("synopsis", game.get("description", "No description available."))
