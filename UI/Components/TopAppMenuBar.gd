class_name TopAppMenuBar
extends HBoxContainer

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

var _file_button: MenuButton
var _view_button: MenuButton
var _tools_button: MenuButton
var _help_button: MenuButton

var _file_menu: PopupMenu
var _view_menu: PopupMenu
var _tools_menu: PopupMenu
var _help_menu: PopupMenu

func _init() -> void:
	custom_minimum_size = Vector2(0, 32)
	add_theme_constant_override("separation", 6)
	_build_menu_bar()

func _build_menu_bar() -> void:
	# 1. File MenuButton
	_file_button = MenuButton.new()
	_file_button.text = "File"
	_file_button.focus_mode = Control.FOCUS_ALL
	_file_menu = _file_button.get_popup()
	_file_menu.add_item("📂 Open Single ROM File...", 100, KEY_MASK_CTRL | KEY_O)
	_file_menu.add_item("📁 Scan Custom ROM Directory...", 101)
	_file_menu.add_separator()
	_file_menu.add_item("💾 Export Database Backup...", 102)
	_file_menu.add_item("📥 Import Database Backup...", 103)
	_file_menu.add_separator()
	_file_menu.add_item("🚪 Exit 3DRetro", 199, KEY_MASK_ALT | KEY_F4)
	_file_menu.id_pressed.connect(_on_file_menu_pressed)
	add_child(_file_button)

	# 2. View MenuButton
	_view_button = MenuButton.new()
	_view_button.text = "View"
	_view_button.focus_mode = Control.FOCUS_ALL
	_view_menu = _view_button.get_popup()
	_view_menu.add_item("🖥️ Classic 3-Column Desktop", 200)
	_view_menu.add_item("📺 Couch Big Picture TV", 201)
	_view_menu.add_item("📋 Minimalist Compact List", 202)
	_view_menu.add_item("🎲 3D Arcade Carousel", 203)
	_view_menu.add_separator()
	_view_menu.add_item("🔲 Toggle Fullscreen Mode", 210, KEY_F11)
	_view_menu.id_pressed.connect(_on_view_menu_pressed)
	add_child(_view_button)

	# 3. Tools MenuButton
	_tools_button = MenuButton.new()
	_tools_button.text = "Tools"
	_tools_button.focus_mode = Control.FOCUS_ALL
	_tools_menu = _tools_button.get_popup()
	_tools_menu.add_item("⚙️ Per-System Overrides...", 300)
	_tools_menu.add_item("🎨 Custom UI Theme Colors...", 301)
	_tools_menu.add_item("🎵 Toggle Background Music", 302)
	_tools_menu.add_separator()
	_tools_menu.add_item("🔄 Rescan ROM Directories", 303, KEY_MASK_CTRL | KEY_R)
	_tools_menu.id_pressed.connect(_on_tools_menu_pressed)
	add_child(_tools_button)

	# 4. Help MenuButton
	_help_button = MenuButton.new()
	_help_button.text = "Help"
	_help_button.focus_mode = Control.FOCUS_ALL
	_help_menu = _help_button.get_popup()
	_help_menu.add_item("❓ About 3DRetro...", 400, KEY_F1)
	_help_menu.id_pressed.connect(_on_help_menu_pressed)
	add_child(_help_button)

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var sec_accent = colors.get("accent_secondary", accent)
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	for btn in [_file_button, _view_button, _tools_button, _help_button]:
		if btn and is_instance_valid(btn):
			btn.add_theme_color_override("font_color", text_col)
			btn.add_theme_color_override("font_hover_color", accent)
			btn.add_theme_color_override("font_pressed_color", sec_accent)
			btn.add_theme_color_override("font_focus_color", accent)

			var sb_norm = StyleBoxFlat.new()
			sb_norm.bg_color = surface.darkened(0.15)
			sb_norm.border_width_left = 1
			sb_norm.border_width_top = 1
			sb_norm.border_width_right = 1
			sb_norm.border_width_bottom = 1
			sb_norm.border_color = border_col
			sb_norm.set_corner_radius_all(6)
			sb_norm.content_margin_left = 12
			sb_norm.content_margin_right = 12
			btn.add_theme_stylebox_override("normal", sb_norm)

			var sb_hover = StyleBoxFlat.new()
			sb_hover.bg_color = surface.lightened(0.15)
			sb_hover.border_width_left = 1
			sb_hover.border_width_top = 1
			sb_hover.border_width_right = 1
			sb_hover.border_width_bottom = 2
			sb_hover.border_color = accent
			sb_hover.set_corner_radius_all(6)
			sb_hover.content_margin_left = 12
			sb_hover.content_margin_right = 12
			btn.add_theme_stylebox_override("hover", sb_hover)

	for popup in [_file_menu, _view_menu, _tools_menu, _help_menu]:
		if popup and is_instance_valid(popup):
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
