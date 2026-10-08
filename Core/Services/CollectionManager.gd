class_name CollectionManager
extends RefCounted

## Filter routines for Smart Collections and Custom Playlists in GDScript.

const ALL_GAMES = "all_games"
const FAVORITES = "favorites"
const RECENTLY_PLAYED = "recently_played"
const NEVER_PLAYED = "never_played"
const MULTIPLAYER_2P = "multiplayer_2p"
const PARTY_4P = "party_4p"
const ARCADE_CLASSICS = "arcade_classics"

static func filter_by_collection(roms: Array, collection_id: String) -> Array:
    match collection_id:
        ALL_GAMES:
            return roms
        FAVORITES:
            return roms.filter(func(r): return r.get("is_favorite", false))
        RECENTLY_PLAYED:
            return roms.filter(func(r): return r.get("play_count", 0) > 0)
        NEVER_PLAYED:
            return roms.filter(func(r): return r.get("play_count", 0) == 0)
        MULTIPLAYER_2P:
            return roms.filter(func(r): return r.get("max_players", 1) >= 2)
        PARTY_4P:
            return roms.filter(func(r): return r.get("max_players", 1) >= 4)
        ARCADE_CLASSICS:
            return roms.filter(func(r): return r.get("platform", "").begins_with("arcade") or r.get("platform", "").begins_with("neogeo"))
        _:
            var raw_name = collection_id.replace("custom_", "").replace("_", " ")
            return roms.filter(func(r): return r.get("title", "").containsn(raw_name))
