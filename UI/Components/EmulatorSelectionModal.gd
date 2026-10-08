class_name EmulatorSelectionModal
extends Window

signal mode_selected(mode: int)

var _title_label: Label
var _description_label: Label
var _standalone_button: Button
var _libretro_button: Button

func _ready() -> void:
	title = "Select Emulator Engine Target"
	size = Vector2i(600, 320)
	exclusive = true
	unresizable = true
	
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)
	
	_title_label = Label.new()
	_title_label.text = "Emulator Auto-Downloader"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_title_label)
	
	_description_label = Label.new()
	_description_label.text = "Select your preferred execution engine. Would you like to download and use a Standalone Windows binary or a RetroArch Libretro Core?"
	_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_description_label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	var button_container = VBoxContainer.new()
	_standalone_button = Button.new()
	_standalone_button.text = "🖥️ Download Standalone Windows Emulator (e.g. Dolphin, PCSX2, RPCS3)"
	_standalone_button.custom_minimum_size = Vector2(0, 50)
	_standalone_button.focus_mode = Control.FOCUS_ALL
	_standalone_button.pressed.connect(func(): _on_mode_selected(0))
	
	_libretro_button = Button.new()
	_libretro_button.text = "🎮 Download RetroArch Libretro Core (.dll)"
	_libretro_button.custom_minimum_size = Vector2(0, 50)
	_libretro_button.focus_mode = Control.FOCUS_ALL
	_libretro_button.pressed.connect(func(): _on_mode_selected(1))
	
	button_container.add_child(_standalone_button)
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	button_container.add_child(spacer2)
	button_container.add_child(_libretro_button)
	
	vbox.add_child(button_container)
	close_requested.connect(_on_close_requested)

func prompt_user_choice(platform: String) -> void:
	_title_label.text = "Select Emulator for " + platform
	_description_label.text = "No emulator binary was found for " + platform + ". Choose how you would like to run your games:"
	popup_centered()
	_standalone_button.grab_focus()

func _on_mode_selected(mode: int) -> void:
	mode_selected.emit(mode)
	hide()

func _on_close_requested() -> void:
	mode_selected.emit(1) # Default fallback: Libretro core
	hide()
