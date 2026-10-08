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

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var sec_accent = colors.get("accent_secondary", accent)
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	add_theme_color_override("font_color", text_col)
	add_theme_color_override("font_hover_color", accent)
	add_theme_color_override("font_pressed_color", sec_accent)
	add_theme_color_override("font_focus_color", accent)

	var sb_norm = StyleBoxFlat.new()
	sb_norm.bg_color = surface.darkened(0.1)
	sb_norm.border_width_left = 1
	sb_norm.border_width_top = 1
	sb_norm.border_width_right = 1
	sb_norm.border_width_bottom = 1
	sb_norm.border_color = border_col
	sb_norm.set_corner_radius_all(4)
	sb_norm.content_margin_left = 10
	sb_norm.content_margin_right = 10
	add_theme_stylebox_override("normal", sb_norm)

	var sb_hover = StyleBoxFlat.new()
	sb_hover.bg_color = surface.lightened(0.15)
	sb_hover.border_width_bottom = 2
	sb_hover.border_color = accent
	sb_hover.set_corner_radius_all(4)
	sb_hover.content_margin_left = 10
	sb_hover.content_margin_right = 10
	add_theme_stylebox_override("hover", sb_hover)

	for popup in [_file_menu, _view_menu, _tools_menu, _help_menu]:
		if popup:
			popup.add_theme_color_override("font_color", text_col)
			popup.add_theme_color_override("font_hover_color", accent)
			popup.add_theme_color_override("font_separator_color", colors.get("secondary", text_col.darkened(0.3)))
			
			var sb_popup = StyleBoxFlat.new()
			sb_popup.bg_color = surface
			sb_popup.border_width_left = 1
			sb_popup.border_width_top = 1
			sb_popup.border_width_right = 1
			sb_popup.border_width_bottom = 1
			sb_popup.border_color = border_col
			sb_popup.set_corner_radius_all(6)
			popup.add_theme_stylebox_override("panel", sb_popup)

			var sb_item_hover = StyleBoxFlat.new()
			sb_item_hover.bg_color = surface.lightened(0.18)
			sb_item_hover.set_corner_radius_all(4)
			popup.add_theme_stylebox_override("hover", sb_item_hover)

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
