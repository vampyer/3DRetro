using System;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Custom Game Card Control for Godot 4.7.
/// Displays dynamic cover art texture, platform badges, title text, and handles focus state animations.
/// </summary>
public partial class GameCard : Godot.Button
{
    private Godot.TextureRect _coverArtTexture = null!;
    private Godot.Label _titleLabel = null!;
    private Godot.Label _platformBadge = null!;
    private Godot.PanelContainer _cardBorder = null!;

    public string GameId { get; private set; } = string.Empty;

    public override void _Ready()
    {
        CustomMinimumSize = new Godot.Vector2(180, 240);
        FocusMode = FocusModeEnum.All;

        // Container structure
        var vBox = new Godot.VBoxContainer
        {
            AnchorRight = 1.0f,
            AnchorBottom = 1.0f
        };
        AddChild(vBox);

        // Cover Art Texture Container
        _coverArtTexture = new Godot.TextureRect
        {
            ExpandMode = Godot.TextureRect.ExpandModeEnum.IgnoreSize,
            StretchMode = Godot.TextureRect.StretchModeEnum.KeepAspectCovered,
            SizeFlagsVertical = SizeFlags.ExpandFill,
            CustomMinimumSize = new Godot.Vector2(180, 190)
        };
        vBox.AddChild(_coverArtTexture);

        // Details Container
        var detailsBox = new Godot.HBoxContainer();
        _titleLabel = new Godot.Label
        {
            Text = "Game Title",
            SizeFlagsHorizontal = SizeFlags.ExpandFill,
            ClipText = true
        };
        _platformBadge = new Godot.Label
        {
            Text = "SNES"
        };

        detailsBox.AddChild(_titleLabel);
        detailsBox.AddChild(_platformBadge);
        vBox.AddChild(detailsBox);

        // Connect Focus animations using Callable.From
        FocusEntered += OnFocusEntered;
        FocusExited += OnFocusExited;
    }

    public void BindData(Core.Models.GameRom game)
    {
        GameId = game.Id;
        _titleLabel.Text = game.Title;
        _platformBadge.Text = game.Platform.ToString();
        TooltipText = $"{game.Title} ({game.Platform})";

        if (!string.IsNullOrEmpty(game.CoverArtPath) && System.IO.File.Exists(game.CoverArtPath))
        {
            try
            {
                var image = Godot.Image.LoadFromFile(game.CoverArtPath);
                if (image != null)
                {
                    _coverArtTexture.Texture = Godot.ImageTexture.CreateFromImage(image);
                }
            }
            catch (Exception ex)
            {
                Godot.GD.PrintErr($"Failed to load texture for card '{game.Title}': {ex.Message}");
            }
        }
    }

    private void OnFocusEntered()
    {
        // Scale up effect on focus for Joypad / Controller navigation
        PivotOffset = Size / 2;
        Scale = new Godot.Vector2(1.05f, 1.05f);
    }

    private void OnFocusExited()
    {
        Scale = Godot.Vector2.One;
    }
}
