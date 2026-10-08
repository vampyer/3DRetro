class_name GameGrid3D
extends SubViewportContainer

## 3D Arcade Cover Arc & Carousel Component in GDScript for Godot 4.7.

signal game_selected(game_id: String)
signal game_selected_3d(game_id: String)
signal launch_requested(game_id: String)

var _sub_viewport: SubViewport
var _camera: Camera3D
var _pivot_node: Node3D
var _games: Array = []
var _selected_index: int = 0

func _init() -> void:
	custom_minimum_size = Vector2(800, 600)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	stretch = true
	_build_3d_scene()

func _build_3d_scene() -> void:
	_sub_viewport = SubViewport.new()
	_sub_viewport.size = Vector2i(1280, 720)
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_sub_viewport)

	var world = Node3D.new()
	_sub_viewport.add_child(world)

	_camera = Camera3D.new()
	world.add_child(_camera)
	_camera.look_at_from_position(Vector3(0, 1.5, 5.0), Vector3(0, 1.0, 0))

	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.light_energy = 1.2
	world.add_child(light)

	var amb_light = OmniLight3D.new()
	amb_light.position = Vector3(0, 2, 2)
	amb_light.light_energy = 0.8
	amb_light.omni_range = 10.0
	world.add_child(amb_light)

	_pivot_node = Node3D.new()
	world.add_child(_pivot_node)

func set_games(games: Array) -> void:
	_games = games
	for child in _pivot_node.get_children():
		child.queue_free()

	var count = games.size()
	if count == 0:
		return

	var radius = 4.0
	var step_angle = (2.0 * PI) / max(count, 8)

	for i in range(count):
		var angle = i * step_angle
		var mesh_inst = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.8, 1.2, 0.1)
		mesh_inst.mesh = box_mesh

		mesh_inst.position = Vector3(sin(angle) * radius, 1.0, -cos(angle) * radius)
		mesh_inst.rotation.y = angle
		_pivot_node.add_child(mesh_inst)

func select_next() -> void:
	if _games.size() > 0:
		_selected_index = (_selected_index + 1) % _games.size()
		_update_carousel_rotation()

func select_prev() -> void:
	if _games.size() > 0:
		_selected_index = (_selected_index - 1 + _games.size()) % _games.size()
		_update_carousel_rotation()

func _update_carousel_rotation() -> void:
	if _games.size() == 0:
		return
	var target_angle = -_selected_index * ((2.0 * PI) / max(_games.size(), 8))
	var tween = create_tween()
	tween.tween_property(_pivot_node, "rotation:y", target_angle, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if _games[_selected_index].has("id"):
		game_selected.emit(_games[_selected_index]["id"])
		game_selected_3d.emit(_games[_selected_index]["id"])
