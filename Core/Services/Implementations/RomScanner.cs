using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Interfaces;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// High-performance asynchronous background ROM Scanner.
/// Uses System.Threading.Channels to stream discovered game files to the Godot UI without frame drops.
/// Automatically detects Standalone, RetroArch, and Classic Vintage Computer / Console systems.
/// </summary>
public class RomScanner : IRomScanner
{
    public ChannelReader<GameRom> ScanDirectoryAsync(
        IEnumerable<string> directoryPaths,
        IReadOnlyList<string> supportedExtensions,
        CancellationToken cancellationToken = default)
    {
        var channel = Channel.CreateUnbounded<GameRom>(new UnboundedChannelOptions
        {
            SingleWriter = true,
            SingleReader = true
        });

        _ = Task.Run(async () =>
        {
            try
            {
                var extensionSet = new HashSet<string>(supportedExtensions, StringComparer.OrdinalIgnoreCase);

                foreach (string rootPath in directoryPaths)
                {
                    if (!Directory.Exists(rootPath)) continue;

                    var enumerationOptions = new EnumerationOptions
                    {
                        RecurseSubdirectories = true,
                        IgnoreInaccessible = true,
                        AttributesToSkip = FileAttributes.Hidden | FileAttributes.System
                    };

                    IEnumerable<string> files = Directory.EnumerateFiles(rootPath, "*.*", enumerationOptions);

                    foreach (string filePath in files)
                    {
                        cancellationToken.ThrowIfCancellationRequested();

                        string ext = Path.GetExtension(filePath);
                        if (extensionSet.Contains(ext) && !filePath.EndsWith("README.txt", StringComparison.OrdinalIgnoreCase))
                        {
                            FileInfo fileInfo = new(filePath);
                            PlatformType platform = InferPlatformFromPathOrExtension(filePath);

                            var gameRom = new GameRom
                            {
                                Title = CleanTitleFromFilename(Path.GetFileNameWithoutExtension(filePath)),
                                FilePath = filePath,
                                Platform = platform,
                                FileSizeBytes = fileInfo.Length,
                                ActiveExecutionMode = DetermineDefaultExecutionMode(platform)
                            };

                            await channel.Writer.WriteAsync(gameRom, cancellationToken);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                channel.Writer.Complete(ex);
                return;
            }

            channel.Writer.Complete();
        }, cancellationToken);

        return channel.Reader;
    }

    private static ExecutionMode DetermineDefaultExecutionMode(PlatformType platform) => platform switch
    {
        PlatformType.GameCube => ExecutionMode.Standalone,
        PlatformType.PlayStation2 => ExecutionMode.Standalone,
        PlatformType.PlayStation3 => ExecutionMode.Standalone,
        PlatformType.NintendoSwitch => ExecutionMode.Standalone,
        _ => ExecutionMode.LibretroCore // Classic retro platforms default to Libretro cores
    };

    private static PlatformType InferPlatformFromPathOrExtension(string filePath)
    {
        string pathLower = filePath.ToLowerInvariant();
        string ext = Path.GetExtension(filePath).ToLowerInvariant();

        // Modern Standalone Systems
        if (pathLower.Contains("gamecube")) return PlatformType.GameCube;
        if (pathLower.Contains("playstation2") || pathLower.Contains("ps2")) return PlatformType.PlayStation2;
        if (pathLower.Contains("playstation3") || pathLower.Contains("ps3")) return PlatformType.PlayStation3;
        if (pathLower.Contains("switch")) return PlatformType.NintendoSwitch;

        // Classic Computers & Vintage Consoles
        if (pathLower.Contains("commodore64") || pathLower.Contains(@"\c64\") || ext is ".d64" or ".t64" or ".crt" or ".prg") return PlatformType.Commodore64;
        if (pathLower.Contains("amiga") || ext is ".adf" or ".hdf" or ".lha" or ".ipf") return PlatformType.CommodoreAmiga;
        if (pathLower.Contains("atarist") || ext is ".st" or ".stx" or ".msa") return PlatformType.AtariST;
        if (pathLower.Contains("atari5200") || ext == ".a52") return PlatformType.Atari5200;
        if (pathLower.Contains("atari7800") || ext == ".a78") return PlatformType.Atari7800;
        if (pathLower.Contains("msx") || ext is ".mx1" or ".mx2") return PlatformType.MSX;
        if (pathLower.Contains("zxspectrum") || ext is ".tzx" or ".z80" or ".sna") return PlatformType.ZXSpectrum;
        if (pathLower.Contains("appleii") || ext is ".do" or ".po" or ".nib") return PlatformType.AppleII;
        if (pathLower.Contains("colecovision") || ext == ".col") return PlatformType.ColecoVision;
        if (pathLower.Contains("intellivision") || ext == ".int") return PlatformType.Intellivision;
        if (pathLower.Contains("virtualboy") || ext is ".vb" or ".vboy") return PlatformType.VirtualBoy;
        if (pathLower.Contains("wonderswan") || ext is ".ws" or ".wsc") return PlatformType.WonderSwan;
        if (pathLower.Contains("segacd")) return PlatformType.SegaCD;
        if (pathLower.Contains("sega32x") || ext == ".32x") return PlatformType.Sega32X;

        // Standard Retro Consoles
        if (pathLower.Contains("playstation1") || pathLower.Contains("ps1") || pathLower.Contains("psx")) return PlatformType.PlayStation1;
        if (pathLower.Contains("n64") || pathLower.Contains("nintendo64")) return PlatformType.Nintendo64;
        if (pathLower.Contains("gameboycolor") || ext == ".gbc") return PlatformType.GameBoyColor;
        if (pathLower.Contains("gameboyadvance") || pathLower.Contains(@"\gba\") || ext == ".gba") return PlatformType.GameBoyAdvance;
        if (pathLower.Contains("gameboy") || ext == ".gb") return PlatformType.GameBoy;
        if (pathLower.Contains("nds") || pathLower.Contains("nintendods") || ext == ".nds") return PlatformType.NintendoDS;
        if (pathLower.Contains("3ds") || ext == ".3ds" || ext == ".cia") return PlatformType.Nintendo3DS;
        if (pathLower.Contains("psp") || pathLower.Contains("playstationportable")) return PlatformType.PlayStationPortable;
        if (pathLower.Contains("saturn")) return PlatformType.SegaSaturn;
        if (pathLower.Contains("dreamcast")) return PlatformType.SegaDreamcast;
        if (pathLower.Contains("atari2600") || ext == ".a26") return PlatformType.Atari2600;
        if (pathLower.Contains("neogeo") || ext == ".neo") return PlatformType.NeoGeo;
        if (pathLower.Contains("pcengine") || ext == ".pce") return PlatformType.PCEngine;
        if (pathLower.Contains("mastersystem") || ext == ".sms") return PlatformType.MasterSystem;
        if (pathLower.Contains("gamegear") || ext == ".gg") return PlatformType.GameGear;
        if (pathLower.Contains("snes") || ext == ".sfc" || ext == ".smc") return PlatformType.SNES;
        if (pathLower.Contains("nes") || ext == ".nes") return PlatformType.NES;
        if (pathLower.Contains("genesis") || ext == ".md" || ext == ".smd") return PlatformType.Genesis;
        if (pathLower.Contains("arcade")) return PlatformType.Arcade;

        return PlatformType.SNES;
    }

    private static string CleanTitleFromFilename(string filename)
    {
        string clean = System.Text.RegularExpressions.Regex.Replace(filename, @"\s*[\(\[].*?[\)\]]", "");
        return clean.Trim();
    }
}
