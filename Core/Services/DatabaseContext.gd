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

const USER_DB_PATH = "user://3dretro_database.json"

func load_database() -> void:
	if not FileAccess.file_exists(_db_path) and FileAccess.file_exists(USER_DB_PATH):
		_db_path = USER_DB_PATH

	var data = _read_json_file(_db_path)
	if data != null:
		_games = data

func save_database() -> void:
	if _write_json_file(_db_path):
		return
	# App folder isn't writable (e.g. installed under Program Files): keep the library in user://
	if _db_path != USER_DB_PATH:
		push_warning("[DatabaseContext] Can't write " + _db_path + ", saving to " + USER_DB_PATH)
		_db_path = USER_DB_PATH
		_write_json_file(_db_path)

func export_to(path: String) -> bool:
	return _write_json_file(path)

func import_from(path: String) -> bool:
	var data = _read_json_file(path)
	if data == null:
		return false
	_games = data
	save_database()
	return true

func get_game(game_id: String) -> Dictionary:
	return _games.get(game_id, {})

func _read_json_file(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_warning("[DatabaseContext] Ignoring unreadable database file: " + path)
		return null
	return json.data

func _write_json_file(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(_games, "\t"))
	file.close()
	return true

func save_game(game: Dictionary, persist: bool = true) -> void:
	if game.has("id"):
		_games[game["id"]] = game
		if persist:
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
