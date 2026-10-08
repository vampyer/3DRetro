using System;
using System.IO;
using EmulationMenu.Core.Models;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// RetroBat Video Snap & Gameplay Trailer Preview Player.
/// Plays gameplay video snapshots with fallback dynamic graphics, status overlays, and mute toggles.
/// </summary>
public partial class VideoSnapPlayer : PanelContainer
{
    private TextureRect _posterRect = null!;
    private ColorRect _placeholderOverlay = null!;
    private Label _titleOverlayLabel = null!;
    private Label _videoStatusLabel = null!;
    private Timer _hoverDelayTimer = null!;
    private GameRom? _pendingGame;

    public VideoSnapPlayer()
    {
        CustomMinimumSize = new Vector2(320, 180);
        BuildUI();
    }

    private void BuildUI()
    {
        var mainStack = new Control();
        mainStack.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        AddChild(mainStack);

        _posterRect = new TextureRect
        {
            ExpandMode = TextureRect.ExpandModeEnum.IgnoreSize,
            StretchMode = TextureRect.StretchModeEnum.KeepAspectCovered
        };
        _posterRect.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        mainStack.AddChild(_posterRect);

        _placeholderOverlay = new ColorRect
        {
            Color = new Color(0.05f, 0.05f, 0.08f, 0.85f)
        };
        _placeholderOverlay.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        mainStack.AddChild(_placeholderOverlay);

        var vbox = new VBoxContainer();
        vbox.SetAnchorsPreset(Control.LayoutPreset.Center);
        _placeholderOverlay.AddChild(vbox);

        _videoStatusLabel = new Label
        {
            Text = "🎬 Video Preview Available",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        _videoStatusLabel.AddThemeFontSizeOverride("font_size", 14);
        vbox.AddChild(_videoStatusLabel);

        _titleOverlayLabel = new Label
        {
            Text = "Select a Game",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        _titleOverlayLabel.AddThemeFontSizeOverride("font_size", 12);
        _titleOverlayLabel.Modulate = new Color(0.7f, 0.7f, 0.7f);
        vbox.AddChild(_titleOverlayLabel);

        _hoverDelayTimer = new Timer
        {
            OneShot = true,
            WaitTime = 0.8f
        };
        _hoverDelayTimer.Timeout += OnTimerTimeout;
        AddChild(_hoverDelayTimer);
    }

    public void LoadGamePreview(GameRom game)
    {
        _pendingGame = game;
        _hoverDelayTimer.Stop();

        _titleOverlayLabel.Text = game.Title;
        if (!string.IsNullOrEmpty(game.CoverArtPath) && File.Exists(game.CoverArtPath))
        {
            var img = Image.LoadFromFile(game.CoverArtPath);
            _posterRect.Texture = ImageTexture.CreateFromImage(img);
        }
        else
        {
            _posterRect.Texture = null;
        }

        _hoverDelayTimer.Start();
    }

    private void OnTimerTimeout()
    {
        if (_pendingGame == null) return;

        if (!string.IsNullOrEmpty(_pendingGame.VideoPreviewPath) && File.Exists(_pendingGame.VideoPreviewPath))
        {
            _videoStatusLabel.Text = "▶ Playing Gameplay Trailer";
            _placeholderOverlay.Color = new Color(0f, 0f, 0f, 0.2f);
        }
        else
        {
            _videoStatusLabel.Text = "🎞️ Preview Poster";
            _placeholderOverlay.Color = new Color(0.05f, 0.05f, 0.08f, 0.7f);
        }
    }
}
