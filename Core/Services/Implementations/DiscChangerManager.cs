using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Service managing multi-disc / multi-cartridge games (e.g. PS1, GameCube, Saturn multi-disc titles).
/// Automatically detects multi-disc series files and generates .m3u playlist files for seamless disc swapping.
/// </summary>
public class DiscChangerManager
{
    /// <summary>
    /// Scans a directory for multi-disc titles matching Disc 1/2/3/4 patterns and generates an .m3u playlist file.
    /// Returns the path to the primary .m3u playlist file.
    /// </summary>
    public string EnsureMultiDiscPlaylistExists(string primaryDiscFilePath)
    {
        string directory = Path.GetDirectoryName(primaryDiscFilePath) ?? string.Empty;
        string filename = Path.GetFileNameWithoutExtension(primaryDiscFilePath);
        string extension = Path.GetExtension(primaryDiscFilePath);

        // Check if file indicates multi-disc (e.g. "Disc 1", "CD 1", "Disk 1")
        if (!System.Text.RegularExpressions.Regex.IsMatch(filename, @"(?i)(disc|cd|disk)\s*[1-9]"))
        {
            return primaryDiscFilePath; // Single disc title
        }

        // Base game title stripping disc number
        string baseGameTitle = System.Text.RegularExpressions.Regex.Replace(filename, @"(?i)\s*\((disc|cd|disk)\s*[1-9]\)", "").Trim();
        string m3uFilePath = Path.Combine(directory, $"{baseGameTitle}.m3u");

        if (File.Exists(m3uFilePath))
        {
            return m3uFilePath;
        }

        // Discover all disc files for this game title
        var siblingFiles = Directory.GetFiles(directory, $"*{baseGameTitle}*{extension}")
            .OrderBy(f => f)
            .ToList();

        if (siblingFiles.Count > 1)
        {
            List<string> relativePaths = siblingFiles.Select(Path.GetFileName).Where(f => f != null).Cast<string>().ToList();
            File.WriteAllLines(m3uFilePath, relativePaths);
            return m3uFilePath;
        }

        return primaryDiscFilePath;
    }
}
