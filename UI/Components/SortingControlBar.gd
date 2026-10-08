class_name SortingControlBar
extends HBoxContainer

signal sort_mode_changed(sort_mode_index: int)
signal card_density_changed(density_index: int)
signal ui_theme_mode_changed(theme_index: int)
signal custom_color_picker_requested
signal system_config_requested
signal bgm_toggled

enum SortMode {
	TITLE_ASCENDING = 0,
	TITLE_DESCENDING = 1,
	RELEASE_YEAR_NEWEST = 2,
	PLAYTIME_MOST_PLAYED = 3,
	PLAY_COUNT_HIGHEST = 4
}

enum CardDensity {
	SMALL = 0,
	MEDIUM = 1,
	LARGE = 2
}

var _sort_selector: OptionButton
var _density_selector: OptionButton
var _theme_selector: OptionButton
var _custom_color_button: Button
var _sys_config_button: Button
var _bgm_button: Button
var _pad_status_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 12)
	
	# 1. Sort Selector
	var sort_label = Label.new()
	sort_label.text = "Sort By:"
	_sort_selector = OptionButton.new()
	_sort_selector.focus_mode = Control.FOCUS_ALL
	_sort_selector.add_item("Title (A-Z)", SortMode.TITLE_ASCENDING)
	_sort_selector.add_item("Title (Z-A)", SortMode.TITLE_DESCENDING)
	_sort_selector.add_item("Release Year (Newest)", SortMode.RELEASE_YEAR_NEWEST)
	_sort_selector.add_item("Playtime (Most Played)", SortMode.PLAYTIME_MOST_PLAYED)
	_sort_selector.add_item("Play Count (Highest)", SortMode.PLAY_COUNT_HIGHEST)
	_sort_selector.item_selected.connect(func(idx: int): sort_mode_changed.emit(idx))
	
	add_child(sort_label)
	add_child(_sort_selector)
	
	# 2. Card Density Selector
	var density_label = Label.new()
	density_label.text = "Grid Size:"
	_density_selector = OptionButton.new()
	_density_selector.focus_mode = Control.FOCUS_ALL
	_density_selector.add_item("Small Cards (120x160)", CardDensity.SMALL)
	_density_selector.add_item("Medium Cards (180x240)", CardDensity.MEDIUM)
	_density_selector.add_item("Large Cards (240x320)", CardDensity.LARGE)
	_density_selector.selected = CardDensity.MEDIUM
	_density_selector.item_selected.connect(func(idx: int): card_density_changed.emit(idx))
	
	add_child(density_label)
	add_child(_density_selector)
	
	# 3. Theme Selector & Custom Colors
	var theme_label = Label.new()
	theme_label.text = "Theme:"
	_theme_selector = OptionButton.new()
	_theme_selector.focus_mode = Control.FOCUS_ALL
	_theme_selector.add_item("Cyberpunk Dark", 0)
	_theme_selector.add_item("Synthwave Retro", 1)
	_theme_selector.add_item("Modern Clean Dark", 2)
	_theme_selector.add_item("Clean Light", 3)
	_theme_selector.item_selected.connect(func(idx: int): ui_theme_mode_changed.emit(idx))
	
	_custom_color_button = Button.new()
	_custom_color_button.text = "🎨 Custom Colors..."
	_custom_color_button.focus_mode = Control.FOCUS_ALL
	_custom_color_button.pressed.connect(func(): custom_color_picker_requested.emit())
	
	add_child(theme_label)
	add_child(_theme_selector)
	add_child(_custom_color_button)
	
	# 4. System Overrides & BGM
	_sys_config_button = Button.new()
	_sys_config_button.text = "⚙️ System Overrides..."
	_sys_config_button.focus_mode = Control.FOCUS_ALL
	_sys_config_button.pressed.connect(func(): system_config_requested.emit())
	add_child(_sys_config_button)
	
	_bgm_button = Button.new()
	_bgm_button.text = "🎵 BGM Music"
	_bgm_button.focus_mode = Control.FOCUS_ALL
	_bgm_button.pressed.connect(func(): bgm_toggled.emit())
	add_child(_bgm_button)
	
	_pad_status_label = Label.new()
	_pad_status_label.text = "🎮 XInput Gamepad"
	_pad_status_label.modulate = Color(0.2, 0.9, 0.4)
	add_child(_pad_status_label)
