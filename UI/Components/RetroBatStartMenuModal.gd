class_name RetroBatStartMenuModal
extends Window

## RetroBat Main Start Menu Overlay in GDScript for Godot 4.7.
## Triggered by Gamepad START Button (JOY_BUTTON_START) or ESCAPE Key.

signal scraper_requested
signal system_settings_requested
signal theme_settings_requested
signal bgm_toggled
signal achievements_requested
signal hotkey_guide_requested
signal exit_app_requested

var _vbox: VBoxContainer
var _title_label: Label
var _buttons: Array = []
var _selected_button_index: int = 0
var _current_theme_colors: Dictionary = {}

func _init() -> void:
	title = "MAIN MENU"
	size = Vector2i(480, 520)
	exclusive = true
	unresizable = true
	transient = true
	visible = false
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	_current_theme_colors = colors
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	if _title_label:
		_title_label.add_theme_color_override("font_color", text_col)

	for btn in _buttons:
		if btn and is_instance_valid(btn):
			btn.add_theme_color_override("font_color", text_col)
			btn.add_theme_color_override("font_hover_color", accent)
			btn.add_theme_color_override("font_focus_color", accent)
			var sb = StyleBoxFlat.new()
			sb.bg_color = surface
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.border_color = border_col
			sb.set_corner_radius_all(6)
			sb.content_margin_left = 16
			btn.add_theme_stylebox_override("normal", sb)

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(_vbox)

	_title_label = Label.new()
	_title_label.text = "🕹️ MAIN MENU (START)"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 22)
	_vbox.add_child(_title_label)

	var sep = HSeparator.new()
	_vbox.add_child(sep)

	_buttons.clear()

	_create_menu_button("🖼️ SCRAPER & METADATA", func(): scraper_requested.emit(); hide())
	_create_menu_button("⚙️ EMULATOR & SYSTEM SETTINGS", func(): system_settings_requested.emit(); hide())
	_create_menu_button("🎨 UI THEMES & CUSTOM COLORS", func(): theme_settings_requested.emit(); hide())
	_create_menu_button("🎵 AUDIO & BACKGROUND MUSIC", func(): bgm_toggled.emit())
	_create_menu_button("🏆 RETROACHIEVEMENTS PROFILE", func(): achievements_requested.emit(); hide())
	_create_menu_button("🎮 CONTROLLER & HOTKEY GUIDE", func(): hotkey_guide_requested.emit(); hide())
	_create_menu_button("🚪 QUIT 3DRETRO", func(): exit_app_requested.emit())

func _create_menu_button(label_text: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.focus_mode = Control.FOCUS_ALL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(callback)
	_vbox.add_child(btn)
	_buttons.append(btn)

func open_menu() -> void:
	popup_centered()
	_selected_button_index = 0
	if _buttons.size() > 0:
		_buttons[0].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			hide()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START or event.button_index == JOY_BUTTON_B:
			hide()
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_DPAD_UP:
			_selected_button_index = (_selected_button_index - 1 + _buttons.size()) % _buttons.size()
			_buttons[_selected_button_index].grab_focus()
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_DPAD_DOWN:
			_selected_button_index = (_selected_button_index + 1) % _buttons.size()
			_buttons[_selected_button_index].grab_focus()
			get_viewport().set_input_as_handled()
