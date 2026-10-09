class_name EmulatorLaunchEngine
extends RefCounted

## Automated Emulator Command-Line Builder & Game Launcher Engine.
## Matches platforms to retroarch cores or standalone emulators in relative paths.

static func build_launch_command(game: Dictionary) -> Dictionary:
	var platform = str(game.get("platform", "snes")).to_lower()
	var rom_path = game.get("rom_path", "")
	var base_dir = RomDirectoryManager.get_base_dir()
	var emu_dir = base_dir.path_join("emulators")

	# PC / Steam Games
	if platform == "pc" or platform == "steam":
		return {
			"executable": rom_path if rom_path != "" else "cmd.exe",
			"args": [],
			"type": "native_pc"
		}

	# Platform to RetroArch core map
	var ra_cores = {
		"snes": "snes9x_libretro.dll",
		"nes": "mesen_libretro.dll",
		"genesis": "genesis_plus_gx_libretro.dll",
		"gba": "mgba_libretro.dll",
		"arcade": "mame_libretro.dll",
		"ps1": "beetle_psx_hw_libretro.dll",
		"n64": "mupen64plus_next_libretro.dll",
		"gb": "sameboy_libretro.dll",
		"gbc": "sameboy_libretro.dll",
		"ds": "melonds_libretro.dll",
		"gamecube": "dolphin_libretro.dll",
		"ps2": "pcsx2_libretro.dll",
		"psp": "ppsspp_libretro.dll"
	}

	var ra_exe = emu_dir.path_join("retroarch/retroarch.exe")
	if FileAccess.file_exists(ra_exe) and ra_cores.has(platform):
		var core_path = emu_dir.path_join("retroarch/cores").path_join(ra_cores[platform])
		return {
			"executable": ra_exe,
			"args": ["-L", core_path, rom_path, "-f"],
			"type": "retroarch"
		}

	# Fallback to standalone emulator executable path
	var default_emu_names = {
		"snes": "snes9x/snes9x.exe",
		"nes": "mesen/mesen.exe",
		"genesis": "blastem/blastem.exe",
		"gba": "mgba/mgba.exe",
		"arcade": "mame/mame.exe",
		"ps1": "duckstation/duckstation-qt.exe",
		"n64": "mupen64plus/mupen64plus.exe",
		"gamecube": "dolphin/dolphin.exe",
		"ps2": "pcsx2/pcsx2-qt.exe",
		"psp": "ppsspp/PPSSPPWindows64.exe"
	}

	var emu_subpath = default_emu_names.get(platform, platform + "/" + platform + ".exe")
	var standalone_exe = emu_dir.path_join(emu_subpath)

	return {
		"executable": standalone_exe if FileAccess.file_exists(standalone_exe) else "cmd.exe",
		"args": [rom_path] if rom_path != "" else [],
		"type": "standalone"
	}

static func launch_game(game: Dictionary) -> int:
	var cmd = build_launch_command(game)
	var exe = cmd["executable"]
	var args = cmd["args"]

	if OS.has_feature("windows") and FileAccess.file_exists(exe):
		return OS.create_process(exe, PackedStringArray(args))
	else:
		print("[EmulatorLaunchEngine] Simulating launch for: ", game.get("title", "Game"), " -> ", exe, " ", args)
		return 0
