class_name VideoSnapPlayer
extends PanelContainer

## Video preview & gameplay trailer player in GDScript for standard Godot 4.7.

var _poster_rect: TextureRect
var _overlay: ColorRect
var _status_lbl: Label
var _title_lbl: Label

func _init() -> void:
    custom_minimum_size = Vector2(320, 180)
    _build_ui()

func _build_ui() -> void:
    var stack = Control.new()
    stack.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(stack)

    _poster_rect = TextureRect.new()
    _poster_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _poster_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _poster_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    stack.add_child(_poster_rect)

    _overlay = ColorRect.new()
    _overlay.color = Color(0.05, 0.05, 0.08, 0.85)
    _overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    stack.add_child(_overlay)

    var vbox = VBoxContainer.new()
    vbox.set_anchors_preset(Control.PRESET_CENTER)
    _overlay.add_child(vbox)

    _status_lbl = Label.new()
    _status_lbl.text = "🎬 Video Preview Available"
    _status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(_status_lbl)

    _title_lbl = Label.new()
    _title_lbl.text = "Select a Game"
    _title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title_lbl.modulate = Color(0.7, 0.7, 0.7)
    vbox.add_child(_title_lbl)

func load_game_preview(game: Dictionary) -> void:
    _title_lbl.text = game.get("title", "Select a Game")
    var art_path = game.get("cover_art", "")
    if art_path != "" and FileAccess.file_exists(art_path):
        var img = Image.load_from_file(art_path)
        if img:
            _poster_rect.texture = ImageTexture.create_from_image(img)
    else:
        _poster_rect.texture = null
