# 3DRetro

**Windows desktop emulation frontend built with Godot 4.7 and GDScript**

3DRetro scans your ROM folders, shows your library in several gamepad-friendly views, and launches games through RetroArch or standalone emulators.

---

## Features

- **5 interface views** (switch with the view selector or LB / RB on a controller):
  - **🖥️ Classic 3-Column Desktop**: grid with a category sidebar and a detail pane.
  - **📺 Couch Big Picture TV**: 10-foot hero view with a horizontal game row.
  - **📋 Minimalist Compact List**: sortable table of title, platform, developer, year and playtime.
  - **🏎️ Vertical Wheel**: curved wheel of games with a detail card.
  - **🏛️ Console Showcase**: browse by system.

- **ROM library**:
  - Creates a `roms/<platform>` folder for each of 33 systems next to the app and scans them using each system's file extensions.
  - Open a single ROM or scan any extra folder from the File menu.
  - Favorites, play counts, last played and playtime are kept across restarts in `3dretro_database.json` (next to the app, or in Godot's `user://` folder if that isn't writable).
  - Export and import the library database as JSON.

- **Launching**:
  - Uses RetroArch (`emulators/retroarch/retroarch.exe` plus the core in `emulators/retroarch/cores/`) when available, otherwise a standalone emulator under `emulators/<name>/`.
  - Tracks the running emulator to record playtime and pause background music during play.

- **Smart collections**: All Games, Favorites, Recently Played, Never Played, 2-Player, Party (4P+), Arcade Classics, plus title-based playlists.

- **Gamepad**:
  - Auto-detects controllers and focuses the UI. Input mode can be Auto-Detect, Gamepad or Keyboard & Mouse.
  - A: launch · B: Console Showcase · X: scrape selected game · Y: favorite selected game · LB/RB: switch view · Start: menu · Back: hotkey guide.

- **Customization**: built-in color themes and skins, custom color picker.

### Not finished yet

- The metadata scraper fills in placeholder values; it doesn't download real metadata or artwork.
- Per-system settings (aspect ratio, shader, bezel, extra args) aren't saved or passed to emulators yet.
- RetroAchievements shows sample badges, and the video snap panel shows cover art only (no video playback).
- Background music has no soundtrack loaded.

---

## Getting Started

### Prerequisites

- [Godot Engine 4.7](https://godotengine.org/download) (standard build, no .NET needed)

### Run

```bash
git clone https://github.com/vampyer/3DRetro.git
cd 3DRetro
godot --path .
```

Or open `project.godot` in the Godot editor and press Play. Running from the editor creates `roms/`, `emulators/` and the database inside the project folder; these are git-ignored.

### Export

Use the **Windows Desktop** export preset (`build/3DRetro.exe`).

---

## License

MIT License.
