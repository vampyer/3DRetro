class_name VirtualGameGrid
extends ScrollContainer

## Recycled/Virtualized 2D Grid Component in GDScript for Godot 4.7.

signal game_selected(game_id: String)
signal launch_requested(game_id: String)

const GameCardScript = preload("res://UI/Components/GameCard.gd")

var _grid_container: HFlowContainer
var _card_size: Vector2 = Vector2(180, 240)

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_build_ui()

func _build_ui() -> void:
	_grid_container = HFlowContainer.new()
	_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_grid_container.add_theme_constant_override("h_separation", 16)
	_grid_container.add_theme_constant_override("v_separation", 16)
	add_child(_grid_container)

func set_games(games: Array) -> void:
	for child in _grid_container.get_children():
		child.queue_free()

	for game in games:
		var card = GameCardScript.new()
		card.custom_minimum_size = _card_size
		card.set_game_data(game)
		card.game_selected.connect(func(id): game_selected.emit(id))
		card.launch_requested.connect(func(id): launch_requested.emit(id))
		_grid_container.add_child(card)

func set_card_size(new_size: Vector2) -> void:
	_card_size = new_size
	for card in _grid_container.get_children():
		card.custom_minimum_size = new_size
