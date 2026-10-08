using System;
using EmulationMenu.Core.Enums;
using Godot;

namespace EmulationMenu.UI.Components;

public enum SortMode
{
    TitleAscending = 0,
    TitleDescending = 1,
    ReleaseYearNewest = 2,
    PlaytimeMostPlayed = 3,
    PlayCountHighest = 4
}

public enum CardDensity
{
    Small = 0,   // 120x160
    Medium = 1,  // 180x240 (Default)
    Large = 2    // 240x320
}

/// <summary>
/// Sorting, Density & Theme Control Bar Component for Godot 4.7.
/// Allows live customization of sorting order, grid card density, color themes, and custom color pickers.
/// </summary>
public partial class SortingControlBar : HBoxContainer
{
    [Signal]
    public delegate void SortModeChangedEventHandler(int sortModeIndex);

    [Signal]
    public delegate void CardDensityChangedEventHandler(int densityIndex);

    [Signal]
    public delegate void UIThemeModeChangedEventHandler(int themeIndex);

    [Signal]
    public delegate void CustomColorPickerRequestedEventHandler();

    [Signal]
    public delegate void SystemConfigRequestedEventHandler();

    [Signal]
    public delegate void BGMToggledEventHandler();

    private OptionButton _sortSelector = null!;
    private OptionButton _densitySelector = null!;
    private OptionButton _themeSelector = null!;
    private Button _customColorButton = null!;
    private Button _sysConfigButton = null!;
    private Button _bgmButton = null!;
    private Label _padStatusLabel = null!;

    public override void _Ready()
    {
        AddThemeConstantOverride("separation", 12);

        // 1. Sort Selector
        var sortLabel = new Label { Text = "Sort By:" };
        _sortSelector = new OptionButton { FocusMode = FocusModeEnum.All };
        _sortSelector.AddItem("Title (A-Z)", (int)SortMode.TitleAscending);
        _sortSelector.AddItem("Title (Z-A)", (int)SortMode.TitleDescending);
        _sortSelector.AddItem("Release Year (Newest)", (int)SortMode.ReleaseYearNewest);
        _sortSelector.AddItem("Playtime (Most Played)", (int)SortMode.PlaytimeMostPlayed);
        _sortSelector.AddItem("Play Count (Highest)", (int)SortMode.PlayCountHighest);
        _sortSelector.ItemSelected += (idx) => EmitSignal(SignalName.SortModeChanged, idx);

        AddChild(sortLabel);
        AddChild(_sortSelector);

        // 2. Card Density Selector
        var densityLabel = new Label { Text = "Grid Size:" };
        _densitySelector = new OptionButton { FocusMode = FocusModeEnum.All };
        _densitySelector.AddItem("Small Cards (120x160)", (int)CardDensity.Small);
        _densitySelector.AddItem("Medium Cards (180x240)", (int)CardDensity.Medium);
        _densitySelector.AddItem("Large Cards (240x320)", (int)CardDensity.Large);
        _densitySelector.Selected = (int)CardDensity.Medium;
        _densitySelector.ItemSelected += (idx) => EmitSignal(SignalName.CardDensityChanged, idx);

        AddChild(densityLabel);
        AddChild(_densitySelector);

        // 3. Theme Selector & Custom Color Button
        var themeLabel = new Label { Text = "Theme:" };
        _themeSelector = new OptionButton { FocusMode = FocusModeEnum.All };
        _themeSelector.AddItem("Cyberpunk Dark", (int)UIThemeMode.CyberpunkDark);
        _themeSelector.AddItem("Synthwave Retro", (int)UIThemeMode.SynthwaveRetro);
        _themeSelector.AddItem("Modern Clean Dark", (int)UIThemeMode.ModernCleanDark);
        _themeSelector.AddItem("Clean Light", (int)UIThemeMode.CleanLight);
        _themeSelector.ItemSelected += (idx) => EmitSignal(SignalName.UIThemeModeChanged, idx);

        _customColorButton = new Button
        {
            Text = "🎨 Custom Colors...",
            FocusMode = FocusModeEnum.All
        };
        _customColorButton.Pressed += () => EmitSignal(SignalName.CustomColorPickerRequested);

        AddChild(themeLabel);
        AddChild(_themeSelector);
        AddChild(_customColorButton);

        // 4. RetroBat System Overrides & BGM Controls
        _sysConfigButton = new Button
        {
            Text = "⚙️ System Overrides...",
            FocusMode = FocusModeEnum.All
        };
        _sysConfigButton.Pressed += () => EmitSignal(SignalName.SystemConfigRequested);
        AddChild(_sysConfigButton);

        _bgmButton = new Button
        {
            Text = "🎵 BGM Music",
            FocusMode = FocusModeEnum.All
        };
        _bgmButton.Pressed += () => EmitSignal(SignalName.BGMToggled);
        AddChild(_bgmButton);

        _padStatusLabel = new Label
        {
            Text = "🎮 XInput Gamepad",
            Modulate = new Color(0.2f, 0.9f, 0.4f)
        };
        AddChild(_padStatusLabel);
    }
}

