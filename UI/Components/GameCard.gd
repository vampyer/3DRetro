class_name GameCard
extends PanelContainer

## Custom Game Card Component in GDScript for standard Godot 4.7.

signal game_selected(game_id: String)
signal launch_requested(game_id: String)

var _cover_rect: TextureRect
var _title_label: Label
var _fav_badge: Label
var _game_data: Dictionary = {}

func _init() -> void:
    custom_minimum_size = Vector2(180, 240)
    focus_mode = Control.FOCUS_ALL
    _build_ui()

func _build_ui() -> void:
    var vbox = VBoxContainer.new()
    add_child(vbox)

    _cover_rect = TextureRect.new()
    _cover_rect.custom_minimum_size = Vector2(160, 180)
    _cover_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    vbox.add_child(_cover_rect)

    var hbox = HBoxContainer.new()
    vbox.add_child(hbox)

    _fav_badge = Label.new()
    _fav_badge.text = "⭐"
    _fav_badge.visible = false
    hbox.add_child(_fav_badge)

    _title_label = Label.new()
    _title_label.text = "Game Title"
    _title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hbox.add_child(_title_label)

    focus_entered.connect(_on_focus_entered)
    gui_input.connect(_on_gui_input)

func set_game_data(game: Dictionary) -> void:
    _game_data = game
    _title_label.text = game.get("title", "Unknown Title")
    _fav_badge.visible = game.get("is_favorite", false)

    var art = game.get("cover_art", "")
    if art != "" and FileAccess.file_exists(art):
        var img = Image.load_from_file(art)
        if img:
            _cover_rect.texture = ImageTexture.create_from_image(img)
    else:
        _cover_rect.texture = null

func _on_focus_entered() -> void:
    if _game_data.has("id"):
        game_selected.emit(_game_data["id"])

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if _game_data.has("id"):
            game_selected.emit(_game_data["id"])
            if event.double_click:
                launch_requested.emit(_game_data["id"])
