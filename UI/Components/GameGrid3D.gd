class_name GameGrid3D
extends SubViewportContainer

## 3D Arcade Cover Arc & Carousel Component with Reflective Floor, Emissive Neon Marquees, Spotlights, and Arcade Cabinet Meshes.

signal game_selected(game_id: String)
signal game_selected_3d(game_id: String)
signal launch_requested(game_id: String)

var _sub_viewport: SubViewport
var _camera: Camera3D
var _pivot_node: Node3D
var _spot_light: SpotLight3D
var _games: Array = []
var _selected_index: int = 0
var _cabinet_nodes: Array = []

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
	_camera.look_at_from_position(Vector3(0, 1.8, 4.5), Vector3(0, 1.1, 0))

	# 1. Reflective Floor Plane
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(20.0, 20.0)
	floor_mesh.mesh = plane
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.05, 0.05, 0.08)
	floor_mat.metallic = 0.8
	floor_mat.roughness = 0.2
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, 0, 0)
	world.add_child(floor_mesh)

	# 2. Lighting Setup
	var dir_light = DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-50, 45, 0)
	dir_light.light_energy = 0.6
	dir_light.light_color = Color(0.8, 0.85, 1.0)
	world.add_child(dir_light)

	_spot_light = SpotLight3D.new()
	_spot_light.position = Vector3(0, 4.0, 3.5)
	_spot_light.rotation_degrees = Vector3(-45, 0, 0)
	_spot_light.spot_angle = 35.0
	_spot_light.light_energy = 3.5
	_spot_light.light_color = Color(0.0, 0.9, 1.0) # Cyberpunk Neon Cyan Spotlight
	world.add_child(_spot_light)

	_pivot_node = Node3D.new()
	_pivot_node.position = Vector3(0, 0, 0)
	world.add_child(_pivot_node)

func set_games(games: Array) -> void:
	_games = games
	_cabinet_nodes.clear()
	for child in _pivot_node.get_children():
		child.queue_free()

	var count = games.size()
	if count == 0:
		return

	var radius = 3.8
	var step_angle = (2.0 * PI) / max(count, 8)

	for i in range(count):
		var angle = i * step_angle
		var cab_root = Node3D.new()

		# Arcade Cabinet Body
		var body_mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.9, 1.8, 0.7)
		body_mesh.mesh = box
		body_mesh.position = Vector3(0, 0.9, 0)
		var body_mat = StandardMaterial3D.new()
		body_mat.albedo_color = Color(0.1, 0.1, 0.15)
		body_mesh.material_override = body_mat
		cab_root.add_child(body_mesh)

		# Glowing Screen
		var screen_mesh = MeshInstance3D.new()
		var s_box = BoxMesh.new()
		s_box.size = Vector3(0.75, 0.6, 0.05)
		screen_mesh.mesh = s_box
		screen_mesh.position = Vector3(0, 1.25, 0.36)
		var screen_mat = StandardMaterial3D.new()
		screen_mat.albedo_color = Color(0.1, 0.6, 0.9)
		screen_mat.emission_enabled = true
		screen_mat.emission = Color(0.0, 0.75, 0.95)
		screen_mat.emission_energy_multiplier = 1.5
		screen_mesh.material_override = screen_mat
		cab_root.add_child(screen_mesh)

		# Glowing Marquee Header
		var marquee_mesh = MeshInstance3D.new()
		var m_box = BoxMesh.new()
		m_box.size = Vector3(0.85, 0.3, 0.1)
		marquee_mesh.mesh = m_box
		marquee_mesh.position = Vector3(0, 1.7, 0.36)
		var marquee_mat = StandardMaterial3D.new()
		marquee_mat.albedo_color = Color(0.95, 0.2, 0.7)
		marquee_mat.emission_enabled = true
		marquee_mat.emission = Color(0.98, 0.2, 0.75)
		marquee_mat.emission_energy_multiplier = 2.0
		marquee_mesh.material_override = marquee_mat
		cab_root.add_child(marquee_mesh)

		cab_root.position = Vector3(sin(angle) * radius, 0, -cos(angle) * radius)
		cab_root.rotation.y = angle
		_pivot_node.add_child(cab_root)
		_cabinet_nodes.append(cab_root)

	_update_carousel_rotation()

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("ui_left"):
		select_prev()
	elif event.is_action_pressed("ui_right"):
		select_next()
	elif event.is_action_pressed("ui_accept"):
		if _games.size() > 0 and _games[_selected_index].has("id"):
			launch_requested.emit(_games[_selected_index]["id"])

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
