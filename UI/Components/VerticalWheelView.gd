class_name VerticalWheelView
extends PanelContainer

## High-Fidelity RetroBat Vertical Wheel View in GDScript for Godot 4.7.
## Features vertical carousel wheel scrolling, centered active card highlight,
## video snap preview area, metadata panel, and gamepad D-Pad navigation.

signal game_selected(game_id: String)
signal launch_requested(game_id: String)
signal favorite_toggled(game_id: String)

const GameCardScript = preload("res://UI/Components/GameCard.gd")

var _games: Array = []
var _selected_index: int = 0

var _wheel_container: VBoxContainer
var _wheel_scroll: ScrollContainer
var _detail_title_lbl: Label
var _detail_platform_lbl: Label
var _detail_meta_lbl: Label
var _detail_synopsis_lbl: Label
var _launch_btn: Button
var _fav_btn: Button
var _video_snap_panel: PanelContainer

var _current_theme_colors: Dictionary = {}

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_theme_colors = colors
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	if _detail_title_lbl:
		_detail_title_lbl.add_theme_color_override("font_color", text_col)
	if _detail_platform_lbl:
		_detail_platform_lbl.modulate = accent
	if _detail_meta_lbl:
		_detail_meta_lbl.add_theme_color_override("font_color", text_col)
	if _detail_synopsis_lbl:
		_detail_synopsis_lbl.add_theme_color_override("font_color", text_col)

	for child in [_launch_btn, _fav_btn]:
		if child and is_instance_valid(child):
			child.add_theme_color_override("font_color", text_col)
			child.add_theme_color_override("font_hover_color", accent)
			var sb = StyleBoxFlat.new()
			sb.bg_color = surface
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.border_color = border_col
			sb.set_corner_radius_all(6)
			child.add_theme_stylebox_override("normal", sb)

	_update_wheel_cards_visuals()

func _build_ui() -> void:
	var main_hbox = HBoxContainer.new()
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.add_theme_constant_override("separation", 24)
	add_child(main_hbox)

	# Left Column: RetroBat Vertical Wheel Carousel List (40% width)
	_wheel_scroll = ScrollContainer.new()
	_wheel_scroll.custom_minimum_size = Vector2(380, 0)
	_wheel_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_wheel_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_hbox.add_child(_wheel_scroll)

	_wheel_container = VBoxContainer.new()
	_wheel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wheel_container.add_theme_constant_override("separation", 12)
	_wheel_scroll.add_child(_wheel_container)

	# Right Column: Game Backdrop, Video Preview & Detail Card (60% width)
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 14)
	main_hbox.add_child(right_vbox)

	# Video Snap / Art Panel
	_video_snap_panel = PanelContainer.new()
	_video_snap_panel.custom_minimum_size = Vector2(0, 240)
	_video_snap_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(_video_snap_panel)

	var video_lbl = Label.new()
	video_lbl.text = "🎬 Gameplay Video Preview"
	video_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	video_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_video_snap_panel.add_child(video_lbl)

	# Metadata Panel
	var meta_panel = PanelContainer.new()
	meta_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(meta_panel)

	var meta_margin = MarginContainer.new()
	meta_margin.add_theme_constant_override("margin_left", 16)
	meta_margin.add_theme_constant_override("margin_top", 16)
	meta_margin.add_theme_constant_override("margin_right", 16)
	meta_margin.add_theme_constant_override("margin_bottom", 16)
	meta_panel.add_child(meta_margin)

	var meta_vbox = VBoxContainer.new()
	meta_vbox.add_theme_constant_override("separation", 10)
	meta_margin.add_child(meta_vbox)

	_detail_title_lbl = Label.new()
	_detail_title_lbl.text = "Select a Game"
	_detail_title_lbl.add_theme_font_size_override("font_size", 28)
	meta_vbox.add_child(_detail_title_lbl)

	_detail_platform_lbl = Label.new()
	_detail_platform_lbl.text = "Platform: --"
	_detail_platform_lbl.add_theme_font_size_override("font_size", 18)
	meta_vbox.add_child(_detail_platform_lbl)

	_detail_meta_lbl = Label.new()
	_detail_meta_lbl.text = "Developer: -- | Year: -- | Genre: -- | Rating: --"
	meta_vbox.add_child(_detail_meta_lbl)

	_detail_synopsis_lbl = Label.new()
	_detail_synopsis_lbl.text = "Scroll through the Vertical Wheel using Up/Down or Gamepad to explore your titles."
	_detail_synopsis_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_synopsis_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	meta_vbox.add_child(_detail_synopsis_lbl)

	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 12)
	meta_vbox.add_child(btn_hbox)

	_launch_btn = Button.new()
	_launch_btn.text = "🚀 Launch Game (Enter / 🎮 A)"
	_launch_btn.custom_minimum_size = Vector2(220, 42)
	_launch_btn.focus_mode = Control.FOCUS_ALL
	_launch_btn.pressed.connect(_on_launch_pressed)
	btn_hbox.add_child(_launch_btn)

	_fav_btn = Button.new()
	_fav_btn.text = "⭐ Favorite (F / 🎮 Y)"
	_fav_btn.custom_minimum_size = Vector2(180, 42)
	_fav_btn.focus_mode = Control.FOCUS_ALL
	_fav_btn.pressed.connect(_on_fav_pressed)
	btn_hbox.add_child(_fav_btn)

func set_games(games: Array) -> void:
	_games = games
	_selected_index = 0
	_rebuild_wheel()

func _rebuild_wheel() -> void:
	for child in _wheel_container.get_children():
		child.queue_free()

	for idx in range(_games.size()):
		var game = _games[idx]
		var card = GameCardScript.new()
		card.custom_minimum_size = Vector2(340, 75)
		card.set_game_data(game)
		if not _current_theme_colors.is_empty() and card.has_method("apply_theme_colors"):
			card.call("apply_theme_colors", _current_theme_colors)
		
		var index_capture = idx
		card.game_selected.connect(func(id):
			_select_wheel_index(index_capture)
		)
		card.launch_requested.connect(func(id):
			_select_wheel_index(index_capture)
			_on_launch_pressed()
		)
		_wheel_container.add_child(card)

	_update_wheel_cards_visuals()

func _select_wheel_index(idx: int) -> void:
	if _games.is_empty():
		return
	_selected_index = clampi(idx, 0, _games.size() - 1)
	_update_wheel_cards_visuals()
	
	var selected_game = _games[_selected_index]
	game_selected.emit(selected_game.get("id", ""))
	
	_detail_title_lbl.text = selected_game.get("title", "Game")
	_detail_platform_lbl.text = "Platform: " + selected_game.get("platform", "SNES").to_upper()
	_detail_meta_lbl.text = "Dev: " + str(selected_game.get("developer", "Unknown")) + " | Year: " + str(selected_game.get("release_year", 1995)) + " | Rating: ★ " + str(selected_game.get("rating", 4.5))
	_detail_synopsis_lbl.text = selected_game.get("synopsis", "No description available.")

func _update_wheel_cards_visuals() -> void:
	var children = _wheel_container.get_children()
	var accent = _current_theme_colors.get("accent", Color(0.0, 0.85, 0.95))
	
	for idx in range(children.size()):
		var card = children[idx]
		if idx == _selected_index:
			card.modulate = Color(1.1, 1.1, 1.1, 1.0)
			card.scale = Vector2(1.05, 1.05)
		else:
			card.modulate = Color(0.7, 0.7, 0.75, 0.85)
			card.scale = Vector2(1.0, 1.0)

func _on_launch_pressed() -> void:
	if _selected_index >= 0 and _selected_index < _games.size():
		launch_requested.emit(_games[_selected_index].get("id", ""))

func _on_fav_pressed() -> void:
	if _selected_index >= 0 and _selected_index < _games.size():
		favorite_toggled.emit(_games[_selected_index].get("id", ""))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			_select_wheel_index(_selected_index - 1)
		elif event.keycode == KEY_DOWN:
			_select_wheel_index(_selected_index + 1)
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_launch_pressed()
