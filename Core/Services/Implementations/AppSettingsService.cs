using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Configuration Settings Model for the 3DRetro Emulation Frontend.
/// </summary>

public class AppSettings
{
    public List<string> RomDirectoryPaths { get; set; } = [Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ROMS")];
    public string RetroArchBasePath { get; set; } = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "RetroArch");
    public string ScreenScraperDevId { get; set; } = "demo";
    public string ScreenScraperDevPassword { get; set; } = "demo";
    public bool AutoScanOnStartup { get; set; } = true;
    public bool EnableGlobalExitHotkey { get; set; } = true;
    public string HotkeyCombination { get; set; } = "Select+Start";
}

/// <summary>
/// JSON Configuration Service for loading and persisting application settings.
/// </summary>
public class AppSettingsService
{
    private readonly string _settingsPath;
    public AppSettings Current { get; private set; }

    public AppSettingsService(string? customPath = null)
    {
        _settingsPath = customPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "settings.json");
        Current = LoadSettings();
    }

    public AppSettings LoadSettings()
    {
        if (File.Exists(_settingsPath))
        {
            try
            {
                string json = File.ReadAllText(_settingsPath);
                return JsonSerializer.Deserialize<AppSettings>(json) ?? new AppSettings();
            }
            catch (Exception ex)
            {
                Godot.GD.PrintErr($"Failed to load settings.json: {ex.Message}");
            }
        }

        var defaults = new AppSettings();
        SaveSettings(defaults);
        return defaults;
    }

    public void SaveSettings(AppSettings settings)
    {
        Current = settings;
        string dir = Path.GetDirectoryName(_settingsPath) ?? string.Empty;
        if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);

        string json = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(_settingsPath, json);
    }
}
