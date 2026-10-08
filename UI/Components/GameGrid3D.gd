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
var _current_accent: Color = Color(0.0, 0.9, 1.0)
var _current_sec_accent: Color = Color(0.98, 0.2, 0.75)
var _environment: Environment

func _init() -> void:
	custom_minimum_size = Vector2(800, 600)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	stretch = true
	_build_3d_scene()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_accent = colors.get("accent", Color(0.0, 0.9, 1.0))
	_current_sec_accent = colors.get("accent_secondary", Color(0.98, 0.2, 0.75))
	var bg = colors.get("background", Color(0.04, 0.04, 0.08))

	if _environment:
		_environment.background_color = bg.darkened(0.2)

	if _spot_light:
		_spot_light.light_color = _current_accent

	for cab_root in _cabinet_nodes:
		if is_instance_valid(cab_root) and cab_root.get_child_count() >= 3:
			var marquee_mesh = cab_root.get_child(2)
			if marquee_mesh and marquee_mesh.material_override:
				marquee_mesh.material_override.emission = _current_sec_accent

func _build_3d_scene() -> void:
	_sub_viewport = SubViewport.new()
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub_viewport.handle_input_locally = true
	add_child(_sub_viewport)

	var world = Node3D.new()
	_sub_viewport.add_child(world)

	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = Color(0.04, 0.04, 0.08)
	_environment.glow_enabled = true
	_environment.glow_intensity = 0.8
	_environment.glow_bloom = 0.25
	var world_env = WorldEnvironment.new()
	world_env.environment = _environment
	world.add_child(world_env)

	_camera = Camera3D.new()
	_camera.keep_aspect = Camera3D.KEEP_WIDTH
	_camera.fov = 60.0
	world.add_child(_camera)
	_camera.look_at_from_position(Vector3(0, 1.15, 2.2), Vector3(0, 0.9, 0))

	# 1. Reflective Floor Plane
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	floor_mesh.mesh = plane
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.06, 0.06, 0.10)
	floor_mat.metallic = 0.85
	floor_mat.roughness = 0.15
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, 0, 0)
	world.add_child(floor_mesh)

	# 2. Lighting Setup
	var dir_light = DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-45, 30, 0)
	dir_light.light_energy = 0.8
	dir_light.light_color = Color(0.85, 0.9, 1.0)
	world.add_child(dir_light)

	_spot_light = SpotLight3D.new()
	_spot_light.position = Vector3(0, 3.2, 1.8)
	_spot_light.rotation_degrees = Vector3(-40, 0, 0)
	_spot_light.spot_angle = 45.0
	_spot_light.light_energy = 4.0
	_spot_light.light_color = _current_accent
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

	var radius = 1.8
	var step_angle = (2.0 * PI) / max(count, 8)

	for i in range(count):
		var game = games[i]
		var angle = i * step_angle
		var cab_root = Node3D.new()

		# Arcade Cabinet Body (Smaller Compact Dimensions)
		var body_mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.85, 1.55, 0.65)
		body_mesh.mesh = box
		body_mesh.position = Vector3(0, 0.775, 0)
		var body_mat = StandardMaterial3D.new()
		body_mat.albedo_color = Color(0.08, 0.08, 0.12)
		body_mat.metallic = 0.7
		body_mat.roughness = 0.3
		body_mesh.material_override = body_mat
		cab_root.add_child(body_mesh)

		# Game Cover Art Screen Card
		var screen_mesh = MeshInstance3D.new()
		var s_box = BoxMesh.new()
		s_box.size = Vector3(0.74, 0.58, 0.04)
		screen_mesh.mesh = s_box
		screen_mesh.position = Vector3(0, 1.05, 0.33)
		var screen_mat = StandardMaterial3D.new()
		
		var art_path = game.get("cover_art", "")
		if art_path != "" and FileAccess.file_exists(art_path):
			var img = Image.load_from_file(art_path)
			if img:
				var tex = ImageTexture.create_from_image(img)
				screen_mat.albedo_texture = tex
				screen_mat.albedo_color = Color.WHITE
				screen_mat.emission_enabled = true
				screen_mat.emission_texture = tex
				screen_mat.emission_energy_multiplier = 0.4
		else:
			screen_mat.albedo_color = Color(0.1, 0.6, 0.95)
			screen_mat.emission_enabled = true
			screen_mat.emission = _current_accent
			screen_mat.emission_energy_multiplier = 1.5

		screen_mesh.material_override = screen_mat
		cab_root.add_child(screen_mesh)

		# Glowing Marquee Header Banner
		var marquee_mesh = MeshInstance3D.new()
		var m_box = BoxMesh.new()
		m_box.size = Vector3(0.79, 0.27, 0.10)
		marquee_mesh.mesh = m_box
		marquee_mesh.position = Vector3(0, 1.43, 0.33)
		var marquee_mat = StandardMaterial3D.new()
		marquee_mat.albedo_color = Color(0.95, 0.2, 0.75)
		marquee_mat.emission_enabled = true
		marquee_mat.emission = _current_sec_accent
		marquee_mat.emission_energy_multiplier = 2.5
		marquee_mesh.material_override = marquee_mat
		cab_root.add_child(marquee_mesh)

		# Control Panel Deck
		var deck_mesh = MeshInstance3D.new()
		var d_box = BoxMesh.new()
		d_box.size = Vector3(0.77, 0.19, 0.31)
		deck_mesh.mesh = d_box
		deck_mesh.position = Vector3(0, 0.70, 0.36)
		var deck_mat = StandardMaterial3D.new()
		deck_mat.albedo_color = Color(0.15, 0.15, 0.2)
		deck_mesh.material_override = deck_mat
		cab_root.add_child(deck_mesh)

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
