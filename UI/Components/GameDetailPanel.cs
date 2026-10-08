using System;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Implementations;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Side detail panel in Godot 4.7 displaying boxart media, rich synopsis metadata text,
/// developer info, community rating, RetroAchievements stats, and action buttons.
/// </summary>
public partial class GameDetailPanel : PanelContainer
{
    [Signal]
    public delegate void LaunchRequestedEventHandler(string gameId);

    [Signal]
    public delegate void FavoriteToggledEventHandler(string gameId);

    [Signal]
    public delegate void MetadataDownloadRequestedEventHandler(string gameId);

    private TextureRect _coverArtTexture = null!;
    private VideoSnapPlayer _videoSnapPlayer = null!;
    private Label _titleLabel = null!;
    private Label _platformLabel = null!;
    private Label _developerLabel = null!;
    private Label _genreRatingLabel = null!;
    private RichTextLabel _descriptionText = null!;
    private Label _playtimeLabel = null!;
    private Label _playCountLabel = null!;
    private Label _achievementsLabel = null!;
    private Label _saveStateLabel = null!;

    private Button _playButton = null!;
    private Button _favoriteButton = null!;
    private Button _scrapeMetadataButton = null!;

    private GameRom? _currentGame;

    public override void _Ready()
    {
        CustomMinimumSize = new Vector2(380, 0);

        var marginContainer = new MarginContainer();
        marginContainer.AddThemeConstantOverride("margin_top", 16);
        marginContainer.AddThemeConstantOverride("margin_bottom", 16);
        marginContainer.AddThemeConstantOverride("margin_left", 16);
        marginContainer.AddThemeConstantOverride("margin_right", 16);
        AddChild(marginContainer);

        var scrollContainer = new ScrollContainer
        {
            SizeFlagsVertical = SizeFlags.ExpandFill,
            HorizontalScrollMode = ScrollContainer.ScrollMode.Disabled
        };
        marginContainer.AddChild(scrollContainer);

        var vBox = new VBoxContainer();
        scrollContainer.AddChild(vBox);

        // Video Snap Trailer & Artwork Stack
        _videoSnapPlayer = new VideoSnapPlayer();
        vBox.AddChild(_videoSnapPlayer);

        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 10) });

        _titleLabel = new Label
        {
            Text = "Select a Game",
            HorizontalAlignment = HorizontalAlignment.Center,
            AutowrapMode = TextServer.AutowrapMode.WordSmart
        };

        _titleLabel.AddThemeFontSizeOverride("font_size", 22);
        vBox.AddChild(_titleLabel);

        _platformLabel = new Label
        {
            Text = "Platform: --",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        vBox.AddChild(_platformLabel);

        _developerLabel = new Label
        {
            Text = "Developer: --",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        vBox.AddChild(_developerLabel);

        _genreRatingLabel = new Label
        {
            Text = "Genre: -- | Rating: ★★★★★",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        vBox.AddChild(_genreRatingLabel);

        vBox.AddChild(new HSeparator());

        // Synopsis Description Box
        var descHeader = new Label { Text = "Game Overview:" };
        descHeader.AddThemeFontSizeOverride("font_size", 14);
        vBox.AddChild(descHeader);

        _descriptionText = new RichTextLabel
        {
            CustomMinimumSize = new Vector2(0, 120),
            BbcodeEnabled = true,
            Text = "Select a game from the grid to view its metadata.",
            FitContent = false
        };
        vBox.AddChild(_descriptionText);

        vBox.AddChild(new HSeparator());

        _playtimeLabel = new Label { Text = "Total Playtime: 0 mins" };
        _playCountLabel = new Label { Text = "Times Played: 0" };
        _achievementsLabel = new Label { Text = "🏆 RetroAchievements: 2 / 4 Unlocked (35 Pts)" };

        vBox.AddChild(_playtimeLabel);
        vBox.AddChild(_playCountLabel);
        vBox.AddChild(_achievementsLabel);

        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 16) });

        // Action Buttons
        _playButton = new Button
        {
            Text = "▶ Play Game",
            CustomMinimumSize = new Vector2(0, 48),
            FocusMode = FocusModeEnum.All
        };
        _playButton.Pressed += () =>
        {
            if (_currentGame != null) EmitSignal(SignalName.LaunchRequested, _currentGame.Id);
        };

        _favoriteButton = new Button
        {
            Text = "★ Favorite",
            CustomMinimumSize = new Vector2(0, 38),
            FocusMode = FocusModeEnum.All
        };
        _favoriteButton.Pressed += () =>
        {
            if (_currentGame != null) EmitSignal(SignalName.FavoriteToggled, _currentGame.Id);
        };

        _scrapeMetadataButton = new Button
        {
            Text = "📥 Download Game Metadata",
            CustomMinimumSize = new Vector2(0, 38),
            FocusMode = FocusModeEnum.All
        };
        _scrapeMetadataButton.Pressed += () =>
        {
            if (_currentGame != null) EmitSignal(SignalName.MetadataDownloadRequested, _currentGame.Id);
        };

        vBox.AddChild(_playButton);
        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 6) });
        vBox.AddChild(_favoriteButton);
        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 6) });
        vBox.AddChild(_scrapeMetadataButton);
    }

    public void DisplayGameDetails(GameRom game)
    {
        _currentGame = game;
        _titleLabel.Text = game.Title;
        _platformLabel.Text = $"Platform: {game.Platform}";
        _developerLabel.Text = $"Developer: {game.Developer ?? "Unknown"} ({game.ReleaseYear?.ToString() ?? "N/A"})";
        
        string stars = game.CommunityRating.HasValue 
            ? new string('★', (int)Math.Round(game.CommunityRating.Value)) 
            : "★★★★☆";

        _genreRatingLabel.Text = $"Genre: {game.Genre ?? "Classic"} | Rating: {stars}";
        _descriptionText.Text = game.Description ?? "No description available. Click 'Download Game Metadata' below to scrape info.";

        _playtimeLabel.Text = $"Total Playtime: {game.TotalPlayTime.TotalMinutes:F1} mins";
        _playCountLabel.Text = $"Times Played: {game.PlayCount}";
        _favoriteButton.Text = game.IsFavorite ? "★ Favorited" : "☆ Add to Favorites";

        _videoSnapPlayer.LoadGamePreview(game);
    }


    public void DisplayAchievements(UserAchievementSummary summary)
    {
        _achievementsLabel.Text = $"🏆 RetroAchievements: {summary.TotalUnlocked} / {summary.TotalAchievements} Unlocked ({summary.TotalPoints} Pts)";
    }
}
