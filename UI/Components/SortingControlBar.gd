class_name SortingControlBar
extends HBoxContainer

signal sort_mode_changed(sort_mode_index: int)
signal card_density_changed(density_index: int)
signal ui_theme_mode_changed(theme_index: int)
signal custom_color_picker_requested
signal system_config_requested
signal bgm_toggled
signal carousel_layer_changed(layer_index: int)
signal carousel_spacing_changed(spacing_index: int)

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
var _carousel_layer_selector: OptionButton
var _carousel_spacing_selector: OptionButton
var _theme_selector: OptionButton
var _custom_color_button: Button
var _sys_config_button: Button
var _bgm_button: Button
var _pad_status_label: Label

func _ready() -> void:
	add_theme_constant_override("separation", 10)
	
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
	
	# 2. Card Density Selector (2D Views)
	var density_label = Label.new()
	density_label.text = "Grid Size:"
	_density_selector = OptionButton.new()
	_density_selector.focus_mode = Control.FOCUS_ALL
	_density_selector.add_item("Small Cards (110x150)", CardDensity.SMALL)
	_density_selector.add_item("Medium Cards (145x195)", CardDensity.MEDIUM)
	_density_selector.add_item("Large Cards (190x255)", CardDensity.LARGE)
	_density_selector.selected = CardDensity.MEDIUM
	_density_selector.item_selected.connect(func(idx: int): card_density_changed.emit(idx))
	
	add_child(density_label)
	add_child(_density_selector)

	# 3. 4-Layer 3D Carousel Menu Controls
	_carousel_layer_selector = OptionButton.new()
	_carousel_layer_selector.focus_mode = Control.FOCUS_ALL
	_carousel_layer_selector.add_item("🌀 3D Layer 1: Front Focus", 0)
	_carousel_layer_selector.add_item("🌀 3D Layer 2: Upper Elevation", 1)
	_carousel_layer_selector.add_item("🌀 3D Layer 3: Lower Elevation", 2)
	_carousel_layer_selector.add_item("🌀 3D Layer 4: Background Depth", 3)
	_carousel_layer_selector.item_selected.connect(func(idx: int): carousel_layer_changed.emit(idx))
	_carousel_layer_selector.visible = false
	add_child(_carousel_layer_selector)

	_carousel_spacing_selector = OptionButton.new()
	_carousel_spacing_selector.focus_mode = Control.FOCUS_ALL
	_carousel_spacing_selector.add_item("📐 3D Spacing: Compact", 0)
	_carousel_spacing_selector.add_item("📐 3D Spacing: Normal", 1)
	_carousel_spacing_selector.add_item("📐 3D Spacing: Expanded", 2)
	_carousel_spacing_selector.selected = 1
	_carousel_spacing_selector.item_selected.connect(func(idx: int): carousel_spacing_changed.emit(idx))
	_carousel_spacing_selector.visible = false
	add_child(_carousel_spacing_selector)

	# 4. Theme Selector & Custom Colors
	var theme_label = Label.new()
	theme_label.text = "Theme:"
	_theme_selector = OptionButton.new()
	_theme_selector.focus_mode = Control.FOCUS_ALL
	_theme_selector.add_item("🔮 Cyberpunk Neon", 0)
	_theme_selector.add_item("🌅 Synthwave Outrun", 1)
	_theme_selector.add_item("🌲 Vaporwave Matrix", 2)
	_theme_selector.add_item("👑 NES Crimson & Gold", 3)
	_theme_selector.item_selected.connect(func(idx: int): ui_theme_mode_changed.emit(idx))
	
	_custom_color_button = Button.new()
	_custom_color_button.text = "🎨 Custom Colors..."
	_custom_color_button.focus_mode = Control.FOCUS_ALL
	_custom_color_button.pressed.connect(func(): custom_color_picker_requested.emit())
	
	add_child(theme_label)
	add_child(_theme_selector)
	add_child(_custom_color_button)
	
	# 5. System Overrides & BGM
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

func update_view_mode_controls(is_3d_carousel: bool) -> void:
	if _carousel_layer_selector: _carousel_layer_selector.visible = is_3d_carousel
	if _carousel_spacing_selector: _carousel_spacing_selector.visible = is_3d_carousel
	if _density_selector: _density_selector.visible = not is_3d_carousel

func set_selected_theme(theme_index: int) -> void:
	if _theme_selector and theme_index >= 0 and theme_index < _theme_selector.item_count:
		_theme_selector.selected = theme_index

func set_gamepad_status(connected: bool, device_name: String = "") -> void:
	if not _pad_status_label:
		return
	if connected:
		var name_clean = device_name if not device_name.is_empty() else "Gamepad"
		_pad_status_label.text = "🎮 " + name_clean
		_pad_status_label.modulate = Color(0.2, 0.95, 0.4)
	else:
		_pad_status_label.text = "⌨️ Keyboard & Mouse"
		_pad_status_label.modulate = Color(0.7, 0.8, 1.0)

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var surface = colors.get("surface", Color(0.1, 0.1, 0.15))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	for child in get_children():
		if child is Label and child != _pad_status_label:
			child.add_theme_color_override("font_color", text_col)
		elif child is OptionButton or child is Button:
			child.add_theme_color_override("font_color", text_col)
			child.add_theme_color_override("font_hover_color", accent)
			var sb = StyleBoxFlat.new()
			sb.bg_color = surface
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.border_color = border_col
			sb.set_corner_radius_all(6)
			sb.content_margin_left = 8
			sb.content_margin_right = 8
			child.add_theme_stylebox_override("normal", sb)
