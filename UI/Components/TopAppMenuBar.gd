class_name TopAppMenuBar
extends MenuBar

## Top Main Window Application File Menu Bar in GDScript for Godot 4.7.

signal load_file_requested
signal scan_dir_requested
signal export_db_requested
signal import_db_requested
signal exit_app_requested

signal view_model_selected(model_index: int)
signal toggle_fullscreen_requested

signal open_system_config_requested
signal open_color_picker_requested
signal toggle_bgm_requested
signal rescan_roms_requested
signal open_about_requested

var _file_menu: PopupMenu
var _view_menu: PopupMenu
var _tools_menu: PopupMenu
var _help_menu: PopupMenu

func _init() -> void:
	custom_minimum_size = Vector2(0, 30)
	_build_menu_bar()

func _build_menu_bar() -> void:
	# 1. File Menu
	_file_menu = PopupMenu.new()
	_file_menu.name = "File"
	_file_menu.add_item("📂 Open Single ROM File...", 100, KEY_MASK_CTRL | KEY_O)
	_file_menu.add_item("📁 Scan Custom ROM Directory...", 101)
	_file_menu.add_separator()
	_file_menu.add_item("💾 Export Database Backup...", 102)
	_file_menu.add_item("📥 Import Database Backup...", 103)
	_file_menu.add_separator()
	_file_menu.add_item("🚪 Exit 3DRetro", 199, KEY_MASK_ALT | KEY_F4)
	_file_menu.id_pressed.connect(_on_file_menu_pressed)
	add_child(_file_menu)

	# 2. View Menu
	_view_menu = PopupMenu.new()
	_view_menu.name = "View"
	_view_menu.add_item("🖥️ Classic 3-Column Desktop", 200)
	_view_menu.add_item("📺 Couch Big Picture TV", 201)
	_view_menu.add_item("📋 Minimalist Compact List", 202)
	_view_menu.add_item("🎲 3D Arcade Carousel", 203)
	_view_menu.add_separator()
	_view_menu.add_item("🔲 Toggle Fullscreen Mode", 210, KEY_F11)
	_view_menu.id_pressed.connect(_on_view_menu_pressed)
	add_child(_view_menu)

	# 3. Tools & Options Menu
	_tools_menu = PopupMenu.new()
	_tools_menu.name = "Tools"
	_tools_menu.add_item("⚙️ Per-System Overrides...", 300)
	_tools_menu.add_item("🎨 Custom UI Theme Colors...", 301)
	_tools_menu.add_item("🎵 Toggle Background Music", 302)
	_tools_menu.add_separator()
	_tools_menu.add_item("🔄 Rescan ROM Directories", 303, KEY_MASK_CTRL | KEY_R)
	_tools_menu.id_pressed.connect(_on_tools_menu_pressed)
	add_child(_tools_menu)

	# 4. Help Menu
	_help_menu = PopupMenu.new()
	_help_menu.name = "Help"
	_help_menu.add_item("❓ About 3DRetro...", 400, KEY_F1)
	_help_menu.id_pressed.connect(_on_help_menu_pressed)
	add_child(_help_menu)

func _on_file_menu_pressed(id: int) -> void:
	match id:
		100: load_file_requested.emit()
		101: scan_dir_requested.emit()
		102: export_db_requested.emit()
		103: import_db_requested.emit()
		199: exit_app_requested.emit()

func _on_view_menu_pressed(id: int) -> void:
	match id:
		200: view_model_selected.emit(0)
		201: view_model_selected.emit(1)
		202: view_model_selected.emit(2)
		203: view_model_selected.emit(3)
		210: toggle_fullscreen_requested.emit()

func _on_tools_menu_pressed(id: int) -> void:
	match id:
		300: open_system_config_requested.emit()
		301: open_color_picker_requested.emit()
		302: toggle_bgm_requested.emit()
		303: rescan_roms_requested.emit()

func _on_help_menu_pressed(id: int) -> void:
	match id:
		400: open_about_requested.emit()
