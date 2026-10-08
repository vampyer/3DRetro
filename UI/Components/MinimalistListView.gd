class_name MinimalistListView
extends ScrollContainer

## High-Density Compact Data Tree List View in GDScript for Godot 4.7.

signal game_selected(game_id: String)
signal list_game_selected(game_id: String)
signal launch_requested(game_id: String)
signal list_game_activated(game_id: String)

var _tree: Tree

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15, 0.95))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	if _tree:
		_tree.add_theme_color_override("font_color", text_col)
		_tree.add_theme_color_override("title_button_color", accent)
		var sb = StyleBoxFlat.new()
		sb.bg_color = surface
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = border_col
		sb.set_corner_radius_all(6)
		_tree.add_theme_stylebox_override("panel", sb)

func _build_ui() -> void:
	_tree = Tree.new()
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.columns = 5
	_tree.set_column_title(0, "Title")
	_tree.set_column_title(1, "Platform")
	_tree.set_column_title(2, "Developer")
	_tree.set_column_title(3, "Release Year")
	_tree.set_column_title(4, "Playtime")
	_tree.column_titles_visible = true
	add_child(_tree)

	_tree.item_selected.connect(_on_item_selected)
	_tree.item_activated.connect(_on_item_activated)

func set_games(games: Array) -> void:
	_tree.clear()
	var root = _tree.create_item()

	for game in games:
		var item = _tree.create_item(root)
		item.set_text(0, game.get("title", "Unknown Title"))
		item.set_text(1, str(game.get("platform", "SNES")))
		item.set_text(2, game.get("developer", "Unknown"))
		item.set_text(3, str(game.get("release_year", "N/A")))
		item.set_text(4, str(game.get("playtime", 0)) + " mins")
		item.set_metadata(0, game.get("id", ""))

func _on_item_selected() -> void:
	var selected = _tree.get_selected()
	if selected:
		var game_id = selected.get_metadata(0)
		if game_id:
			game_selected.emit(game_id)
			list_game_selected.emit(game_id)

func _on_item_activated() -> void:
	var selected = _tree.get_selected()
	if selected:
		var game_id = selected.get_metadata(0)
		if game_id:
			launch_requested.emit(game_id)
			list_game_activated.emit(game_id)
