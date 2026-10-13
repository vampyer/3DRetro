class_name EmulatorLaunchEngine
extends RefCounted

## Automated Emulator Command-Line Builder & Game Launcher Engine.
## Matches platforms to retroarch cores or standalone emulators in relative paths.

static func build_launch_command(game: Dictionary) -> Dictionary:
	var platform = str(game.get("platform", "snes")).to_lower()
	# Scanned games store their path in "file_path"; "rom_path" is kept for older entries
	var rom_path = game.get("file_path", game.get("rom_path", ""))
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
	var core_path = emu_dir.path_join("retroarch/cores").path_join(ra_cores.get(platform, ""))
	if FileAccess.file_exists(ra_exe) and ra_cores.has(platform) and FileAccess.file_exists(core_path):
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

## Returns {"pid": int, "error": String}. pid is -1 when nothing was started,
## and 0 when the game was opened through the shell without a process to track.
static func launch_game(game: Dictionary) -> Dictionary:
	var cmd = build_launch_command(game)
	var exe = cmd["executable"]
	var args = cmd["args"]
	var rom_path = game.get("file_path", game.get("rom_path", ""))

	if rom_path == "" or not FileAccess.file_exists(rom_path):
		return {"pid": -1, "error": "ROM file not found" + (": " + rom_path if rom_path != "" else "")}
	if not FileAccess.file_exists(exe):
		return {"pid": -1, "error": "No emulator found for " + str(game.get("platform", "")).to_upper() + ". Add RetroArch or a standalone emulator under emulators/"}
	if not OS.has_feature("windows"):
		print("[EmulatorLaunchEngine] Simulating launch for: ", game.get("title", "Game"), " -> ", exe, " ", args)
		return {"pid": -1, "error": "Launching emulators is only supported on Windows"}

	# Shortcuts and scripts (.lnk/.url/.bat) can't be spawned directly; hand them to the shell (no PID to track)
	if cmd["type"] == "native_pc" and exe.get_extension().to_lower() != "exe":
		if OS.shell_open(exe) != OK:
			return {"pid": -1, "error": "Failed to open " + exe.get_file()}
		return {"pid": 0, "error": ""}

	var pid = OS.create_process(exe, PackedStringArray(args))
	if pid == -1:
		return {"pid": -1, "error": "Failed to start " + exe.get_file()}
	return {"pid": pid, "error": ""}
