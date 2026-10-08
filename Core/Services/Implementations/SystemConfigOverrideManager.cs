using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using Godot;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Persistence and Management service for RetroBat System & Per-Game Overrides.
/// Saves and loads platform settings (Aspect Ratios, Bezels, Shaders, Preferred Emulator Mode)
/// to JSON storage in App/system_configs.json.
/// </summary>
public class SystemConfigOverrideManager
{
    private readonly string _configFilePath;
    private readonly Dictionary<PlatformType, SystemConfigOverride> _configs = new();

    public SystemConfigOverrideManager(string baseDir)
    {
        _configFilePath = Path.Combine(baseDir, "App", "system_configs.json");
        LoadConfigs();
    }

    private void LoadConfigs()
    {
        if (File.Exists(_configFilePath))
        {
            try
            {
                string json = File.ReadAllText(_configFilePath);
                var loaded = JsonSerializer.Deserialize<Dictionary<string, SystemConfigOverride>>(json);
                if (loaded != null)
                {
                    foreach (var kvp in loaded)
                    {
                        if (Enum.TryParse<PlatformType>(kvp.Key, out var platform))
                        {
                            _configs[platform] = kvp.Value;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                GD.PrintErr($"Failed to load system configs: {ex.Message}");
            }
        }

        // Fill missing defaults
        foreach (PlatformType platform in Enum.GetValues<PlatformType>())
        {
            if (!_configs.ContainsKey(platform))
            {
                _configs[platform] = new SystemConfigOverride
                {
                    TargetPlatform = platform,
                    PreferredMode = ExecutionMode.Standalone,
                    AspectRatio = GetDefaultAspectRatio(platform),
                    BezelStyle = "ConsoleThemed",
                    ShaderPreset = "CRT-Scanlines"
                };
            }
        }
    }

    private string GetDefaultAspectRatio(PlatformType platform) => platform switch
    {
        PlatformType.GameBoy or PlatformType.GameBoyColor or PlatformType.GameBoyAdvance => "Auto",
        PlatformType.PlayStationPortable => "16:9",

        _ => "4:3"
    };

    public SystemConfigOverride GetSystemConfig(PlatformType platform)
    {
        return _configs.TryGetValue(platform, out var cfg) ? cfg : new SystemConfigOverride { TargetPlatform = platform };
    }

    public void SaveSystemConfig(SystemConfigOverride config)
    {
        _configs[config.TargetPlatform] = config;
        SaveAll();
    }

    private void SaveAll()
    {
        try
        {
            string dir = Path.GetDirectoryName(_configFilePath)!;
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            var exportDict = new Dictionary<string, SystemConfigOverride>();
            foreach (var kvp in _configs)
            {
                exportDict[kvp.Key.ToString()] = kvp.Value;
            }

            string json = JsonSerializer.Serialize(exportDict, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(_configFilePath, json);
        }
        catch (Exception ex)
        {
            GD.PrintErr($"Failed to save system configs: {ex.Message}");
        }
    }
}
