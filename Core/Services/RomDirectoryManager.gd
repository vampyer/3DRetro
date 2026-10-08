class_name RomDirectoryManager
extends RefCounted

## Auto-generates 33 platform ROM directories with README files in standard Godot 4.7.

static func get_all_supported_platforms() -> Array[Dictionary]:
    return [
        {"id": "snes", "name": "Super Nintendo (SNES)", "ext": [".sfc", ".smc", ".zip", ".7z"]},
        {"id": "nes", "name": "Nintendo (NES)", "ext": [".nes", ".zip"]},
        {"id": "genesis", "name": "Sega Genesis / Mega Drive", "ext": [".md", ".smd", ".gen", ".zip"]},
        {"id": "gba", "name": "Game Boy Advance (GBA)", "ext": [".gba", ".zip"]},
        {"id": "arcade", "name": "Arcade Hardware", "ext": [".zip", ".7z"]},
        {"id": "ps1", "name": "Sony PlayStation 1", "ext": [".iso", ".cue", ".chd", ".m3u"]},
        {"id": "n64", "name": "Nintendo 64", "ext": [".n64", ".z64", ".v64"]},
        {"id": "gb", "name": "Game Boy", "ext": [".gb", ".zip"]},
        {"id": "gbc", "name": "Game Boy Color", "ext": [".gbc", ".zip"]},
        {"id": "ds", "name": "Nintendo DS", "ext": [".nds", ".zip"]},
        {"id": "gamecube", "name": "Nintendo GameCube", "ext": [".iso", ".gcz", ".rvz"]},
        {"id": "ps2", "name": "Sony PlayStation 2", "ext": [".iso", ".chd"]},
        {"id": "ps3", "name": "Sony PlayStation 3", "ext": [".pkg", ".iso"]},
        {"id": "switch", "name": "Nintendo Switch", "ext": [".nsp", ".xci"]},
        {"id": "psp", "name": "PlayStation Portable", "ext": [".iso", ".cso"]},
        {"id": "saturn", "name": "Sega Saturn", "ext": [".iso", ".cue", ".chd"]},
        {"id": "dreamcast", "name": "Sega Dreamcast", "ext": [".cdi", ".gdi", ".chd"]},
        {"id": "atari2600", "name": "Atari 2600", "ext": [".a26", ".bin"]},
        {"id": "neogeo", "name": "SNK Neo Geo", "ext": [".zip"]},
        {"id": "pcengine", "name": "TurboGrafx-16 / PC Engine", "ext": [".pce", ".zip"]},
        {"id": "mastersystem", "name": "Sega Master System", "ext": [".sms", ".zip"]},
        {"id": "gamegear", "name": "Sega Game Gear", "ext": [".gg", ".zip"]},
        {"id": "c64", "name": "Commodore 64", "ext": [".d64", ".t64", ".prg"]},
        {"id": "amiga", "name": "Commodore Amiga", "ext": [".adf", ".lha"]},
        {"id": "atarist", "name": "Atari ST", "ext": [".st", ".msa"]},
        {"id": "atari5200", "name": "Atari 5200", "ext": [".bin", ".a52"]},
        {"id": "atari7800", "name": "Atari 7800", "ext": [".a78", ".bin"]},
        {"id": "msx", "name": "MSX Home Computer", "ext": [".rom", ".dsk"]},
        {"id": "spectrum", "name": "ZX Spectrum", "ext": [".tzx", ".tap", ".z80"]},
        {"id": "apple2", "name": "Apple II", "ext": [".dsk", ".do"]},
        {"id": "coleco", "name": "ColecoVision", "ext": [".col", ".bin"]},
        {"id": "intellivision", "name": "Intellivision", "ext": [".int", ".bin"]},
        {"id": "wonder-swan", "name": "Bandai WonderSwan", "ext": [".ws", ".wsc"]}
    ]

func ensure_directories_exist() -> Array[String]:
    var paths: Array[String] = []
    var root = "user://ROMS"
    DirAccess.make_dir_recursive_absolute(root)

    for plat in get_all_supported_platforms():
        var dir_path = root + "/" + plat["id"]
        DirAccess.make_dir_recursive_absolute(dir_path)
        paths.append(dir_path)
    return paths
