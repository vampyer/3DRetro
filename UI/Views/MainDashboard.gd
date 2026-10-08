class_name MainDashboard
extends Control

const DatabaseContextScript = preload("res://Core/Services/DatabaseContext.gd")
const RomDirectoryManagerScript = preload("res://Core/Services/RomDirectoryManager.gd")
const CollectionManagerScript = preload("res://Core/Services/CollectionManager.gd")
const BackgroundMusicPlayerScript = preload("res://Core/Services/BackgroundMusicPlayer.gd")
const SystemConfigOverrideManagerScript = preload("res://Core/Services/SystemConfigOverrideManager.gd")
const ShaderPresetManagerScript = preload("res://UI/Services/ShaderPresetManager.gd")
const ThemeManagerScript = preload("res://UI/Services/ThemeManager.gd")

const SortingControlBarScript = preload("res://UI/Components/SortingControlBar.gd")
const SidebarCategoryNavScript = preload("res://UI/Components/SidebarCategoryNav.gd")
const VirtualGameGridScript = preload("res://UI/Components/VirtualGameGrid.gd")
const GameGrid3DScript = preload("res://UI/Components/GameGrid3D.gd")
const CouchBigPictureViewScript = preload("res://UI/Components/CouchBigPictureView.gd")
const MinimalistListViewScript = preload("res://UI/Components/MinimalistListView.gd")
const GameDetailPanelScript = preload("res://UI/Components/GameDetailPanel.gd")
const EmulatorSelectionModalScript = preload("res://UI/Components/EmulatorSelectionModal.gd")
const ColorPickerModalScript = preload("res://UI/Components/ColorPickerModal.gd")
const SystemConfigModalScript = preload("res://UI/Components/SystemConfigModal.gd")

var _download_progress_bar: ProgressBar
var _status_label: Label
var _interface_model_selector: OptionButton
var _sorting_bar

var _sidebar_nav
var _game_grid_2d
var _game_grid_3d
var _viewport_container: SubViewportContainer
var _couch_big_picture_view
var _minimalist_list_view
var _detail_panel
var _selection_modal
var _color_picker_modal
var _system_config_modal
var _grid_container: Control

var _db
var _rom_dir_manager
var _collection_manager
var _bgm_player
var _sys_config_manager
var _shader_manager

var _all_scanned_games: Array = []
var _currently_displayed_games: Array = []
var _loaded_games: Dictionary = {}
var _current_interface_model: int = 0
var _pending_launch_game: Dictionary = {}

func _ready() -> void:
	_initialize_services()
	_initialize_ui_components()
	_load_and_scan_games()
	_on_theme_changed(0) # Apply initial default skin theme

func _initialize_services() -> void:
	_db = DatabaseContextScript.new()
	_rom_dir_manager = RomDirectoryManagerScript.new()
	_collection_manager = CollectionManagerScript.new()
	_bgm_player = BackgroundMusicPlayerScript.new()
	_sys_config_manager = SystemConfigOverrideManagerScript.new()
	_shader_manager = ShaderPresetManagerScript.new()
	
	add_child(_bgm_player)

func _initialize_ui_components() -> void:
	var root_vbox = VBoxContainer.new()
	root_vbox.anchor_right = 1.0
	root_vbox.anchor_bottom = 1.0
	add_child(root_vbox)

	# Header Bar
	var status_container = HBoxContainer.new()
	_status_label = Label.new()
	_status_label.text = "Initializing 3DRetro Engine..."
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_download_progress_bar = ProgressBar.new()
	_download_progress_bar.visible = false
	_download_progress_bar.custom_minimum_size = Vector2(250, 20)

	_interface_model_selector = OptionButton.new()
	_interface_model_selector.custom_minimum_size = Vector2(220, 30)
	_interface_model_selector.focus_mode = Control.FOCUS_ALL
	_interface_model_selector.add_item("🖥️ Classic 3-Column Desktop", 0)
	_interface_model_selector.add_item("📺 Couch Big Picture TV", 1)
	_interface_model_selector.add_item("📋 Minimalist Compact List", 2)
	_interface_model_selector.add_item("🎲 3D Arcade Carousel", 3)
	_interface_model_selector.item_selected.connect(_switch_interface_model)

	status_container.add_child(_status_label)
	status_container.add_child(_download_progress_bar)
	status_container.add_child(_interface_model_selector)
	root_vbox.add_child(status_container)

	# Toolbar
	_sorting_bar = SortingControlBarScript.new()
	_sorting_bar.sort_mode_changed.connect(_on_sort_mode_changed)
	_sorting_bar.card_density_changed.connect(_on_card_density_changed)
	_sorting_bar.ui_theme_mode_changed.connect(_on_theme_changed)
	_sorting_bar.custom_color_picker_requested.connect(_on_custom_color_picker_requested)
	_sorting_bar.system_config_requested.connect(_on_system_config_requested)
	_sorting_bar.bgm_toggled.connect(_on_bgm_toggled)
	root_vbox.add_child(_sorting_bar)

	# Body Layout
	var body_hbox = HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(body_hbox)

	_sidebar_nav = SidebarCategoryNavScript.new()
	_sidebar_nav.category_selected.connect(_on_category_selected)
	_sidebar_nav.search_text_changed.connect(_on_search_text_changed)
	body_hbox.add_child(_sidebar_nav)

	_grid_container = Control.new()
	_grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_hbox.add_child(_grid_container)

	_game_grid_2d = VirtualGameGridScript.new()
	_game_grid_2d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_game_grid_2d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_game_grid_2d.game_selected.connect(_on_game_selected)
	_grid_container.add_child(_game_grid_2d)

	_viewport_container = SubViewportContainer.new()
	_viewport_container.anchor_right = 1.0
	_viewport_container.anchor_bottom = 1.0
	_viewport_container.stretch = true
	_viewport_container.visible = false
	_grid_container.add_child(_viewport_container)

	var viewport = SubViewport.new()
	_viewport_container.add_child(viewport)

	_game_grid_3d = GameGrid3DScript.new()
	_game_grid_3d.game_selected_3d.connect(_on_game_selected)
	viewport.add_child(_game_grid_3d)

	_couch_big_picture_view = CouchBigPictureViewScript.new()
	_couch_big_picture_view.visible = false
	_couch_big_picture_view.big_picture_game_selected.connect(_on_game_selected)
	_couch_big_picture_view.big_picture_launch_requested.connect(_on_game_launch_requested)
	_grid_container.add_child(_couch_big_picture_view)

	_minimalist_list_view = MinimalistListViewScript.new()
	_minimalist_list_view.visible = false
	_minimalist_list_view.list_game_selected.connect(_on_game_selected)
	_minimalist_list_view.list_game_activated.connect(_on_game_launch_requested)
	_grid_container.add_child(_minimalist_list_view)

	_detail_panel = GameDetailPanelScript.new()
	_detail_panel.launch_requested.connect(_on_game_launch_requested)
	_detail_panel.favorite_toggled.connect(_on_favorite_toggled)
	_detail_panel.metadata_download_requested.connect(_on_metadata_download_requested)
	body_hbox.add_child(_detail_panel)

	# Modals
	_selection_modal = EmulatorSelectionModalScript.new()
	_selection_modal.mode_selected.connect(_on_emulator_mode_selected)
	add_child(_selection_modal)

	_color_picker_modal = ColorPickerModalScript.new()
	_color_picker_modal.custom_colors_applied.connect(_on_custom_colors_applied)
	add_child(_color_picker_modal)

	_system_config_modal = SystemConfigModalScript.new(_sys_config_manager)
	add_child(_system_config_modal)

func _load_and_scan_games() -> void:
	_status_label.text = "Scanning ROM directories..."
	var paths = _rom_dir_manager.ensure_directories_exist()
	
	_all_scanned_games.clear()
	_loaded_games.clear()

	# Scan user ROM directories
	var extensions = [".sfc", ".smc", ".nes", ".md", ".smd", ".gba", ".iso", ".zip", ".7z", ".chd", ".nsp", ".xci"]
	for dir_path in paths:
		var dir = DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					for ext in extensions:
						if file_name.ends_with(ext):
							var plat_name = dir_path.get_file()
							var title_clean = file_name.get_basename().capitalize()
							var rom_data = {
								"id": plat_name + "_" + file_name,
								"title": title_clean,
								"platform": plat_name,
								"file_path": dir_path + "/" + file_name,
								"developer": "Unknown Developer",
								"release_year": 1995,
								"genre": "Retro Classic",
								"rating": 4.5,
								"is_favorite": false,
								"play_count": 0,
								"total_play_time": 0,
								"synopsis": "A classic " + plat_name.to_upper() + " retro title scanned from disk.",
								"max_players": 2
							}
							_db.save_game(rom_data)
							_all_scanned_games.append(rom_data)
							_loaded_games[rom_data["id"]] = rom_data
							break
				file_name = dir.get_next()
			dir.list_dir_end()

	# Seed sample games if folder is empty or for demonstration
	if _all_scanned_games.is_empty():
		var sample_games = [
			{
				"id": "snes_smw",
				"title": "Super Mario World",
				"platform": "snes",
				"developer": "Nintendo EAD",
				"release_year": 1990,
				"genre": "Platformer",
				"rating": 4.9,
				"is_favorite": true,
				"play_count": 14,
				"total_play_time": 120,
				"synopsis": "Guide Mario and Luigi through Dinosaur Land to save Princess Toadstool from Bowser!",
				"max_players": 2
			},
			{
				"id": "genesis_sonic2",
				"title": "Sonic the Hedgehog 2",
				"platform": "genesis",
				"developer": "Sonic Team",
				"release_year": 1992,
				"genre": "Platformer",
				"rating": 4.8,
				"is_favorite": true,
				"play_count": 8,
				"total_play_time": 45,
				"synopsis": "Speed through Chemical Plant Zone and Metropolis Zone alongside Miles 'Tails' Prower!",
				"max_players": 2
			},
			{
				"id": "n64_zelda64",
				"title": "The Legend of Zelda: Ocarina of Time",
				"platform": "n64",
				"developer": "Nintendo EAD",
				"release_year": 1998,
				"genre": "Action-Adventure",
				"rating": 5.0,
				"is_favorite": false,
				"play_count": 5,
				"total_play_time": 300,
				"synopsis": "Travel through time as Link to stop Ganondorf from taking control of the Triforce.",
				"max_players": 1
			},
			{
				"id": "ps1_castlevania",
				"title": "Castlevania: Symphony of the Night",
				"platform": "ps1",
				"developer": "Konami",
				"release_year": 1997,
				"genre": "Metroidvania",
				"rating": 4.9,
				"is_favorite": true,
				"play_count": 22,
				"total_play_time": 210,
				"synopsis": "Awaken as Alucard and explore Dracula's treacherous castle in this legendary masterpiece.",
				"max_players": 1
			},
			{
				"id": "arcade_sf2",
				"title": "Street Fighter II Turbo",
				"platform": "arcade",
				"developer": "Capcom",
				"release_year": 1992,
				"genre": "Fighting",
				"rating": 4.7,
				"is_favorite": false,
				"play_count": 35,
				"total_play_time": 90,
				"synopsis": "Master Hadoukens and Shoryukens in the premier head-to-head arcade fighter.",
				"max_players": 2
			},
			{
				"id": "gamecube_metroid",
				"title": "Metroid Prime",
				"platform": "gamecube",
				"developer": "Retro Studios",
				"release_year": 2002,
				"genre": "First-Person Adventure",
				"rating": 4.9,
				"is_favorite": false,
				"play_count": 2,
				"total_play_time": 60,
				"synopsis": "Explore the mystery of Tallon IV through the visor of bounty hunter Samus Aran.",
				"max_players": 1
			},
			{
				"id": "gba_pokemon_emerald",
				"title": "Pokémon Emerald Version",
				"platform": "gba",
				"developer": "Game Freak",
				"release_year": 2004,
				"genre": "RPG",
				"rating": 4.8,
				"is_favorite": true,
				"play_count": 19,
				"total_play_time": 480,
				"synopsis": "Unite Kyogre and Groudon under Rayquaza's skies in the Hoenn region!",
				"max_players": 4
			}
		]
		for g in sample_games:
			_db.save_game(g)
			_all_scanned_games.append(g)
			_loaded_games[g["id"]] = g

	_status_label.text = "3DRetro Ready. Displaying " + str(_all_scanned_games.size()) + " games across " + str(paths.size()) + " platform folders."
	_update_displayed_list(_all_scanned_games)
	if not _all_scanned_games.is_empty():
		_on_game_selected(_all_scanned_games[0]["id"])

func _update_displayed_list(list: Array) -> void:
	_currently_displayed_games = list
	_game_grid_2d.set_games(list)
	_game_grid_3d.set_games(list)
	_couch_big_picture_view.set_games(list)
	_minimalist_list_view.set_games(list)

func _switch_interface_model(model_index: int) -> void:
	_current_interface_model = model_index
	_sidebar_nav.visible = (model_index == 0 or model_index == 2)
	_detail_panel.visible = (model_index == 0 or model_index == 2 or model_index == 3)
	
	_game_grid_2d.visible = (model_index == 0)
	_couch_big_picture_view.visible = (model_index == 1)
	_minimalist_list_view.visible = (model_index == 2)
	if _viewport_container:
		_viewport_container.visible = (model_index == 3)

func _on_sort_mode_changed(sort_index: int) -> void:
	var sorted = _currently_displayed_games.duplicate()
	match sort_index:
		0: sorted.sort_custom(func(a, b): return a.get("title", "").naturalnocasecmp_to(b.get("title", "")) < 0)
		1: sorted.sort_custom(func(a, b): return a.get("title", "").naturalnocasecmp_to(b.get("title", "")) > 0)
		2: sorted.sort_custom(func(a, b): return a.get("release_year", 0) > b.get("release_year", 0))
		3: sorted.sort_custom(func(a, b): return a.get("total_play_time", 0) > b.get("total_play_time", 0))
		4: sorted.sort_custom(func(a, b): return a.get("play_count", 0) > b.get("play_count", 0))
	_update_displayed_list(sorted)

func _on_card_density_changed(density_index: int) -> void:
	var size: Vector2
	match density_index:
		0: size = Vector2(120, 160)
		1: size = Vector2(180, 240)
		2: size = Vector2(240, 320)
		_: size = Vector2(180, 240)
	_game_grid_2d.set_card_size(size)

func _on_theme_changed(theme_index: int) -> void:
	ThemeManagerScript.apply_theme(self, theme_index)

func _on_custom_color_picker_requested() -> void:
	var colors = ThemeManagerScript.get_theme_colors(0)
	_color_picker_modal.open_customizer(colors.background, colors.surface, colors.accent, colors.text)

func _on_custom_colors_applied(bg: Color, surface: Color, accent: Color, text: Color) -> void:
	var colors = {
		"background": bg,
		"surface": surface,
		"accent": accent,
		"text": text,
		"secondary": text.darkened(0.3)
	}
	ThemeManagerScript._recursive_apply_colors(self, colors)
	_status_label.text = "Custom interface colors applied."

func _on_system_config_requested() -> void:
	_system_config_modal.open_for_platform("snes")

func _on_bgm_toggled() -> void:
	var muted = _bgm_player.toggle_mute()
	_status_label.text = "🔇 Background Music Muted" if muted else "🎵 Background Music Active"

func _on_category_selected(category: String) -> void:
	var filtered: Array = []
	if category == "⭐ Favorites": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.FAVORITES)
	elif category == "🕒 Recently Played": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.RECENTLY_PLAYED)
	elif category == "🎮 All Games": filtered = _all_scanned_games
	elif category == "🆕 Never Played": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.NEVER_PLAYED)
	elif category == "👥 2-Player (2P+)": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.MULTIPLAYER_2P)
	elif category == "🎉 Party Games (4P+)": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.PARTY_4P)
	elif category == "🕹️ Arcade Classics": filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, CollectionManagerScript.ARCADE_CLASSICS)
	elif category.begins_with("📁 "):
		var playlist_name = category.replace("📁 ", "").to_lower()
		filtered = CollectionManagerScript.filter_by_collection(_all_scanned_games, "custom_" + playlist_name)
	else:
		filtered = _all_scanned_games.filter(func(g): return g.get("platform", "").to_lower() == category.to_lower() or category.containsn(g.get("platform", "")))

	_update_displayed_list(filtered)

func _on_search_text_changed(text: String) -> void:
	if text.strip_edges().is_empty():
		_update_displayed_list(_all_scanned_games)
	else:
		var matches = _all_scanned_games.filter(func(g): return g.get("title", "").containsn(text))
		_update_displayed_list(matches)

func _on_game_selected(game_id: String) -> void:
	if _loaded_games.has(game_id):
		_detail_panel.display_game_details(_loaded_games[game_id])

func _on_favorite_toggled(game_id: String) -> void:
	var is_fav = _db.toggle_favorite(game_id)
	if _loaded_games.has(game_id):
		_loaded_games[game_id]["is_favorite"] = is_fav
		_detail_panel.display_game_details(_loaded_games[game_id])

func _on_metadata_download_requested(game_id: String) -> void:
	_status_label.text = "Fetching metadata for " + game_id + "..."

func _on_game_launch_requested(game_id: String) -> void:
	if _loaded_games.has(game_id):
		var game = _loaded_games[game_id]
		_pending_launch_game = game
		_selection_modal.prompt_user_choice(game.get("platform", "retro"))

func _on_emulator_mode_selected(mode: int) -> void:
	if _pending_launch_game.is_empty():
		return
	
	var mode_name = "Standalone Engine" if mode == 0 else "RetroArch Libretro Core"
	var title = _pending_launch_game.get("title", "Game")
	_status_label.text = "Launching " + title + " via " + mode_name + "..."
	_bgm_player.pause_for_game()
	
	get_tree().create_timer(3.0).timeout.connect(func():
		_status_label.text = "Finished session for " + title + "."
		_bgm_player.resume_after_game()
	)
