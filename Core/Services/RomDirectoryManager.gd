class_name RomDirectoryManager
extends RefCounted

## Auto-generates 33 platform ROM directories and Emulator directories in the executable root folder.

static func get_base_dir() -> String:
	if OS.has_feature("standalone"):
		return OS.get_executable_path().get_base_dir()
	else:
		return ProjectSettings.globalize_path("res://")

static func get_all_supported_platforms() -> Array[Dictionary]:
	return [
		{"id": "snes", "name": "Super Nintendo (SNES)", "ext": [".sfc", ".smc", ".zip", ".7z"], "emulator": "snes9x"},
		{"id": "nes", "name": "Nintendo (NES)", "ext": [".nes", ".zip"], "emulator": "mesen"},
		{"id": "genesis", "name": "Sega Genesis / Mega Drive", "ext": [".md", ".smd", ".gen", ".zip"], "emulator": "blastem"},
		{"id": "gba", "name": "Game Boy Advance (GBA)", "ext": [".gba", ".zip"], "emulator": "mgba"},
		{"id": "arcade", "name": "Arcade Hardware", "ext": [".zip", ".7z"], "emulator": "mame"},
		{"id": "ps1", "name": "Sony PlayStation 1", "ext": [".iso", ".cue", ".chd", ".m3u"], "emulator": "duckstation"},
		{"id": "n64", "name": "Nintendo 64", "ext": [".n64", ".z64", ".v64"], "emulator": "mupen64plus"},
		{"id": "gb", "name": "Game Boy", "ext": [".gb", ".zip"], "emulator": "sameboy"},
		{"id": "gbc", "name": "Game Boy Color", "ext": [".gbc", ".zip"], "emulator": "sameboy"},
		{"id": "ds", "name": "Nintendo DS", "ext": [".nds", ".zip"], "emulator": "melonds"},
		{"id": "gamecube", "name": "Nintendo GameCube", "ext": [".iso", ".gcz", ".rvz"], "emulator": "dolphin"},
		{"id": "ps2", "name": "Sony PlayStation 2", "ext": [".iso", ".chd"], "emulator": "pcsx2"},
		{"id": "ps3", "name": "Sony PlayStation 3", "ext": [".pkg", ".iso"], "emulator": "rpcs3"},
		{"id": "switch", "name": "Nintendo Switch", "ext": [".nsp", ".xci"], "emulator": "yuzu"},
		{"id": "psp", "name": "PlayStation Portable", "ext": [".iso", ".cso"], "emulator": "ppsspp"},
		{"id": "saturn", "name": "Sega Saturn", "ext": [".iso", ".cue", ".chd"], "emulator": "mednafen"},
		{"id": "dreamcast", "name": "Sega Dreamcast", "ext": [".cdi", ".gdi", ".chd"], "emulator": "flycast"},
		{"id": "atari2600", "name": "Atari 2600", "ext": [".a26", ".bin"], "emulator": "stella"},
		{"id": "neogeo", "name": "SNK Neo Geo", "ext": [".zip"], "emulator": "fbneo"},
		{"id": "pcengine", "name": "TurboGrafx-16 / PC Engine", "ext": [".pce", ".zip"], "emulator": "mednafen"},
		{"id": "mastersystem", "name": "Sega Master System", "ext": [".sms", ".zip"], "emulator": "genesisplusgx"},
		{"id": "gamegear", "name": "Sega Game Gear", "ext": [".gg", ".zip"], "emulator": "genesisplusgx"},
		{"id": "c64", "name": "Commodore 64", "ext": [".d64", ".t64", ".prg"], "emulator": "vice"},
		{"id": "amiga", "name": "Commodore Amiga", "ext": [".adf", ".lha"], "emulator": "winuae"},
		{"id": "atarist", "name": "Atari ST", "ext": [".st", ".msa"], "emulator": "hatari"},
		{"id": "atari5200", "name": "Atari 5200", "ext": [".bin", ".a52"], "emulator": "atari800"},
		{"id": "atari7800", "name": "Atari 7800", "ext": [".a78", ".bin"], "emulator": "prosystem"},
		{"id": "msx", "name": "MSX Home Computer", "ext": [".rom", ".dsk"], "emulator": "openmsx"},
		{"id": "spectrum", "name": "ZX Spectrum", "ext": [".tzx", ".tap", ".z80"], "emulator": "fuse"},
		{"id": "apple2", "name": "Apple II", "ext": [".dsk", ".do"], "emulator": "linapple"},
		{"id": "coleco", "name": "ColecoVision", "ext": [".col", ".bin"], "emulator": "colem"},
		{"id": "intellivision", "name": "Intellivision", "ext": [".int", ".bin"], "emulator": "jzintv"},
		{"id": "wonder-swan", "name": "Bandai WonderSwan", "ext": [".ws", ".wsc"], "emulator": "mednafen"}
	]

func ensure_directories_exist() -> Array[String]:
	var paths: Array[String] = []
	var base = get_base_dir()
	var roms_root = base.path_join("roms")
	var emulators_root = base.path_join("emulators")

	DirAccess.make_dir_recursive_absolute(roms_root)
	DirAccess.make_dir_recursive_absolute(emulators_root)

	# 1. Create emulators subfolders
	for plat in get_all_supported_platforms():
		var emu_name = plat.get("emulator", plat["id"])
		var emu_path = emulators_root.path_join(emu_name)
		DirAccess.make_dir_recursive_absolute(emu_path)

	# Always ensure retroarch subfolder exists
	DirAccess.make_dir_recursive_absolute(emulators_root.path_join("retroarch"))

	# 2. Create roms subfolders
	for plat in get_all_supported_platforms():
		var dir_path = roms_root.path_join(plat["id"])
		DirAccess.make_dir_recursive_absolute(dir_path)
		paths.append(dir_path)

	return paths
