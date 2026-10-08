class_name SidebarCategoryNav
extends PanelContainer

## Left Navigation Sidebar Component in GDScript for standard Godot 4.7.

signal category_selected(category_name: String)
signal search_text_changed(search_text: String)

const RomDirectoryManagerScript = preload("res://Core/Services/RomDirectoryManager.gd")

var _search_box: LineEdit
var _button_container: VBoxContainer

func _init() -> void:
	custom_minimum_size = Vector2(240, 0)
	_build_ui()

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	add_child(margin)

	var main_vbox = VBoxContainer.new()
	margin.add_child(main_vbox)

	_search_box = LineEdit.new()
	_search_box.placeholder_text = "🔍 Search Games..."
	_search_box.clear_button_enabled = true
	_search_box.text_changed.connect(func(t): search_text_changed.emit(t))
	main_vbox.add_child(_search_box)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	_button_container = VBoxContainer.new()
	scroll.add_child(_button_container)

	_populate_categories()

func _populate_categories() -> void:
	_add_header("SMART COLLECTIONS")
	_add_button("🎮 All Games")
	_add_button("⭐ Favorites")
	_add_button("🕒 Recently Played")
	_add_button("🆕 Never Played")
	_add_button("👥 2-Player (2P+)")
	_add_button("🎉 Party Games (4P+)")
	_add_button("🕹️ Arcade Classics")

	_button_container.add_child(HSeparator.new())
	_add_header("CUSTOM PLAYLISTS")
	_add_button("📁 Mario Franchise")
	_add_button("📁 Zelda Series")
	_add_button("📁 Final Fantasy")
	_add_button("📁 Beat 'em Ups")

	_button_container.add_child(HSeparator.new())
	_add_header("SYSTEM PLATFORMS")
	for plat in RomDirectoryManagerScript.get_all_supported_platforms():
		_add_button(plat["name"])

func _add_header(text_val: String) -> void:
	var lbl = Label.new()
	lbl.text = text_val
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.modulate = Color(0.6, 0.6, 0.6)
	_button_container.add_child(lbl)

func _add_button(label: String) -> void:
	var btn = Button.new()
	btn.text = label
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 36)
	btn.focus_mode = Control.FOCUS_ALL
	btn.pressed.connect(func(): category_selected.emit(label))
	_button_container.add_child(btn)
