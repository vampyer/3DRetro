class_name HotkeyGuideModal
extends Window

## SDL Controller & Keyboard Hotkey Mapping Guide Modal (RetroBat Batgui style).

func _init() -> void:
	title = "3DRetro - Controller Hotkeys & Input Guide"
	size = Vector2i(560, 460)
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

	var title_lbl = Label.new()
	title_lbl.text = "🎮 Controller Hotkey Shortcuts (RetroBat Standards)"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title_lbl)

	vbox.add_child(HSeparator.new())

	var hotkeys = [
		["Hotkey + Start", "Exit Game back to 3DRetro Dashboard"],
		["Hotkey + X", "Open Emulator Quick Menu"],
		["Hotkey + R1", "Save State to active slot"],
		["Hotkey + L1", "Load State from active slot"],
		["Hotkey + Right D-Pad", "Fast-Forward Gameplay"],
		["Hotkey + Left D-Pad", "Rewind Gameplay"],
		["LB / RB", "Cycle Interface Views (Desktop / Couch TV / List / 3D Carousel)"],
		["Y Button / Ctrl+F", "Focus Quick Search Box"],
		["F11", "Toggle Fullscreen Mode"]
	]

	for hk in hotkeys:
		var hbox = HBoxContainer.new()
		var key_lbl = Label.new()
		key_lbl.text = hk[0]
		key_lbl.add_theme_font_size_override("font_size", 13)
		key_lbl.modulate = Color(0.0, 0.85, 0.95)
		key_lbl.custom_minimum_size = Vector2(180, 0)
		hbox.add_child(key_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = hk[1]
		desc_lbl.add_theme_font_size_override("font_size", 12)
		hbox.add_child(desc_lbl)

		vbox.add_child(hbox)

	vbox.add_child(HSeparator.new())

	var close_btn = Button.new()
	close_btn.text = "Close Hotkey Guide"
	close_btn.pressed.connect(hide)
	vbox.add_child(close_btn)
