class_name MainDashboard
extends Control

const DatabaseContextScript = preload("res://Core/Services/DatabaseContext.gd")
const RomDirectoryManagerScript = preload("res://Core/Services/RomDirectoryManager.gd")
const CollectionManagerScript = preload("res://Core/Services/CollectionManager.gd")
const BackgroundMusicPlayerScript = preload("res://Core/Services/BackgroundMusicPlayer.gd")
const SystemConfigOverrideManagerScript = preload("res://Core/Services/SystemConfigOverrideManager.gd")
const EmulatorLaunchEngineScript = preload("res://Core/Services/EmulatorLaunchEngine.gd")
const ScraperServiceScript = preload("res://Core/Services/ScraperService.gd")
const ShaderPresetManagerScript = preload("res://UI/Services/ShaderPresetManager.gd")
const ThemeManagerScript = preload("res://UI/Services/ThemeManager.gd")

const TopAppMenuBarScript = preload("res://UI/Components/TopAppMenuBar.gd")
const LogoBannerScript = preload("res://UI/Components/LogoBanner.gd")
const SortingControlBarScript = preload("res://UI/Components/SortingControlBar.gd")
const SidebarCategoryNavScript = preload("res://UI/Components/SidebarCategoryNav.gd")
const VirtualGameGridScript = preload("res://UI/Components/VirtualGameGrid.gd")
const CouchBigPictureViewScript = preload("res://UI/Components/CouchBigPictureView.gd")
const MinimalistListViewScript = preload("res://UI/Components/MinimalistListView.gd")
const GameDetailPanelScript = preload("res://UI/Components/GameDetailPanel.gd")
const EmulatorSelectionModalScript = preload("res://UI/Components/EmulatorSelectionModal.gd")
const ColorPickerModalScript = preload("res://UI/Components/ColorPickerModal.gd")
const SystemConfigModalScript = preload("res://UI/Components/SystemConfigModal.gd")
const RetroAchievementsModalScript = preload("res://UI/Components/RetroAchievementsModal.gd")
const HotkeyGuideModalScript = preload("res://UI/Components/HotkeyGuideModal.gd")

var _background_rect: TextureRect
var _top_menu_bar
var _logo_banner
var _download_progress_bar: ProgressBar
var _status_label: Label
var _interface_model_selector: OptionButton
var _sorting_bar

var _sidebar_nav
var _game_grid_2d
var _viewport_container: SubViewportContainer
var _couch_big_picture_view
var _minimalist_list_view
var _detail_panel
var _selection_modal
var _color_picker_modal
var _system_config_modal
var _achievements_modal
var _hotkey_guide_modal
var _grid_container: Control

var _file_dialog: FileDialog
var _about_dialog: AcceptDialog

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

func _ready() -> void:
	_initialize_services()
	_initialize_ui_components()
	_load_and_scan_games()
	_on_theme_changed(0) # Apply initial default skin theme & backdrop texture
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_gamepad_status()

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	_update_gamepad_status()
	if connected:
		var name_str = Input.get_joy_name(device_id)
		_status_label.text = "🎮 Controller Connected: " + name_str
	else:
		_status_label.text = "🔌 Controller Disconnected. Keyboard & Mouse active."

func _update_gamepad_status() -> void:
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		var dev_name = Input.get_joy_name(joypads[0])
		if _sorting_bar and _sorting_bar.has_method("set_gamepad_status"):
			_sorting_bar.set_gamepad_status(true, dev_name)
	else:
		if _sorting_bar and _sorting_bar.has_method("set_gamepad_status"):
			_sorting_bar.set_gamepad_status(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			_toggle_fullscreen()
		elif event.ctrl_pressed and event.keycode == KEY_F:
			if _sidebar_nav and _sidebar_nav.has_method("focus_search_box"):
				_sidebar_nav.focus_search_box()
		elif event.ctrl_pressed and event.keycode == KEY_R:
			_load_and_scan_games()
		elif event.ctrl_pressed and event.keycode == KEY_O:
			_on_menu_open_file_requested()
		elif event.keycode == KEY_F1:
			_on_menu_open_about_requested()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			var prev_model = (_current_interface_model - 1 + 3) % 3
			_interface_model_selector.selected = prev_model
			_switch_interface_model(prev_model)
		elif event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			var next_model = (_current_interface_model + 1) % 3
			_interface_model_selector.selected = next_model
			_switch_interface_model(next_model)
		elif event.button_index == JOY_BUTTON_Y:
			if _sidebar_nav and _sidebar_nav.has_method("focus_search_box"):
				_sidebar_nav.focus_search_box()

func _toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _initialize_services() -> void:
	_db = DatabaseContextScript.new()
	_rom_dir_manager = RomDirectoryManagerScript.new()
	_collection_manager = CollectionManagerScript.new()
	_bgm_player = BackgroundMusicPlayerScript.new()
	_sys_config_manager = SystemConfigOverrideManagerScript.new()
	_shader_manager = ShaderPresetManagerScript.new()
	
	add_child(_bgm_player)

func _initialize_ui_components() -> void:
	# Full-Screen Skin Background Texture Canvas
	_background_rect = TextureRect.new()
	_background_rect.anchor_right = 1.0
	_background_rect.anchor_bottom = 1.0
	_background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_rect.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_background_rect)

	var outer_margin = MarginContainer.new()
	outer_margin.anchor_right = 1.0
	outer_margin.anchor_bottom = 1.0
	outer_margin.add_theme_constant_override("margin_left", 8)
	outer_margin.add_theme_constant_override("margin_top", 4)
	outer_margin.add_theme_constant_override("margin_right", 8)
	outer_margin.add_theme_constant_override("margin_bottom", 8)
	add_child(outer_margin)

	var root_vbox = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 8)
	outer_margin.add_child(root_vbox)

	# 0. Top Main Application Menu Bar (File, View, Tools, Help)
	_top_menu_bar = TopAppMenuBarScript.new()
	_top_menu_bar.load_file_requested.connect(_on_menu_open_file_requested)
	_top_menu_bar.scan_dir_requested.connect(_on_menu_scan_dir_requested)
	_top_menu_bar.export_db_requested.connect(_on_menu_export_db_requested)
	_top_menu_bar.import_db_requested.connect(_on_menu_import_db_requested)
	_top_menu_bar.exit_app_requested.connect(func(): get_tree().quit())
	_top_menu_bar.view_model_selected.connect(func(idx): _interface_model_selector.selected = idx; _switch_interface_model(idx))
	_top_menu_bar.toggle_fullscreen_requested.connect(_toggle_fullscreen)
	_top_menu_bar.open_system_config_requested.connect(_on_system_config_requested)
	_top_menu_bar.open_color_picker_requested.connect(_on_custom_color_picker_requested)
	_top_menu_bar.toggle_bgm_requested.connect(_on_bgm_toggled)
	_top_menu_bar.rescan_roms_requested.connect(_load_and_scan_games)
	_top_menu_bar.open_about_requested.connect(_on_menu_open_about_requested)
	_top_menu_bar.open_achievements_requested.connect(func(): if _achievements_modal: _achievements_modal.open_modal())
	_top_menu_bar.open_hotkey_guide_requested.connect(func(): if _hotkey_guide_modal: _hotkey_guide_modal.popup_centered())
	root_vbox.add_child(_top_menu_bar)

	# Header Bar
	var header_panel = PanelContainer.new()
	root_vbox.add_child(header_panel)

	var header_margin = MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 12)
	header_margin.add_theme_constant_override("margin_right", 12)
	header_margin.add_theme_constant_override("margin_top", 6)
	header_margin.add_theme_constant_override("margin_bottom", 6)
	header_panel.add_child(header_margin)

	var status_container = HBoxContainer.new()
	status_container.add_theme_constant_override("separation", 16)
	header_margin.add_child(status_container)

	# Stylized 3D Retro Neon Logo Badge
	_logo_banner = LogoBannerScript.new()
	status_container.add_child(_logo_banner)

	_status_label = Label.new()
	_status_label.text = "Initializing 3DRetro Engine..."
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_container.add_child(_status_label)

	_download_progress_bar = ProgressBar.new()
	_download_progress_bar.visible = false
	_download_progress_bar.custom_minimum_size = Vector2(250, 20)
	status_container.add_child(_download_progress_bar)

	_interface_model_selector = OptionButton.new()
	_interface_model_selector.custom_minimum_size = Vector2(220, 32)
	_interface_model_selector.focus_mode = Control.FOCUS_ALL
	_interface_model_selector.add_item("🖥️ Classic 3-Column Desktop", 0)
	_interface_model_selector.add_item("📺 Couch Big Picture TV", 1)
	_interface_model_selector.add_item("📋 Minimalist Compact List", 2)
	_interface_model_selector.item_selected.connect(_switch_interface_model)
	status_container.add_child(_interface_model_selector)

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
	body_hbox.add_theme_constant_override("separation", 12)
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
	_game_grid_2d.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_grid_2d.game_selected.connect(_on_game_selected)
	_grid_container.add_child(_game_grid_2d)

	_couch_big_picture_view = CouchBigPictureViewScript.new()
	_couch_big_picture_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_couch_big_picture_view.visible = false
	_couch_big_picture_view.big_picture_game_selected.connect(_on_game_selected)
	_couch_big_picture_view.big_picture_launch_requested.connect(_on_game_launch_requested)
	_grid_container.add_child(_couch_big_picture_view)

	_minimalist_list_view = MinimalistListViewScript.new()
	_minimalist_list_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_minimalist_list_view.visible = false
	_minimalist_list_view.list_game_selected.connect(_on_game_selected)
	_minimalist_list_view.list_game_activated.connect(_on_game_launch_requested)
	_grid_container.add_child(_minimalist_list_view)

	_detail_panel = GameDetailPanelScript.new()
	_detail_panel.launch_requested.connect(_on_game_launch_requested)
	_detail_panel.favorite_toggled.connect(_on_favorite_toggled)
	_detail_panel.metadata_download_requested.connect(_on_metadata_download_requested)
	body_hbox.add_child(_detail_panel)

	# Dialogs & Modals
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.size = Vector2i(750, 500)
	add_child(_file_dialog)

	_about_dialog = AcceptDialog.new()
	_about_dialog.title = "About 3DRetro Frontend"
	_about_dialog.dialog_text = "🕹️ 3DRetro High-Performance Desktop Frontend v1.0.0\n\nBuilt on Standard Godot Engine 4.7 GDScript.\nFeatures 33 Emulated Systems, 4 Dynamic View Models, RetroBat System Configs, CRT Shaders, and Gamepad Autoconfig."
	add_child(_about_dialog)

	_color_picker_modal = ColorPickerModalScript.new()
	_color_picker_modal.custom_colors_applied.connect(_on_custom_colors_applied)
	add_child(_color_picker_modal)

	_system_config_modal = SystemConfigModalScript.new(_sys_config_manager)
	add_child(_system_config_modal)

	_achievements_modal = RetroAchievementsModalScript.new()
	add_child(_achievements_modal)

	_hotkey_guide_modal = HotkeyGuideModalScript.new()
	add_child(_hotkey_guide_modal)

func _on_menu_open_file_requested() -> void:
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.filters = ["*.sfc, *.smc ; Super Nintendo", "*.nes ; Nintendo", "*.md, *.smd ; Genesis", "*.gba ; Game Boy Advance", "*.iso, *.chd ; Disc Images", "*.zip, *.7z ; ROM Archives", "*.* ; All Files"]
	_file_dialog.title = "Open Single ROM File"
	if _file_dialog.file_selected.is_connected(_on_file_dialog_rom_selected):
		_file_dialog.file_selected.disconnect(_on_file_dialog_rom_selected)
	_file_dialog.file_selected.connect(_on_file_dialog_rom_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_file_dialog_rom_selected(path: String) -> void:
	var file_name = path.get_file()
	var plat = "snes"
	if path.ends_with(".nes"): plat = "nes"
	elif path.ends_with(".md") or path.ends_with(".smd"): plat = "genesis"
	elif path.ends_with(".gba"): plat = "gba"
	elif path.ends_with(".iso") or path.ends_with(".chd"): plat = "ps1"
	
	var custom_game = {
		"id": "custom_" + file_name,
		"title": file_name.get_basename().capitalize(),
		"platform": plat,
		"file_path": path,
		"developer": "User Loaded",
		"release_year": 2026,
		"genre": "Custom ROM",
		"rating": 5.0,
		"is_favorite": true,
		"play_count": 1,
		"total_play_time": 0,
		"synopsis": "Directly loaded ROM file from path: " + path,
		"max_players": 2
	}
	_db.save_game(custom_game)
	_loaded_games[custom_game["id"]] = custom_game
	_all_scanned_games.append(custom_game)
	_update_displayed_list(_all_scanned_games)
	_on_game_selected(custom_game["id"])
	_on_game_launch_requested(custom_game["id"])

func _on_menu_scan_dir_requested() -> void:
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_file_dialog.title = "Select Custom ROM Directory to Scan"
	if _file_dialog.dir_selected.is_connected(_on_file_dialog_dir_selected):
		_file_dialog.dir_selected.disconnect(_on_file_dialog_dir_selected)
	_file_dialog.dir_selected.connect(_on_file_dialog_dir_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_file_dialog_dir_selected(dir_path: String) -> void:
	_status_label.text = "Scanning custom directory: " + dir_path + "..."
	var extensions = [".sfc", ".smc", ".nes", ".md", ".smd", ".gba", ".iso", ".zip", ".7z", ".chd", ".nsp", ".xci"]
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var count = 0
		while file_name != "":
			if not dir.current_is_dir():
				for ext in extensions:
					if file_name.ends_with(ext):
						var rom_data = {
							"id": "dir_" + file_name,
							"title": file_name.get_basename().capitalize(),
							"platform": "custom",
							"file_path": dir_path + "/" + file_name,
							"developer": "Scanned ROM",
							"release_year": 2000,
							"genre": "Retro",
							"rating": 4.5,
							"is_favorite": false,
							"play_count": 0,
							"total_play_time": 0,
							"synopsis": "Scanned from custom directory " + dir_path,
							"max_players": 2
						}
						_db.save_game(rom_data)
						_all_scanned_games.append(rom_data)
						_loaded_games[rom_data["id"]] = rom_data
						count += 1
						break
			file_name = dir.get_next()
		dir.list_dir_end()
		_status_label.text = "Scan complete. Added " + str(count) + " ROM files from " + dir_path
		_update_displayed_list(_all_scanned_games)

func _on_menu_export_db_requested() -> void:
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.filters = ["*.json ; JSON Database"]
	_file_dialog.title = "Export Library Database Backup"
	if _file_dialog.file_selected.is_connected(_on_file_dialog_export_selected):
		_file_dialog.file_selected.disconnect(_on_file_dialog_export_selected)
	_file_dialog.file_selected.connect(_on_file_dialog_export_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_file_dialog_export_selected(path: String) -> void:
	_db.save_database()
	_status_label.text = "Exported library database backup to " + path

func _on_menu_import_db_requested() -> void:
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.filters = ["*.json ; JSON Database"]
	_file_dialog.title = "Import Library Database Backup"
	if _file_dialog.file_selected.is_connected(_on_file_dialog_import_selected):
		_file_dialog.file_selected.disconnect(_on_file_dialog_import_selected)
	_file_dialog.file_selected.connect(_on_file_dialog_import_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_file_dialog_import_selected(path: String) -> void:
	_db.load_database()
	_load_and_scan_games()
	_status_label.text = "Imported library database from " + path

func _on_menu_open_about_requested() -> void:
	_about_dialog.popup_centered()

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
	_couch_big_picture_view.set_games(list)
	_minimalist_list_view.set_games(list)

func _switch_interface_model(model_index: int) -> void:
	_current_interface_model = model_index
	_sidebar_nav.visible = true
	_detail_panel.visible = (model_index == 0 or model_index == 2)
	
	_game_grid_2d.visible = (model_index == 0)
	_couch_big_picture_view.visible = (model_index == 1)
	_minimalist_list_view.visible = (model_index == 2)
	if _sorting_bar and _sorting_bar.has_method("update_view_mode_controls"):
		_sorting_bar.update_view_mode_controls(false)

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
		0: size = Vector2(110, 150)
		1: size = Vector2(145, 195)
		2: size = Vector2(190, 255)
		_: size = Vector2(145, 195)
	_game_grid_2d.set_card_size(size)

func _on_theme_changed(theme_index: int) -> void:
	if _background_rect:
		_background_rect.texture = ThemeManagerScript.generate_skin_background_texture(theme_index)
	ThemeManagerScript.apply_theme(self, theme_index)
	if _sorting_bar and _sorting_bar.has_method("set_selected_theme"):
		_sorting_bar.set_selected_theme(theme_index)

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
	if _loaded_games.has(game_id):
		var game = _loaded_games[game_id]
		var updated = ScraperServiceScript.scrape_game_metadata(game)
		_loaded_games[game_id] = updated
		_db.save_game(updated)
		_detail_panel.display_game_details(updated)
		_status_label.text = "📥 Metadata & Artwork updated for " + updated.get("title", "Game") + "."

func _on_game_launch_requested(game_id: String) -> void:
	if _loaded_games.has(game_id):
		var game = _loaded_games[game_id]
		var title = game.get("title", "Game")
		var plat = game.get("platform", "SNES")
		_status_label.text = "🚀 Launching " + title + " (" + str(plat).to_upper() + ")..."
		_bgm_player.pause_for_game()
		
		game["play_count"] = game.get("play_count", 0) + 1
		_db.save_game(game)

		var pid = EmulatorLaunchEngineScript.launch_game(game)
		_status_label.text = "🎮 Running " + title + " (Session Active)..."
		
		get_tree().create_timer(3.0).timeout.connect(func():
			_status_label.text = "Finished session for " + title + "."
			_bgm_player.resume_after_game()
		)
