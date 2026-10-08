using System;
using System.Collections.Generic;
using System.Linq;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using LiteDB;

namespace EmulationMenu.Core.Data;

/// <summary>
/// Embedded LiteDB Context managing Platform configuration, Emulator mappings, ROM library, and Playtime analytics.
/// Provides high-performance indexing for 10,000+ games.
/// </summary>
public class DatabaseContext : IDisposable
{
    private readonly LiteDatabase _db;

    public ILiteCollection<GameRom> Games => _db.GetCollection<GameRom>("games");
    public ILiteCollection<PlatformConfigEntity> Platforms => _db.GetCollection<PlatformConfigEntity>("platforms");

    public DatabaseContext(string? databasePath = null)
    {
        string path = databasePath ?? System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "emulation_data.db");
        _db = new LiteDatabase($"Filename={path};Connection=Shared");

        ConfigureIndexes();
    }

    private void ConfigureIndexes()
    {
        Games.EnsureIndex(x => x.Title);
        Games.EnsureIndex(x => x.Platform);
        Games.EnsureIndex(x => x.IsFavorite);
        Games.EnsureIndex(x => x.LastPlayed);
        Games.EnsureIndex(x => x.FilePath, unique: true);

        Platforms.EnsureIndex(x => x.TargetPlatform, unique: true);
    }

    public void SaveGame(GameRom game)
    {
        Games.Upsert(game);
    }

    public IEnumerable<GameRom> GetGamesByPlatform(PlatformType platform)
    {
        return Games.Find(x => x.Platform == platform);
    }

    public IEnumerable<GameRom> GetFavorites()
    {
        return Games.Find(x => x.IsFavorite);
    }

    public IEnumerable<GameRom> GetRecentlyPlayed(int limit = 20)
    {
        return Games.Query()
            .Where(x => x.LastPlayed > DateTime.MinValue)
            .OrderByDescending(x => x.LastPlayed)
            .Limit(limit)
            .ToEnumerable();
    }

    public void ToggleFavorite(string gameId)
    {
        var game = Games.FindById(gameId);
        if (game != null)
        {
            game.IsFavorite = !game.IsFavorite;
            Games.Update(game);
        }
    }

    public void RecordPlaySession(string gameId, TimeSpan sessionTime)
    {
        var game = Games.FindById(gameId);
        if (game != null)
        {
            game.PlayCount++;
            game.LastPlayed = DateTime.Now;
            game.TotalPlayTime += sessionTime;
            Games.Update(game);
        }
    }

    public ExecutionMode GetExecutionModeForPlatform(PlatformType platform)
    {
        var config = Platforms.FindOne(x => x.TargetPlatform == platform);
        return config?.SelectedMode ?? ExecutionMode.Standalone;
    }

    public void SetExecutionModeForPlatform(PlatformType platform, ExecutionMode mode)
    {
        var config = Platforms.FindOne(x => x.TargetPlatform == platform) 
            ?? new PlatformConfigEntity { TargetPlatform = platform };

        config.SelectedMode = mode;
        Platforms.Upsert(config);
    }

    public void Dispose()
    {
        _db.Dispose();
        GC.SuppressFinalize(this);
    }
}

/// <summary>
/// Database Entity mapping Platform to selected ExecutionMode (Standalone vs LibretroCore).
/// </summary>
public class PlatformConfigEntity
{
    public ObjectId Id { get; set; } = ObjectId.NewObjectId();
    public PlatformType TargetPlatform { get; set; }
    public ExecutionMode SelectedMode { get; set; } = ExecutionMode.Standalone;
    public string? ActiveEmulatorId { get; set; }
}
