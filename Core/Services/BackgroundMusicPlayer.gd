class_name BackgroundMusicPlayer
extends Node

## Background audio soundtrack player for standard Godot 4.7 GDScript.

var _audio_player: AudioStreamPlayer
var _user_volume_db: float = -12.0
var _is_muted: bool = false
var _is_ducked: bool = false

func _ready() -> void:
    _audio_player = AudioStreamPlayer.new()
    _audio_player.name = "BGMPlayerNode"
    _audio_player.volume_db = _user_volume_db
    add_child(_audio_player)

func toggle_mute() -> bool:
    _is_muted = !_is_muted
    _audio_player.volume_db = -80.0 if _is_muted else (_user_volume_db - 15.0 if _is_ducked else _user_volume_db)
    return _is_muted

func is_muted() -> bool:
    return _is_muted

func duck_volume_for_video(duck: bool) -> void:
    _is_ducked = duck
    if !_is_muted:
        _audio_player.volume_db = _user_volume_db - 15.0 if duck else _user_volume_db

func pause_for_game() -> void:
    if _audio_player.playing:
        _audio_player.stream_paused = true

func resume_after_game() -> void:
    if _audio_player.stream_paused:
        _audio_player.stream_paused = false
