using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using EmulationMenu.Core.Models;

namespace EmulationMenu.Core.Services.Implementations;

public record SaveStateInfo(string FilePath, DateTime CreatedAt, long FileSizeBytes, bool IsBatterySave);

/// <summary>
/// Service managing game battery saves (.srm), save state files, and in-game screenshots.
/// Automatically creates isolated save directories per platform and game.
/// </summary>
public class SaveStateManager
{
    private readonly string _savesBaseDirectory;

    public SaveStateManager(string? customSavesDir = null)
    {
        _savesBaseDirectory = customSavesDir ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Saves");
        Directory.CreateDirectory(_savesBaseDirectory);
    }

    /// <summary>
    /// Returns the dedicated save folder path for a specific game and platform.
    /// Creates the directory automatically if missing.
    /// </summary>
    public string GetSaveDirectoryForGame(GameRom rom)
    {
        string safeTitle = string.Concat(rom.Title.Split(Path.GetInvalidFileNameChars()));
        string path = Path.Combine(_savesBaseDirectory, rom.Platform.ToString(), safeTitle);
        Directory.CreateDirectory(path);
        return path;
    }

    /// <summary>
    /// Lists all save state files (.state, .srm, .s01) associated with a game.
    /// </summary>
    public IEnumerable<SaveStateInfo> GetSaveStatesForGame(GameRom rom)
    {
        string dir = GetSaveDirectoryForGame(rom);
        if (!Directory.Exists(dir)) return Enumerable.Empty<SaveStateInfo>();

        var files = Directory.GetFiles(dir, "*.*")
            .Where(f => f.EndsWith(".srm") || f.EndsWith(".state") || f.EndsWith(".s01") || f.EndsWith(".sav"));

        return files.Select(f =>
        {
            var fi = new FileInfo(f);
            return new SaveStateInfo(f, fi.LastWriteTime, fi.Length, f.EndsWith(".srm") || f.EndsWith(".sav"));
        }).OrderByDescending(s => s.CreatedAt);
    }

    /// <summary>
    /// Backs up a battery save (.srm / .sav) prior to game launch to prevent save corruption.
    /// </summary>
    public void BackupBatterySave(GameRom rom)
    {
        string dir = GetSaveDirectoryForGame(rom);
        string[] saveFiles = Directory.GetFiles(dir, "*.srm").Concat(Directory.GetFiles(dir, "*.sav")).ToArray();

        foreach (string file in saveFiles)
        {
            string backupPath = $"{file}.bak_{DateTime.Now:yyyyMMdd_HHmmss}";
            File.Copy(file, backupPath, overwrite: true);
        }
    }
}
