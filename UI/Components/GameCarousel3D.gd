class_name GameCarousel3D
extends SubViewportContainer

## 4-Layer 3D Multi-Tier Game Carousel Component for Godot 4.7.
## Renders games across 4 distinct 3D depth layers (Front Focus, Upper Tier, Lower Tier, Background Depth).

signal game_selected(game_id: String)
signal game_selected_3d(game_id: String)
signal launch_requested(game_id: String)

var _sub_viewport: SubViewport
var _camera: Camera3D
var _pivot_node: Node3D
var _spot_light: SpotLight3D
var _environment: Environment

var _games: Array = []
var _selected_index: int = 0
var _current_layer: int = 0 # 0: Front Focus, 1: Upper Ring, 2: Lower Ring, 3: Far Depth
var _layer_nodes: Array = [[], [], [], []] # 4 Layer Arrays holding 3D card nodes

# Configurable Layer Parameters
var layer_spacing_factor: float = 1.0
var carousel_radius_factor: float = 1.0
var card_scale_factor: float = 1.0

var _current_accent: Color = Color(0.0, 0.85, 0.95)
var _current_sec_accent: Color = Color(0.98, 0.2, 0.75)

func _init() -> void:
	custom_minimum_size = Vector2(800, 600)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	stretch = true
	_build_3d_scene()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	_current_sec_accent = colors.get("accent_secondary", Color(0.98, 0.2, 0.75))
	var bg = colors.get("background", Color(0.04, 0.04, 0.08))

	if _environment:
		_environment.background_color = bg.darkened(0.2)

	if _spot_light:
		_spot_light.light_color = _current_accent

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
	_camera.look_at_from_position(Vector3(0, 0.0, 3.2), Vector3(0, 0.0, 0))

	# 1. Reflective Floor Plane
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(35.0, 35.0)
	floor_mesh.mesh = plane
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.05, 0.05, 0.09)
	floor_mat.metallic = 0.85
	floor_mat.roughness = 0.18
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, -1.8, 0)
	world.add_child(floor_mesh)

	# 2. Lighting Setup
	var dir_light = DirectionalLight3D.new()
	dir_light.rotation_degrees = Vector3(-45, 30, 0)
	dir_light.light_energy = 0.9
	dir_light.light_color = Color(0.85, 0.9, 1.0)
	world.add_child(dir_light)

	_spot_light = SpotLight3D.new()
	_spot_light.position = Vector3(0, 3.5, 2.5)
	_spot_light.rotation_degrees = Vector3(-40, 0, 0)
	_spot_light.spot_angle = 50.0
	_spot_light.light_energy = 4.5
	_spot_light.light_color = _current_accent
	world.add_child(_spot_light)

	_pivot_node = Node3D.new()
	_pivot_node.position = Vector3(0, 0, 0)
	world.add_child(_pivot_node)

func set_games(games: Array) -> void:
	_games = games
	_layer_nodes = [[], [], [], []]
	for child in _pivot_node.get_children():
		child.queue_free()

	var count = games.size()
	if count == 0:
		return

	# Re-build 4-Layer 3D Carousel Nodes
	_rebuild_4_layers()

func _rebuild_4_layers() -> void:
	var count = _games.size()
	if count == 0: return

	# Clear previous layer nodes
	for child in _pivot_node.get_children():
		child.queue_free()
	_layer_nodes = [[], [], [], []]

	# Define 4 Layer Configurations: [Radius, Y-Offset, Z-Offset, Card Scale]
	var layer_configs = [
		[2.1 * carousel_radius_factor, 0.0, 0.0, 1.0 * card_scale_factor],                          # Layer 0: Front Main Focus Ring
		[2.6 * carousel_radius_factor, 0.85 * layer_spacing_factor, -0.6, 0.82 * card_scale_factor], # Layer 1: Upper Elevation Ring
		[2.6 * carousel_radius_factor, -0.85 * layer_spacing_factor, -0.6, 0.82 * card_scale_factor],# Layer 2: Lower Elevation Ring
		[3.3 * carousel_radius_factor, 0.0, -1.35 * layer_spacing_factor, 0.68 * card_scale_factor]  # Layer 3: Far Depth Halo Ring
	]

	for layer_idx in range(4):
		var config = layer_configs[layer_idx]
		var radius: float = config[0]
		var y_offset: float = config[1]
		var z_offset: float = config[2]
		var card_scale: float = config[3]

		var step_angle = (2.0 * PI) / max(count, 6)

		for i in range(count):
			var game = _games[i]
			var angle = i * step_angle
			
			var card_root = Node3D.new()

			# 3D Game Cover Card Mesh
			var card_mesh = MeshInstance3D.new()
			var box = BoxMesh.new()
			box.size = Vector3(1.1 * card_scale, 1.5 * card_scale, 0.08 * card_scale)
			card_mesh.mesh = box
			
			var mat = StandardMaterial3D.new()
			var art_path = game.get("cover_art", "")
			if art_path != "" and FileAccess.file_exists(art_path):
				var img = Image.load_from_file(art_path)
				if img:
					var tex = ImageTexture.create_from_image(img)
					mat.albedo_texture = tex
					mat.albedo_color = Color.WHITE
					mat.emission_enabled = true
					mat.emission_texture = tex
					mat.emission_energy_multiplier = 0.35
			else:
				mat.albedo_color = Color(0.12, 0.16, 0.24)
				mat.emission_enabled = true
				mat.emission = _current_accent
				mat.emission_energy_multiplier = 1.2
			
			card_mesh.material_override = mat
			card_root.add_child(card_mesh)

			# Position in 3D Carousel space
			var pos_x = sin(angle) * radius
			var pos_z = -cos(angle) * radius + z_offset
			card_root.position = Vector3(pos_x, y_offset, pos_z)
			card_root.rotation.y = angle
			
			_pivot_node.add_child(card_root)
			_layer_nodes[layer_idx].append(card_root)

	_update_carousel_rotation()

func adjust_carousel_settings(spacing: float, radius: float, scale_val: float) -> void:
	layer_spacing_factor = spacing
	carousel_radius_factor = radius
	card_scale_factor = scale_val
	_rebuild_4_layers()

func set_active_layer(layer_index: int) -> void:
	_current_layer = posmod(layer_index, 4)
	_update_carousel_rotation()

func select_next() -> void:
	if _games.size() > 0:
		_selected_index = (_selected_index + 1) % _games.size()
		_update_carousel_rotation()

func select_prev() -> void:
	if _games.size() > 0:
		_selected_index = (_selected_index - 1 + _games.size()) % _games.size()
		_update_carousel_rotation()

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("ui_left"):
		select_prev()
	elif event.is_action_pressed("ui_right"):
		select_next()
	elif event.is_action_pressed("ui_up"):
		set_active_layer(_current_layer - 1)
	elif event.is_action_pressed("ui_down"):
		set_active_layer(_current_layer + 1)
	elif event.is_action_pressed("ui_accept"):
		if _games.size() > 0 and _games[_selected_index].has("id"):
			launch_requested.emit(_games[_selected_index]["id"])

func _update_carousel_rotation() -> void:
	if _games.size() == 0:
		return
	var target_angle = -_selected_index * ((2.0 * PI) / max(_games.size(), 6))
	var tween = create_tween()
	tween.tween_property(_pivot_node, "rotation:y", target_angle, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Adjust camera height slightly based on active 4-layer selection
	var cam_target_y = 0.0
	match _current_layer:
		1: cam_target_y = 0.65 # Focus upper layer
		2: cam_target_y = -0.65 # Focus lower layer
		3: cam_target_y = 0.0 # Focus background layer
		_: cam_target_y = 0.0 # Focus front layer
	
	var cam_tween = create_tween()
	cam_tween.tween_property(_camera, "position:y", cam_target_y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if _games[_selected_index].has("id"):
		game_selected.emit(_games[_selected_index]["id"])
		game_selected_3d.emit(_games[_selected_index]["id"])
