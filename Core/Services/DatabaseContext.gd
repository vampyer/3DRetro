class_name DatabaseContext
extends RefCounted

## Local Database Context for standard Godot 4.7 GDScript.
## Stores ROM metadata, favorites, playtime analytics, and custom collections in application root.

var _db_path: String = ""
var _games: Dictionary = {}

func _init() -> void:
	var base_dir = OS.get_executable_path().get_base_dir() if OS.has_feature("standalone") else ProjectSettings.globalize_path("res://")
	_db_path = base_dir.path_join("3dretro_database.json")
	load_database()

func load_database() -> void:
	if not FileAccess.file_exists(_db_path) and FileAccess.file_exists("user://3dretro_database.json"):
		_db_path = "user://3dretro_database.json"
		
	if FileAccess.file_exists(_db_path):
		var file = FileAccess.open(_db_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_text) == OK:
				if typeof(json.data) == TYPE_DICTIONARY:
					_games = json.data

func save_database() -> void:
	var file = FileAccess.open(_db_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_games, "\t"))
		file.close()

func save_game(game: Dictionary) -> void:
	if game.has("id"):
		_games[game["id"]] = game
		save_database()

func get_all_games() -> Array:
	return _games.values()

func get_favorites() -> Array:
	var favs = []
	for g in _games.values():
		if g.get("is_favorite", false):
			favs.append(g)
	return favs

func toggle_favorite(game_id: String) -> bool:
	if _games.has(game_id):
		var is_fav = !_games[game_id].get("is_favorite", false)
		_games[game_id]["is_favorite"] = is_fav
		save_database()
		return is_fav
	return false
