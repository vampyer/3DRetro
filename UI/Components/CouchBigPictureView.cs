using System;
using System.Collections.Generic;
using EmulationMenu.Core.Models;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Couch Big Picture Interface Model for TV / Handheld / Gamepad navigation.
/// Displays large horizontal hero cards, background blur art, and 10-foot gamepad controls.
/// </summary>
public partial class CouchBigPictureView : Control
{
    [Signal]
    public delegate void BigPictureGameSelectedEventHandler(string gameId);

    [Signal]
    public delegate void BigPictureLaunchRequestedEventHandler(string gameId);

    private TextureRect _backgroundImage = null!;
    private Label _heroTitleLabel = null!;
    private Label _heroPlatformLabel = null!;
    private Button _heroPlayButton = null!;
    private HBoxContainer _horizontalCardsContainer = null!;

    private readonly List<GameRom> _games = [];
    private int _focusedIndex = 0;

    public override void _Ready()
    {
        AnchorRight = 1.0f;
        AnchorBottom = 1.0f;

        // Background Hero Art
        _backgroundImage = new TextureRect
        {
            AnchorRight = 1.0f,
            AnchorBottom = 1.0f,
            ExpandMode = TextureRect.ExpandModeEnum.IgnoreSize,
            StretchMode = TextureRect.StretchModeEnum.KeepAspectCovered,
            Modulate = new Color(0.3f, 0.3f, 0.35f, 0.6f)
        };
        AddChild(_backgroundImage);

        var mainVBox = new VBoxContainer
        {
            AnchorRight = 1.0f,
            AnchorBottom = 1.0f
        };
        AddChild(mainVBox);

        mainVBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 40) });

        // Hero Banner Information
        var heroMargin = new MarginContainer();
        heroMargin.AddThemeConstantOverride("margin_left", 60);
        heroMargin.AddThemeConstantOverride("margin_right", 60);
        mainVBox.AddChild(heroMargin);

        var heroVBox = new VBoxContainer();
        heroMargin.AddChild(heroVBox);

        _heroTitleLabel = new Label
        {
            Text = "SELECT A GAME",
            AutowrapMode = TextServer.AutowrapMode.WordSmart
        };
        _heroTitleLabel.AddThemeFontSizeOverride("font_size", 42);
        heroVBox.AddChild(_heroTitleLabel);

        _heroPlatformLabel = new Label { Text = "PRESS A TO LAUNCH" };
        _heroPlatformLabel.AddThemeFontSizeOverride("font_size", 20);
        heroVBox.AddChild(_heroPlatformLabel);

        heroVBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 16) });

        _heroPlayButton = new Button
        {
            Text = "▶ START GAME SESSION",
            CustomMinimumSize = new Vector2(280, 56),
            FocusMode = FocusModeEnum.All
        };
        _heroPlayButton.AddThemeFontSizeOverride("font_size", 20);
        _heroPlayButton.Pressed += () =>
        {
            if (_games.Count > 0 && _focusedIndex >= 0 && _focusedIndex < _games.Count)
            {
                EmitSignal(SignalName.BigPictureLaunchRequested, _games[_focusedIndex].Id);
            }
        };
        heroVBox.AddChild(_heroPlayButton);

        mainVBox.AddChild(new Control { SizeFlagsVertical = SizeFlags.ExpandFill });

        // Bottom Horizontal Game Row
        var scroll = new ScrollContainer
        {
            CustomMinimumSize = new Vector2(0, 260),
            VerticalScrollMode = ScrollContainer.ScrollMode.Disabled
        };
        mainVBox.AddChild(scroll);

        _horizontalCardsContainer = new HBoxContainer();
        _horizontalCardsContainer.AddThemeConstantOverride("separation", 20);
        scroll.AddChild(_horizontalCardsContainer);
    }

    public void SetGames(IEnumerable<GameRom> games)
    {
        foreach (Node child in _horizontalCardsContainer.GetChildren())
        {
            child.QueueFree();
        }

        _games.Clear();
        _games.AddRange(games);
        _focusedIndex = 0;

        for (int i = 0; i < _games.Count; i++)
        {
            int index = i;
            var game = _games[i];

            var cardBtn = new Button
            {
                CustomMinimumSize = new Vector2(160, 220),
                Text = game.Title,
                FocusMode = FocusModeEnum.All
            };

            cardBtn.FocusEntered += () => OnCardFocus(index);
            cardBtn.Pressed += () => EmitSignal(SignalName.BigPictureLaunchRequested, game.Id);

            _horizontalCardsContainer.AddChild(cardBtn);
        }

        if (_games.Count > 0) UpdateHeroDisplay(_games[0]);
    }

    private void OnCardFocus(int index)
    {
        _focusedIndex = index;
        if (_focusedIndex >= 0 && _focusedIndex < _games.Count)
        {
            var game = _games[_focusedIndex];
            UpdateHeroDisplay(game);
            EmitSignal(SignalName.BigPictureGameSelected, game.Id);
        }
    }

    private void UpdateHeroDisplay(GameRom game)
    {
        _heroTitleLabel.Text = game.Title.ToUpper();
        _heroPlatformLabel.Text = $"{game.Platform} • PLAYTIME: {game.TotalPlayTime.TotalMinutes:F0} MINS";

        if (!string.IsNullOrEmpty(game.CoverArtPath) && System.IO.File.Exists(game.CoverArtPath))
        {
            try
            {
                var img = Image.LoadFromFile(game.CoverArtPath);
                if (img != null) _backgroundImage.Texture = ImageTexture.CreateFromImage(img);
            }
            catch (Exception ex)
            {
                GD.PrintErr($"Hero background load error: {ex.Message}");
            }
        }
    }
}
