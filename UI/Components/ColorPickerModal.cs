using System;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Custom UI Color Picker Modal for Godot 4.7 .NET.
/// Allows the user to select custom RGBA colors for Background, Surface Containers, Accent Highlights, and Text.
/// </summary>
public partial class ColorPickerModal : Window
{
    [Signal]
    public delegate void CustomColorsAppliedEventHandler(Color bgColor, Color surfaceColor, Color accentColor, Color textColor);

    private ColorPickerButton _bgPicker = null!;
    private ColorPickerButton _surfacePicker = null!;
    private ColorPickerButton _accentPicker = null!;
    private ColorPickerButton _textPicker = null!;
    private Button _applyButton = null!;

    public override void _Ready()
    {
        Title = "🎨 Interface Color Customizer";
        Size = new Vector2I(450, 360);
        Exclusive = true;
        Unresizable = true;

        var margin = new MarginContainer();
        margin.AddThemeConstantOverride("margin_top", 20);
        margin.AddThemeConstantOverride("margin_bottom", 20);
        margin.AddThemeConstantOverride("margin_left", 20);
        margin.AddThemeConstantOverride("margin_right", 20);
        AddChild(margin);

        var vBox = new VBoxContainer();
        margin.AddChild(vBox);

        var titleLabel = new Label
        {
            Text = "Customize UI Colors",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        titleLabel.AddThemeFontSizeOverride("font_size", 20);
        vBox.AddChild(titleLabel);

        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 16) });

        var grid = new GridContainer
        {
            Columns = 2,
            SizeFlagsHorizontal = Control.SizeFlags.ExpandFill
        };
        grid.AddThemeConstantOverride("h_separation", 20);
        grid.AddThemeConstantOverride("v_separation", 12);
        vBox.AddChild(grid);

        // 1. Background Color
        grid.AddChild(new Label { Text = "Background Color:" });
        _bgPicker = new ColorPickerButton
        {
            Color = new Color(0.08f, 0.08f, 0.12f),
            CustomMinimumSize = new Vector2(160, 36)
        };
        grid.AddChild(_bgPicker);

        // 2. Surface Container Color
        grid.AddChild(new Label { Text = "Surface / Card Color:" });
        _surfacePicker = new ColorPickerButton
        {
            Color = new Color(0.14f, 0.14f, 0.20f),
            CustomMinimumSize = new Vector2(160, 36)
        };
        grid.AddChild(_surfacePicker);

        // 3. Accent Glow Color
        grid.AddChild(new Label { Text = "Accent Highlight Color:" });
        _accentPicker = new ColorPickerButton
        {
            Color = new Color(0.00f, 0.80f, 1.00f),
            CustomMinimumSize = new Vector2(160, 36)
        };
        grid.AddChild(_accentPicker);

        // 4. Text Color
        grid.AddChild(new Label { Text = "Primary Text Color:" });
        _textPicker = new ColorPickerButton
        {
            Color = Colors.White,
            CustomMinimumSize = new Vector2(160, 36)
        };
        grid.AddChild(_textPicker);

        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 24) });

        _applyButton = new Button
        {
            Text = "✔ Apply Custom Colors",
            CustomMinimumSize = new Vector2(0, 44),
            FocusMode = Control.FocusModeEnum.All
        };
        _applyButton.Pressed += OnApplyPressed;
        vBox.AddChild(_applyButton);

        CloseRequested += Hide;
    }

    public void OpenCustomizer(Color currentBg, Color currentSurface, Color currentAccent, Color currentText)
    {
        _bgPicker.Color = currentBg;
        _surfacePicker.Color = currentSurface;
        _accentPicker.Color = currentAccent;
        _textPicker.Color = currentText;

        PopupCentered();
        _applyButton.GrabFocus();
    }

    private void OnApplyPressed()
    {
        EmitSignal(SignalName.CustomColorsApplied, _bgPicker.Color, _surfacePicker.Color, _accentPicker.Color, _textPicker.Color);
        Hide();
    }
}
