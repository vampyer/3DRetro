class_name SystemShowcaseView
extends PanelContainer

## High-Fidelity RetroBat Console System Showcase Wall View in GDScript for Godot 4.7.
## Features Hardware Console Cards (SNES, Genesis, NES, N64, PS1, Arcade, GameCube, GBA, etc.)
## displaying game count badges, manufacturer logos, hardware generation specs, and system quick launch.

signal system_selected(platform_id: String)
signal quick_launch_requested(platform_id: String)

var _scroll: ScrollContainer
var _grid: GridContainer
var _title_label: Label
var _subtitle_label: Label

var _games: Array = []
var _current_theme_colors: Dictionary = {}

const SYSTEM_DEFINITIONS = [
	{"id": "snes", "name": "Super Nintendo", "manufacturer": "Nintendo", "year": "1990", "gen": "16-Bit", "color": Color(0.42, 0.28, 0.65)},
	{"id": "genesis", "name": "Sega Genesis / Mega Drive", "manufacturer": "Sega", "year": "1988", "gen": "16-Bit", "color": Color(0.12, 0.45, 0.85)},
	{"id": "nes", "name": "Nintendo Entertainment System", "manufacturer": "Nintendo", "year": "1983", "gen": "8-Bit", "color": Color(0.85, 0.15, 0.22)},
	{"id": "n64", "name": "Nintendo 64", "manufacturer": "Nintendo", "year": "1996", "gen": "64-Bit 3D", "color": Color(0.15, 0.75, 0.32)},
	{"id": "ps1", "name": "Sony PlayStation", "manufacturer": "Sony", "year": "1994", "gen": "32-Bit CD", "color": Color(0.20, 0.35, 0.65)},
	{"id": "arcade", "name": "Arcade MVS / CPS", "manufacturer": "Capcom / SNK", "year": "1980s-90s", "gen": "Coin-Op", "color": Color(0.95, 0.75, 0.0)},
	{"id": "gamecube", "name": "Nintendo GameCube", "manufacturer": "Nintendo", "year": "2001", "gen": "128-Bit", "color": Color(0.38, 0.20, 0.68)},
	{"id": "gba", "name": "Game Boy Advance", "manufacturer": "Nintendo", "year": "2001", "gen": "Handheld 32-Bit", "color": Color(0.25, 0.15, 0.55)},
	{"id": "dreamcast", "name": "Sega Dreamcast", "manufacturer": "Sega", "year": "1998", "gen": "128-Bit GD-ROM", "color": Color(0.95, 0.45, 0.1)},
	{"id": "ps2", "name": "Sony PlayStation 2", "manufacturer": "Sony", "year": "2000", "gen": "Emotion Engine", "color": Color(0.10, 0.20, 0.50)},
	{"id": "psp", "name": "PlayStation Portable", "manufacturer": "Sony", "year": "2004", "gen": "Handheld UMD", "color": Color(0.15, 0.55, 0.75)},
	{"id": "saturn", "name": "Sega Saturn", "manufacturer": "Sega", "year": "1994", "gen": "32-Bit Dual-CPU", "color": Color(0.40, 0.40, 0.45)},
	{"id": "nds", "name": "Nintendo DS", "manufacturer": "Nintendo", "year": "2004", "gen": "Dual Screen", "color": Color(0.70, 0.70, 0.75)},
	{"id": "switch", "name": "Nintendo Switch", "manufacturer": "Nintendo", "year": "2017", "gen": "Hybrid Tegra", "color": Color(0.90, 0.10, 0.15)},
	{"id": "wii", "name": "Nintendo Wii", "manufacturer": "Nintendo", "year": "2006", "gen": "Motion Control", "color": Color(0.0, 0.70, 0.90)},
	{"id": "neogeo", "name": "Neo Geo AES/MVS", "manufacturer": "SNK", "year": "1990", "gen": "24-Bit Arcade", "color": Color(0.85, 0.10, 0.10)}
]

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_theme_colors = colors
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	
	if _title_label:
		_title_label.add_theme_color_override("font_color", text_col)
	if _subtitle_label:
		_subtitle_label.modulate = accent

func _build_ui() -> void:
	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 14)
	add_child(root_vbox)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	root_vbox.add_child(margin)

	var header_vbox = VBoxContainer.new()
	margin.add_child(header_vbox)

	_title_label = Label.new()
	_title_label.text = "🏛️ Console System Showcase"
	_title_label.add_theme_font_size_override("font_size", 26)
	header_vbox.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = "Select a console platform to filter your games library, view hardware specs, or launch a quick session."
	header_vbox.add_child(_subtitle_label)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(_scroll)

	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	_scroll.add_child(_grid)

func set_games(games: Array) -> void:
	_games = games
	_rebuild_system_cards()

func _rebuild_system_cards() -> void:
	for child in _grid.get_children():
		child.queue_free()

	for sys in SYSTEM_DEFINITIONS:
		var sys_id = sys["id"]
		var count = 0
		for g in _games:
			if str(g.get("platform", "")).to_lower() == sys_id:
				count += 1

		var sys_card = PanelContainer.new()
		sys_card.custom_minimum_size = Vector2(260, 160)
		sys_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var sb = StyleBoxFlat.new()
		sb.bg_color = _current_theme_colors.get("surface", Color(0.1, 0.1, 0.15))
		sb.border_width_left = 3
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = sys["color"]
		sb.shadow_color = Color(sys["color"].r, sys["color"].g, sys["color"].b, 0.35)
		sb.shadow_size = 10
		sb.set_corner_radius_all(10)
		sys_card.add_theme_stylebox_override("panel", sb)

		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 14)
		card_margin.add_theme_constant_override("margin_top", 14)
		card_margin.add_theme_constant_override("margin_right", 14)
		card_margin.add_theme_constant_override("margin_bottom", 14)
		sys_card.add_child(card_margin)

		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 6)
		card_margin.add_child(card_vbox)

		var mfg_badge = Label.new()
		mfg_badge.text = sys["manufacturer"].to_upper() + " • " + sys["gen"]
		mfg_badge.modulate = sys["color"]
		mfg_badge.add_theme_font_size_override("font_size", 12)
		card_vbox.add_child(mfg_badge)

		var name_lbl = Label.new()
		name_lbl.text = sys["name"]
		name_lbl.add_theme_font_size_override("font_size", 18)
		card_vbox.add_child(name_lbl)

		var count_lbl = Label.new()
		count_lbl.text = "🎮 " + str(count) + " Games Available (" + sys["year"] + ")"
		count_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_vbox.add_child(count_lbl)

		var browse_btn = Button.new()
		browse_btn.text = "Browse " + sys_id.to_upper() + " Library"
		browse_btn.focus_mode = Control.FOCUS_ALL
		var captured_id = sys_id
		browse_btn.pressed.connect(func():
			system_selected.emit(captured_id)
		)
		card_vbox.add_child(browse_btn)

		# Sleek hover scale animation
		sys_card.mouse_entered.connect(func():
			var tween = sys_card.create_tween()
			tween.tween_property(sys_card, "scale", Vector2(1.04, 1.04), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		)
		sys_card.mouse_exited.connect(func():
			var tween = sys_card.create_tween()
			tween.tween_property(sys_card, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		)

		_grid.add_child(sys_card)
