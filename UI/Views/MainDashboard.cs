using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EmulationMenu.Core.Data;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Implementations;
using EmulationMenu.Core.Services.Interfaces;
using EmulationMenu.UI.Components;
using EmulationMenu.UI.Services;
using Godot;

using HttpClient = System.Net.Http.HttpClient;

namespace EmulationMenu.UI.Views;

/// <summary>
/// Main Godot 4.7 Control View integrating Sidebar Navigation, 2D Virtualized Grid,
/// 3D Carousel Cover Wall, Couch Big Picture TV View, Minimalist List View, Color Customizer, Services, and ViewModels.
/// </summary>
public partial class MainDashboard : Control
{
    private ProgressBar _downloadProgressBar = null!;
    private Label _statusLabel = null!;
    private OptionButton _interfaceModelSelector = null!;
    private SortingControlBar _sortingBar = null!;
    
    private SidebarCategoryNav _sidebarNav = null!;
    private VirtualGameGrid _gameGrid2D = null!;
    private GameGrid3D _gameGrid3D = null!;
    private CouchBigPictureView _couchBigPictureView = null!;
    private MinimalistListView _minimalistListView = null!;
    private GameDetailPanel _detailPanel = null!;
    private EmulatorSelectionModal _selectionModal = null!;
    private ColorPickerModal _colorPickerModal = null!;
    private SystemConfigModal _systemConfigModal = null!;
    private Control _gridContainer = null!;

    private HttpClient _httpClient = null!;
    private IEmulatorDownloader _downloader = null!;
    private IEmulatorLauncher _launcher = null!;
    private DatabaseContext _db = null!;
    private IRomScanner _romScanner = null!;
    private RomDirectoryManager _romDirectoryManager = null!;
    private RetroArchInstallerService _retroArchInstaller = null!;
    private PreinstallBootstrapper _bootstrapper = null!;
    private GameMetadataScraperService _metadataScraper = null!;

    // RetroBat Services
    private SystemConfigOverrideManager _sysConfigManager = null!;
    private BezelDecorationManager _bezelManager = null!;
    private AutoControllerConfigEngine _padConfigEngine = null!;
    private CollectionManager _collectionManager = null!;
    private BackgroundMusicPlayer _bgmPlayer = null!;


    private readonly List<GameRom> _allScannedGames = [];
    private List<GameRom> _currentlyDisplayedGames = [];
    private readonly Dictionary<string, GameRom> _loadedGames = [];
    private CancellationTokenSource? _scanCts;
    private InterfaceModel _currentInterfaceModel = InterfaceModel.ClassicDesktop;

    public override void _Ready()
    {
        InitializeServices();
        InitializeUIComponents();

        _ = BootAndLoadAsync();
    }

    private void InitializeServices()
    {
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string retroArchPath = System.IO.Path.Combine(baseDir, "App", "RetroArch");

        _httpClient = new HttpClient();
        _downloader = new EmulatorDownloader(_httpClient);
        _launcher = new EmulatorLauncher();
        _db = new DatabaseContext();
        _romScanner = new RomScanner();
        _romDirectoryManager = new RomDirectoryManager();
        _retroArchInstaller = new RetroArchInstallerService(_httpClient);
        _bootstrapper = new PreinstallBootstrapper(_retroArchInstaller, _downloader, _romDirectoryManager);
        _metadataScraper = new GameMetadataScraperService(_httpClient, _db);

        // RetroBat Features Services
        _sysConfigManager = new SystemConfigOverrideManager(baseDir);
        _bezelManager = new BezelDecorationManager(baseDir);
        _padConfigEngine = new AutoControllerConfigEngine(retroArchPath);
        _collectionManager = new CollectionManager();
        _bgmPlayer = new BackgroundMusicPlayer();
        AddChild(_bgmPlayer);

        // Auto-detect and configure connected controllers on boot
        _padConfigEngine.SynchronizeControllerConfigs();

        _launcher.GameExited += OnGameExited;
    }


    private void InitializeUIComponents()
    {
        var rootVBox = new VBoxContainer
        {
            AnchorRight = 1.0f,
            AnchorBottom = 1.0f
        };
        AddChild(rootVBox);

        // Header Bar
        var statusContainer = new HBoxContainer();
        _statusLabel = new Label { Text = "Initializing Emulation Engine...", SizeFlagsHorizontal = SizeFlags.ExpandFill };
        _downloadProgressBar = new ProgressBar { Visible = true, CustomMinimumSize = new Vector2(250, 20) };
        
        _interfaceModelSelector = new OptionButton
        {
            CustomMinimumSize = new Vector2(220, 30),
            FocusMode = FocusModeEnum.All
        };
        _interfaceModelSelector.AddItem("🖥️ Classic 3-Column Desktop", (int)InterfaceModel.ClassicDesktop);
        _interfaceModelSelector.AddItem("📺 Couch Big Picture TV", (int)InterfaceModel.CouchBigPicture);
        _interfaceModelSelector.AddItem("📋 Minimalist Compact List", (int)InterfaceModel.MinimalistList);
        _interfaceModelSelector.AddItem("🎲 3D Arcade Carousel", (int)InterfaceModel.Arcade3DCarousel);
        _interfaceModelSelector.ItemSelected += (index) => SwitchInterfaceModel((InterfaceModel)index);

        statusContainer.AddChild(_statusLabel);
        statusContainer.AddChild(_downloadProgressBar);
        statusContainer.AddChild(_interfaceModelSelector);
        rootVBox.AddChild(statusContainer);

        // Toolbar
        _sortingBar = new SortingControlBar();
        _sortingBar.Connect(SortingControlBar.SignalName.SortModeChanged, Callable.From<int>(OnSortModeChanged));
        _sortingBar.Connect(SortingControlBar.SignalName.CardDensityChanged, Callable.From<int>(OnCardDensityChanged));
        _sortingBar.Connect(SortingControlBar.SignalName.UIThemeModeChanged, Callable.From<int>(OnThemeChanged));
        _sortingBar.Connect(SortingControlBar.SignalName.CustomColorPickerRequested, Callable.From(OnCustomColorPickerRequested));
        rootVBox.AddChild(_sortingBar);

        // Body Layout
        var bodyHBox = new HBoxContainer
        {
            SizeFlagsVertical = SizeFlags.ExpandFill,
            SizeFlagsHorizontal = SizeFlags.ExpandFill
        };
        rootVBox.AddChild(bodyHBox);

        _sidebarNav = new SidebarCategoryNav();
        _sidebarNav.Connect(SidebarCategoryNav.SignalName.CategorySelected, Callable.From<string>(OnCategorySelected));
        _sidebarNav.Connect(SidebarCategoryNav.SignalName.SearchTextChanged, Callable.From<string>(OnSearchTextChanged));
        bodyHBox.AddChild(_sidebarNav);

        _gridContainer = new Control
        {
            SizeFlagsVertical = SizeFlags.ExpandFill,
            SizeFlagsHorizontal = SizeFlags.ExpandFill
        };
        bodyHBox.AddChild(_gridContainer);

        _gameGrid2D = new VirtualGameGrid
        {
            SizeFlagsVertical = SizeFlags.ExpandFill,
            SizeFlagsHorizontal = SizeFlags.ExpandFill
        };
        _gameGrid2D.Connect(VirtualGameGrid.SignalName.GameSelected, Callable.From<string>(OnGameSelected));
        _gridContainer.AddChild(_gameGrid2D);

        var viewportContainer = new SubViewportContainer
        {
            AnchorRight = 1.0f,
            AnchorBottom = 1.0f,
            Stretch = true,
            Visible = false
        };
        _gridContainer.AddChild(viewportContainer);

        var viewport = new SubViewport();
        viewportContainer.AddChild(viewport);

        _gameGrid3D = new GameGrid3D();
        _gameGrid3D.Connect(GameGrid3D.SignalName.GameSelected3D, Callable.From<string>(OnGameSelected));
        viewport.AddChild(_gameGrid3D);

        _couchBigPictureView = new CouchBigPictureView { Visible = false };
        _couchBigPictureView.Connect(CouchBigPictureView.SignalName.BigPictureGameSelected, Callable.From<string>(OnGameSelected));
        _couchBigPictureView.Connect(CouchBigPictureView.SignalName.BigPictureLaunchRequested, Callable.From<string>(OnGameLaunchRequested));
        _gridContainer.AddChild(_couchBigPictureView);

        _minimalistListView = new MinimalistListView { Visible = false };
        _minimalistListView.Connect(MinimalistListView.SignalName.ListGameSelected, Callable.From<string>(OnGameSelected));
        _minimalistListView.Connect(MinimalistListView.SignalName.ListGameActivated, Callable.From<string>(OnGameLaunchRequested));
        _gridContainer.AddChild(_minimalistListView);

        _detailPanel = new GameDetailPanel();
        _detailPanel.Connect(GameDetailPanel.SignalName.LaunchRequested, Callable.From<string>(OnGameLaunchRequested));
        _detailPanel.Connect(GameDetailPanel.SignalName.FavoriteToggled, Callable.From<string>(OnFavoriteToggled));
        _detailPanel.Connect(GameDetailPanel.SignalName.MetadataDownloadRequested, Callable.From<string>(OnMetadataDownloadRequested));
        bodyHBox.AddChild(_detailPanel);

        // Selection Modal, Color Picker Modal, and RetroBat System Config Modal
        _selectionModal = new EmulatorSelectionModal();
        AddChild(_selectionModal);

        _colorPickerModal = new ColorPickerModal();
        _colorPickerModal.Connect(ColorPickerModal.SignalName.CustomColorsApplied, Callable.From<Color, Color, Color, Color>(OnCustomColorsApplied));
        AddChild(_colorPickerModal);

        _systemConfigModal = new SystemConfigModal(_sysConfigManager);
        AddChild(_systemConfigModal);

        _sortingBar.Connect(SortingControlBar.SignalName.SystemConfigRequested, Callable.From(OnSystemConfigRequested));
        _sortingBar.Connect(SortingControlBar.SignalName.BGMToggled, Callable.From(OnBGMToggled));
    }

    private void OnSystemConfigRequested()
    {
        _systemConfigModal.OpenForPlatform(PlatformType.SNES);
    }

    private void OnBGMToggled()
    {
        _bgmPlayer.ToggleMute();
        _statusLabel.Text = _bgmPlayer.IsMuted ? "🔇 Background Music Muted" : "🎵 Background Music Active";
    }


    private void SwitchInterfaceModel(InterfaceModel model)
    {
        _currentInterfaceModel = model;

        _sidebarNav.Visible = (model == InterfaceModel.ClassicDesktop || model == InterfaceModel.MinimalistList);
        _detailPanel.Visible = (model == InterfaceModel.ClassicDesktop || model == InterfaceModel.Arcade3DCarousel || model == InterfaceModel.MinimalistList);

        _gameGrid2D.Visible = (model == InterfaceModel.ClassicDesktop);
        _gameGrid3D.Visible = (model == InterfaceModel.Arcade3DCarousel);
        _couchBigPictureView.Visible = (model == InterfaceModel.CouchBigPicture);
        _minimalistListView.Visible = (model == InterfaceModel.MinimalistList);
    }

    private void OnSortModeChanged(int sortIndex)
    {
        SortMode mode = (SortMode)sortIndex;
        IEnumerable<GameRom> sorted = mode switch
        {
            SortMode.TitleAscending => _currentlyDisplayedGames.OrderBy(g => g.Title),
            SortMode.TitleDescending => _currentlyDisplayedGames.OrderByDescending(g => g.Title),
            SortMode.ReleaseYearNewest => _currentlyDisplayedGames.OrderByDescending(g => g.ReleaseYear ?? 0),
            SortMode.PlaytimeMostPlayed => _currentlyDisplayedGames.OrderByDescending(g => g.TotalPlayTime),
            SortMode.PlayCountHighest => _currentlyDisplayedGames.OrderByDescending(g => g.PlayCount),
            _ => _currentlyDisplayedGames
        };

        UpdateDisplayedList(sorted.ToList());
    }

    private void OnCardDensityChanged(int densityIndex)
    {
        CardDensity density = (CardDensity)densityIndex;
        Vector2 size = density switch
        {
            CardDensity.Small => new Vector2(120, 160),
            CardDensity.Medium => new Vector2(180, 240),
            CardDensity.Large => new Vector2(240, 320),
            _ => new Vector2(180, 240)
        };

        _gameGrid2D.SetCardSize(size);
    }

    private void OnThemeChanged(int themeIndex)
    {
        ThemeManager.ApplyTheme(this, (UIThemeMode)themeIndex);
    }

    private void OnCustomColorPickerRequested()
    {
        var currentColors = ThemeManager.GetThemeColors(UIThemeMode.CyberpunkDark);
        _colorPickerModal.OpenCustomizer(currentColors.BackgroundColor, currentColors.SurfaceColor, currentColors.AccentColor, currentColors.TextColor);
    }

    private void OnCustomColorsApplied(Color bg, Color surface, Color accent, Color text)
    {
        SelfModulate = bg;
        _sidebarNav.SelfModulate = surface;
        _detailPanel.SelfModulate = surface;
        _statusLabel.SelfModulate = text;
        _statusLabel.Text = "Custom interface colors applied.";
    }

    private async Task BootAndLoadAsync()
    {
        _scanCts = new CancellationTokenSource();

        Progress<DownloadProgressReport> bootProgress = new(report =>
        {
            Callable.From(() =>
            {
                _downloadProgressBar.Visible = true;
                _downloadProgressBar.Value = report.ProgressPercentage;
                _statusLabel.Text = report.StatusMessage;
            }).CallDeferred();
        });

        try
        {
            await _bootstrapper.RunPreinstallBootSequenceAsync(bootProgress, _scanCts.Token);
            _downloadProgressBar.Visible = false;

            _statusLabel.Text = "Scanning ROM directories...";
            IReadOnlyList<string> scanPaths = _romDirectoryManager.EnsureSupportedDirectoriesExist();
            string[] extensions = [".iso", ".gcz", ".rvz", ".sfc", ".smc", ".gba", ".nes", ".md", ".smd", ".nsp", ".xci", ".pkg", ".zip", ".7z"];

            System.Threading.Channels.ChannelReader<GameRom> channelReader = 
                _romScanner.ScanDirectoryAsync(scanPaths, extensions, _scanCts.Token);

            _allScannedGames.Clear();
            await foreach (GameRom game in channelReader.ReadAllAsync(_scanCts.Token))
            {
                _db.SaveGame(game);
                _loadedGames[game.Id] = game;
                _allScannedGames.Add(game);
            }

            _statusLabel.Text = $"3DRetro Ready. Found {_allScannedGames.Count} games across {scanPaths.Count} platform folders.";

            UpdateDisplayedList(_allScannedGames);
        }
        catch (Exception ex)
        {
            _statusLabel.Text = $"Boot Error: {ex.Message}";
            _downloadProgressBar.Visible = false;
        }
    }

    private void UpdateDisplayedList(List<GameRom> list)
    {
        _currentlyDisplayedGames = list;
        Callable.From(() =>
        {
            _gameGrid2D.SetGames(list);
            _gameGrid3D.SetGames(list);
            _couchBigPictureView.SetGames(list);
            _minimalistListView.SetGames(list);
        }).CallDeferred();
    }

    private void OnCategorySelected(string category)
    {
        IEnumerable<GameRom> filtered;

        if (category == "⭐ Favorites") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.FavoritesId);
        else if (category == "🕒 Recently Played") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.RecentlyPlayedId);
        else if (category == "🎮 All Games") filtered = _allScannedGames;
        else if (category == "🆕 Never Played") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.NeverPlayedId);
        else if (category == "👥 2-Player (2P+)") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.Multiplayer2PId);
        else if (category == "🎉 Party Games (4P+)") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.Party4PId);
        else if (category == "🕹️ Arcade Classics") filtered = _collectionManager.FilterByCollection(_allScannedGames, CollectionManager.ArcadeClassicsId);
        else if (category.StartsWith("📁 "))
        {
            string playlistName = category.Replace("📁 ", "");
            filtered = _collectionManager.FilterByCollection(_allScannedGames, $"custom_{playlistName.ToLowerInvariant()}");
        }
        else
        {
            var info = RomDirectoryManager.GetAllSupportedPlatforms().FirstOrDefault(p => p.SystemDisplayName == category);
            filtered = info != null ? _allScannedGames.Where(g => g.Platform == info.Platform) : _allScannedGames;
        }

        UpdateDisplayedList(filtered.ToList());
    }


    private void OnSearchTextChanged(string text)
    {
        IEnumerable<GameRom> matches = string.IsNullOrWhiteSpace(text)
            ? _allScannedGames
            : _allScannedGames.Where(g => g.Title.Contains(text, StringComparison.OrdinalIgnoreCase));

        UpdateDisplayedList(matches.ToList());
    }

    private void OnGameSelected(string gameId)
    {
        if (_loadedGames.TryGetValue(gameId, out GameRom? game))
        {
            _detailPanel.DisplayGameDetails(game);
        }
    }

    private void OnFavoriteToggled(string gameId)
    {
        _db.ToggleFavorite(gameId);
        if (_loadedGames.TryGetValue(gameId, out GameRom? game))
        {
            game.IsFavorite = !game.IsFavorite;
            _detailPanel.DisplayGameDetails(game);
        }
    }

    private async void OnMetadataDownloadRequested(string gameId)
    {
        if (!_loadedGames.TryGetValue(gameId, out GameRom? game)) return;

        Progress<string> statusProgress = new(msg =>
        {
            Callable.From(() =>
            {
                _statusLabel.Text = msg;
            }).CallDeferred();
        });

        try
        {
            GameRom enriched = await _metadataScraper.DownloadMetadataForGameAsync(game, statusProgress, CancellationToken.None);
            _loadedGames[gameId] = enriched;
            
            Callable.From(() =>
            {
                _detailPanel.DisplayGameDetails(enriched);
            }).CallDeferred();
        }
        catch (Exception ex)
        {
            _statusLabel.Text = $"Metadata scrape error: {ex.Message}";
        }
    }

    private async void OnGameLaunchRequested(string gameId)
    {
        if (!_loadedGames.TryGetValue(gameId, out GameRom? game)) return;

        _statusLabel.Text = $"Checking emulator setup for {game.Platform}...";

        EmulatorDefinition baseDefinition = EmulatorRegistry.GetDefinitionOrDefault(game.Platform);
        ExecutionMode preferredMode = _db.GetExecutionModeForPlatform(game.Platform);

        string targetDir = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Emulators", game.Platform.ToString());
        string expectedExe = System.IO.Path.Combine(targetDir, baseDefinition.StandaloneExePath ?? $"{baseDefinition.DisplayName}.exe");
        string expectedCore = System.IO.Path.Combine(targetDir, $"{baseDefinition.LibretroCoreName}.dll");

        bool hasStandalone = System.IO.File.Exists(expectedExe);
        bool hasCore = System.IO.File.Exists(expectedCore);

        if (!hasStandalone && !hasCore)
        {
            _statusLabel.Text = "Prompting for emulator selection...";
            preferredMode = await _selectionModal.PromptUserChoiceAsync(game.Platform);
            _db.SetExecutionModeForPlatform(game.Platform, preferredMode);
        }

        game.ActiveExecutionMode = preferredMode;
        EmulatorDefinition targetConfig = baseDefinition with { PreferredMode = preferredMode };

        Progress<DownloadProgressReport> progress = new(report =>
        {
            Callable.From(() =>
            {
                _downloadProgressBar.Visible = true;
                _downloadProgressBar.Value = report.ProgressPercentage;
                _statusLabel.Text = report.StatusMessage;
            }).CallDeferred();
        });

        try
        {
            if (preferredMode == ExecutionMode.LibretroCore)
            {
                _statusLabel.Text = "Ensuring RetroArch backend is installed...";
                await _retroArchInstaller.EnsureRetroArchInstalledAsync(progress, CancellationToken.None);
            }

            await _downloader.EnsureEmulatorInstalledAsync(targetConfig, progress, CancellationToken.None);

            _downloadProgressBar.Visible = false;
            _statusLabel.Text = $"Launching {game.Title}...";

            // RetroBat: Pause menu BGM and sync gamepads & bezels
            _bgmPlayer.PauseForGameLaunch();
            _padConfigEngine.SynchronizeControllerConfigs();

            string retroArchPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "RetroArch");
            bool launched = await _launcher.LaunchGameAsync(game, targetConfig, retroArchPath);

            if (!launched)
            {
                _statusLabel.Text = $"Failed to launch {game.Title}.";
                _bgmPlayer.ResumeAfterGameExit();
            }
        }
        catch (Exception ex)
        {
            _statusLabel.Text = $"Error: {ex.Message}";
            _downloadProgressBar.Visible = false;
            _bgmPlayer.ResumeAfterGameExit();
        }
    }

    private void OnGameExited(object? sender, TimeSpan playSessionTime)
    {
        _statusLabel.Text = $"Game session ended. Played for {playSessionTime.TotalMinutes:F1} minutes.";
        _bgmPlayer.ResumeAfterGameExit();
    }


    public override void _ExitTree()
    {
        _scanCts?.Cancel();
        _scanCts?.Dispose();
        _httpClient.Dispose();
        _db.Dispose();
    }
}
