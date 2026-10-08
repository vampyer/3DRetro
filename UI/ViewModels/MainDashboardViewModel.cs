using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Data;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Implementations;
using EmulationMenu.Core.Services.Interfaces;

namespace EmulationMenu.UI.ViewModels;

/// <summary>
/// Main Dashboard View Model implementing MVVM pattern for Godot 4.7.
/// Decouples all business logic, process execution, and async channel operations from Godot Control nodes.
/// </summary>
public class MainDashboardViewModel : INotifyPropertyChanged
{
    private readonly IEmulatorDownloader _downloader;
    private readonly IEmulatorLauncher _launcher;
    private readonly IRomScanner _scanner;
    private readonly ArchiveRomManager _archiveManager;
    private readonly RomDirectoryManager _directoryManager;
    private readonly DatabaseContext _db;

    private string _statusText = "Ready";
    private bool _isDownloading;
    private double _downloadProgress;
    private PlatformType _selectedPlatform = PlatformType.SNES;

    public event PropertyChangedEventHandler? PropertyChanged;

    public ObservableCollection<GameRom> FilteredGames { get; } = [];

    public string StatusText
    {
        get => _statusText;
        set => SetProperty(ref _statusText, value);
    }

    public bool IsDownloading
    {
        get => _isDownloading;
        set => SetProperty(ref _isDownloading, value);
    }

    public double DownloadProgress
    {
        get => _downloadProgress;
        set => SetProperty(ref _downloadProgress, value);
    }

    public PlatformType SelectedPlatform
    {
        get => _selectedPlatform;
        set
        {
            if (SetProperty(ref _selectedPlatform, value))
            {
                RefreshPlatformGames();
            }
        }
    }

    public MainDashboardViewModel(
        IEmulatorDownloader downloader,
        IEmulatorLauncher launcher,
        IRomScanner scanner,
        ArchiveRomManager archiveManager,
        RomDirectoryManager directoryManager,
        DatabaseContext db)
    {
        _downloader = downloader;
        _launcher = launcher;
        _scanner = scanner;
        _archiveManager = archiveManager;
        _directoryManager = directoryManager;
        _db = db;

        _launcher.GameExited += OnGameExited;

        // Auto-build all supported ROM directories on startup
        _directoryManager.EnsureSupportedDirectoriesExist();
    }

    public async Task ScanDirectoriesAsync(CancellationToken cancellationToken)
    {
        StatusText = "Checking ROM directories...";
        var scanPaths = _directoryManager.EnsureSupportedDirectoriesExist();

        StatusText = "Scanning ROM files...";
        List<string> extensions = [".iso", ".gcz", ".rvz", ".sfc", ".smc", ".gba", ".nes", ".md", ".smd", ".nsp", ".xci", ".pkg", ".zip", ".7z"];

        var channel = _scanner.ScanDirectoryAsync(scanPaths, extensions, cancellationToken);

        int count = 0;
        await foreach (GameRom rom in channel.ReadAllAsync(cancellationToken))
        {
            _db.SaveGame(rom);
            count++;
        }

        StatusText = $"Scan complete. {count} total ROMs indexed across {scanPaths.Count} platform folders.";
        RefreshPlatformGames();
    }

    public async Task LaunchGameSessionAsync(GameRom game, EmulatorDefinition emulatorConfig, string retroArchPath)
    {
        try
        {
            StatusText = $"Preparing emulator for {game.Title}...";

            var progress = new Progress<DownloadProgressReport>(report =>
            {
                IsDownloading = true;
                DownloadProgress = report.ProgressPercentage;
                StatusText = report.StatusMessage;
            });

            // Ensure emulator binary/core is installed
            await _downloader.EnsureEmulatorInstalledAsync(emulatorConfig, progress);
            IsDownloading = false;

            // Extract ROM if inside archive (.7z, .zip)
            StatusText = "Checking ROM format...";
            string playablePath = await _archiveManager.PrepareRomForLaunchAsync(game.FilePath);
            
            GameRom targetRom = new()
            {
                Id = game.Id,
                Title = game.Title,
                FilePath = playablePath,
                Platform = game.Platform,
                ActiveExecutionMode = game.ActiveExecutionMode
            };

            StatusText = $"Launching {game.Title}...";
            bool success = await _launcher.LaunchGameAsync(targetRom, emulatorConfig, retroArchPath);

            if (!success)
            {
                StatusText = $"Failed to start emulator for {game.Title}.";
            }
        }
        catch (Exception ex)
        {
            StatusText = $"Launch Error: {ex.Message}";
            IsDownloading = false;
        }
    }

    private void RefreshPlatformGames()
    {
        FilteredGames.Clear();
        foreach (var game in _db.GetGamesByPlatform(SelectedPlatform))
        {
            FilteredGames.Add(game);
        }
    }

    private void OnGameExited(object? sender, TimeSpan playSessionTime)
    {
        StatusText = $"Session finished. Played for {playSessionTime.TotalMinutes:F1} minutes.";
    }

    protected bool SetProperty<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (Equals(field, value)) return false;
        field = value;
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        return true;
    }
}
