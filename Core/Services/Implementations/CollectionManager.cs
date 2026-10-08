using System;
using System.Collections.Generic;
using System.Linq;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;

namespace EmulationMenu.Core.Services.Implementations;

public record CollectionItem(string Id, string DisplayName, string IconName, bool IsSmartCollection);

/// <summary>
/// RetroBat Collection and Dynamic Playlist Manager.
/// Provides filter routines for Smart Collections (Favorites, Recent, Never Played, 2-Player, 4-Player, Arcade Classics)
/// and User-defined Custom Playlists (e.g., "Mario", "Zelda", "RPGs").
/// </summary>
public class CollectionManager
{
    public const string AllGamesId = "all_games";
    public const string FavoritesId = "favorites";
    public const string RecentlyPlayedId = "recently_played";
    public const string NeverPlayedId = "never_played";
    public const string Multiplayer2PId = "multiplayer_2p";
    public const string Party4PId = "party_4p";
    public const string ArcadeClassicsId = "arcade_classics";

    private readonly List<string> _customCollectionNames = new()
    {
        "Mario Franchise",
        "Zelda Series",
        "Final Fantasy",
        "Beat 'em Ups",
        "Fighting Games"
    };

    public IReadOnlyList<CollectionItem> GetSmartCollections()
    {
        return new List<CollectionItem>
        {
            new(AllGamesId, "All Games", "🎮", true),
            new(FavoritesId, "Favorites", "⭐", true),
            new(RecentlyPlayedId, "Recently Played", "🕒", true),
            new(NeverPlayedId, "Never Played", "🆕", true),
            new(Multiplayer2PId, "2-Player (2P+)", "👥", true),
            new(Party4PId, "Party Games (4P+)", "🎉", true),
            new(ArcadeClassicsId, "Arcade Classics", "🕹️", true),
        };
    }

    public IReadOnlyList<CollectionItem> GetCustomCollections()
    {
        return _customCollectionNames
            .Select(name => new CollectionItem($"custom_{name.ToLowerInvariant().Replace(' ', '_')}", name, "📁", false))
            .ToList();
    }

    /// <summary>
    /// Filters a master list of ROMs based on the selected collection ID.
    /// </summary>
    public IEnumerable<GameRom> FilterByCollection(IEnumerable<GameRom> roms, string collectionId)
    {
        return collectionId switch
        {
            AllGamesId => roms,
            FavoritesId => roms.Where(r => r.IsFavorite),
            RecentlyPlayedId => roms.Where(r => r.PlayCount > 0).OrderByDescending(r => r.LastPlayed),
            NeverPlayedId => roms.Where(r => r.PlayCount == 0),
            Multiplayer2PId => roms.Where(r => r.MaxPlayers >= 2),
            Party4PId => roms.Where(r => r.MaxPlayers >= 4),
            ArcadeClassicsId => roms.Where(r => r.Platform == PlatformType.Arcade || r.Platform == PlatformType.NeoGeo),

            _ => FilterCustomCollection(roms, collectionId)
        };
    }

    private IEnumerable<GameRom> FilterCustomCollection(IEnumerable<GameRom> roms, string collectionId)
    {
        string rawName = collectionId.Replace("custom_", "").Replace('_', ' ');
        return roms.Where(r => 
            r.CustomCollections.Any(c => c.Equals(rawName, StringComparison.OrdinalIgnoreCase)) ||
            r.Title.Contains(rawName, StringComparison.OrdinalIgnoreCase));
    }

    public void AddCustomCollection(string collectionName)
    {
        if (!string.IsNullOrWhiteSpace(collectionName) && !_customCollectionNames.Contains(collectionName))
        {
            _customCollectionNames.Add(collectionName);
        }
    }
}
