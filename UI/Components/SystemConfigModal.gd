class_name SystemConfigModal
extends Window

## RetroBat-inspired Advanced System, Netplay, Save State & Shader Config Modal for Godot 4.7.

signal config_saved(config: Dictionary)

var _title_label: Label
var _mode_opt: OptionButton
var _aspect_opt: OptionButton
var _bezel_opt: OptionButton
var _shader_opt: OptionButton
var _save_slot_opt: OptionButton
var _netplay_opt: OptionButton
var _achievements_user_edit: LineEdit
var _manager = null

func _init(manager = null) -> void:
	_manager = manager
	title = "3DRetro - RetroBat Advanced System Configuration"
	size = Vector2i(600, 560)
	unresizable = true
	exclusive = true
	visible = false
	_build_ui()

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	_title_label = Label.new()
	_title_label.text = "⚙️ Advanced System & Netplay Overrides"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_title_label)

	vbox.add_child(HSeparator.new())

	# 1. Emulator & Display Settings
	_mode_opt = _add_field(vbox, "Execution Engine Mode:", ["Standalone Executable", "Libretro Core (RetroArch)"])
	_aspect_opt = _add_field(vbox, "Aspect Ratio:", ["Original (4:3)", "Widescreen (16:9)", "Integer Scale", "Auto Match"])
	_bezel_opt = _add_field(vbox, "Artwork Bezel Overlay (RetroBat Style):", ["Console Themed Frame", "Arcade Cabinet Frame", "Retro CRT TV Screen", "Disabled"])
	_shader_opt = _add_field(vbox, "Visual Shader Preset:", ["CRT Scanlines (Authentic)", "Subtle Glow", "Cyberpunk Neon", "None"])

	# 2. Save States & Netplay Settings (RetroBat Features)
	_save_slot_opt = _add_field(vbox, "Save State Auto-Load Slot:", ["Disabled (Fresh Boot)", "Slot 0 (Default)", "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5"])
	_netplay_opt = _add_field(vbox, "Netplay Multiplayer Mode:", ["Disabled", "Host Public Lobby", "Join Client Lobby", "Local Wireless Bridge"])

	var user_lbl = Label.new()
	user_lbl.text = "🏆 RetroAchievements User Account:"
	vbox.add_child(user_lbl)

	_achievements_user_edit = LineEdit.new()
	_achievements_user_edit.placeholder_text = "Enter RetroAchievements Username..."
	vbox.add_child(_achievements_user_edit)

	vbox.add_child(HSeparator.new())

	var hbox_btns = HBoxContainer.new()
	hbox_btns.alignment = BoxContainer.ALIGNMENT_END
	hbox_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_btns)

	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(hide)
	hbox_btns.add_child(cancel_btn)

	var save_btn = Button.new()
	save_btn.text = "Save Settings"
	save_btn.pressed.connect(_on_save_pressed)
	hbox_btns.add_child(save_btn)

func _add_field(parent: VBoxContainer, label_text: String, options: Array[String]) -> OptionButton:
	var lbl = Label.new()
	lbl.text = label_text
	parent.add_child(lbl)

	var opt = OptionButton.new()
	for item in options:
		opt.add_item(item)
	parent.add_child(opt)
	return opt

func open_for_platform(platform_name: String) -> void:
	_title_label.text = "⚙️ " + platform_name + " Advanced System Overrides"
	popup_centered()

func _on_save_pressed() -> void:
	var cfg = {
		"mode": _mode_opt.get_item_text(_mode_opt.selected),
		"aspect": _aspect_opt.get_item_text(_aspect_opt.selected),
		"bezel": _bezel_opt.get_item_text(_bezel_opt.selected),
		"shader": _shader_opt.get_item_text(_shader_opt.selected),
		"save_slot": _save_slot_opt.get_item_text(_save_slot_opt.selected),
		"netplay": _netplay_opt.get_item_text(_netplay_opt.selected),
		"achievements_user": _achievements_user_edit.text.strip_edges()
	}
	if _manager and _manager.has_method("save_system_config"):
		_manager.save_system_config(cfg)
	config_saved.emit(cfg)
	hide()
