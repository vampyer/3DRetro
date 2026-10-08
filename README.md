# 3DRetro

**High-Performance Windows Desktop Emulation Frontend built with Godot 4.7 .NET, C# 12, and .NET 8**

3DRetro is a modern, high-performance desktop emulation frontend designed for Windows. It provides a locked 60+ FPS user interface, decoupled MVVM architecture, automatic emulator installation, and multiple UI presentation views (including a 3D arcade carousel).

---

## Key Features

- **4 UI Interface Models**:
  - **🖥️ Classic 3-Column Desktop View**: Grid view with left navigation sidebar and rich detail pane.
  - **📺 Couch Big Picture TV Mode**: 10-foot console interface designed for gamepads and TV setups.
  - **📋 Minimalist Compact List View**: High-density tabular list for instant sorting across large libraries.
  - **🕹️ 3D Arcade Carousel View**: Immersive 3D curved cover wall with studio lighting and dynamic camera.

- **System & Emulator Configuration**:
  - Hybrid downloader supporting Standalone Windows executables and Libretro `.dll` cores.
  - Automatic RetroArch runtime deployment and auto-generation of 33 platform ROM directories.
  - Aspect ratio switching (4:3, 16:9, Integer Scale), console artwork bezels, and CRT scanline shaders.

- **Smart Collections & Custom Playlists**:
  - Built-in smart filters: Favorites, Recently Played, Never Played, 2-Player (2P+), Party Games (4P+), and Arcade Classics.
  - User custom collections (e.g. "Mario Franchise", "Zelda Series", "RPGs").

- **Gamepad Autoconfig & Emergency Hotkeys**:
  - Automatic detection and mapping for Xbox, PlayStation, and Nintendo Switch Pro controllers.
  - Emergency escape hotkeys (`Alt + Esc` / `Select + Start`).

- **Rich Scraped Metadata & Video Snap Previews**:
  - Scrapes boxart, logos, developers, release years, community ratings, and game synopses.
  - Embedded gameplay video trailer player with hover delays.
  - RetroAchievements integration for trophies and hardcore points.

- **Interactive UI Customization**:
  - Built-in color themes (Cyberpunk Dark, Synthwave Retro, Modern Clean Dark, Clean Light).
  - Custom RGBA color picker dialog for personalization.

---

## Tech Stack & Architecture

- **Engine**: Godot 4.7 .NET / C# 12
- **Runtime**: .NET 8 (`net8.0-windows`)
- **Database**: LiteDB
- **Concurrency**: `System.Threading.Channels` for non-blocking background ROM scanning
- **Process Management**: Win32 P/Invoke (`user32.dll`), `Stopwatch` playtime tracking

---

## Getting Started

### Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Godot Engine 4.4 / 4.7 (.NET / C# Version)](https://godotengine.org/download)

### Build & Run

```bash
# Clone repository
git clone https://github.com/vampyer/3DRetro.git
cd 3DRetro

# Build C# project
dotnet build

# Launch via Godot CLI or Godot Editor
godot --path . res://UI/Views/MainDashboard.cs
```

---

## License

MIT License.
