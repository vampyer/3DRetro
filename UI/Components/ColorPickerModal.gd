class_name ColorPickerModal
extends Window

signal custom_colors_applied(bg: Color, surface: Color, accent: Color, text: Color)

var _bg_picker: ColorPickerButton
var _surface_picker: ColorPickerButton
var _accent_picker: ColorPickerButton
var _text_picker: ColorPickerButton

func _init() -> void:
    title = "🎨 UI Color Customizer"
    size = Vector2i(420, 360)
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

    var lbl = Label.new()
    lbl.text = "Customize Interface Colors"
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.add_theme_font_size_override("font_size", 18)
    vbox.add_child(lbl)

    _bg_picker = _create_color_row(vbox, "Background Color:", Color(0.08, 0.08, 0.12))
    _surface_picker = _create_color_row(vbox, "Surface / Card Color:", Color(0.14, 0.14, 0.20))
    _accent_picker = _create_color_row(vbox, "Accent Highlight Color:", Color(0.0, 0.85, 0.95))
    _text_picker = _create_color_row(vbox, "Primary Text Color:", Color(0.95, 0.95, 1.0))

    var apply_btn = Button.new()
    apply_btn.text = "✔ Apply Custom Colors"
    apply_btn.custom_minimum_size = Vector2(0, 40)
    apply_btn.pressed.connect(_on_apply_pressed)
    vbox.add_child(apply_btn)

func _create_color_row(parent: VBoxContainer, title_text: String, default_color: Color) -> ColorPickerButton:
    var hbox = HBoxContainer.new()
    var label = Label.new()
    label.text = title_text
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)

    var picker = ColorPickerButton.new()
    picker.color = default_color
    picker.custom_minimum_size = Vector2(60, 30)
    hbox.add_child(picker)

    parent.add_child(hbox)
    return picker

func open_customizer() -> void:
    popup_centered()

func _on_apply_pressed() -> void:
    custom_colors_applied.emit(_bg_picker.color, _surface_picker.color, _accent_picker.color, _text_picker.color)
    hide()
