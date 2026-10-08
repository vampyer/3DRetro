using System;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Godot 4.7 Interactive Selection Modal.
/// Prompts the user to choose between downloading a Standalone Windows Emulator binary
/// or a RetroArch Libretro Core DLL.
/// </summary>
public partial class EmulatorSelectionModal : Window
{
    private Label _titleLabel = null!;
    private Label _descriptionLabel = null!;
    private Button _standaloneButton = null!;
    private Button _libretroButton = null!;

    private TaskCompletionSource<ExecutionMode>? _tcs;

    public override void _Ready()
    {
        Title = "Select Emulator Engine Target";
        Size = new Vector2I(600, 320);
        Exclusive = true;
        Unresizable = true;

        var marginContainer = new MarginContainer();
        marginContainer.AddThemeConstantOverride("margin_top", 20);
        marginContainer.AddThemeConstantOverride("margin_left", 20);
        marginContainer.AddThemeConstantOverride("margin_right", 20);
        marginContainer.AddThemeConstantOverride("margin_bottom", 20);
        AddChild(marginContainer);

        var vBox = new VBoxContainer();
        marginContainer.AddChild(vBox);

        _titleLabel = new Label
        {
            Text = "Emulator Auto-Downloader",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        _titleLabel.AddThemeFontSizeOverride("font_size", 20);
        vBox.AddChild(_titleLabel);

        _descriptionLabel = new Label
        {
            Text = "Select your preferred execution engine. Would you like to download and use a Standalone Windows binary or a RetroArch Libretro Core?",
            HorizontalAlignment = HorizontalAlignment.Center,
            AutowrapMode = TextServer.AutowrapMode.WordSmart
        };
        vBox.AddChild(_descriptionLabel);

        vBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 20) });

        var buttonContainer = new VBoxContainer();
        _standaloneButton = new Button
        {
            Text = "🖥️ Download Standalone Windows Emulator (e.g. Dolphin, PCSX2, RPCS3)",
            CustomMinimumSize = new Vector2(0, 50),
            FocusMode = Control.FocusModeEnum.All
        };
        _standaloneButton.Pressed += () => OnModeSelected(ExecutionMode.Standalone);

        _libretroButton = new Button
        {
            Text = "🎮 Download RetroArch Libretro Core (.dll)",
            CustomMinimumSize = new Vector2(0, 50),
            FocusMode = Control.FocusModeEnum.All
        };
        _libretroButton.Pressed += () => OnModeSelected(ExecutionMode.LibretroCore);

        buttonContainer.AddChild(_standaloneButton);
        buttonContainer.AddChild(new Control { CustomMinimumSize = new Vector2(0, 10) });
        buttonContainer.AddChild(_libretroButton);

        vBox.AddChild(buttonContainer);

        CloseRequested += OnCloseRequested;
    }

    public Task<ExecutionMode> PromptUserChoiceAsync(PlatformType platform)
    {
        _tcs = new TaskCompletionSource<ExecutionMode>();

        _titleLabel.Text = $"Select Emulator for {platform}";
        _descriptionLabel.Text = $"No emulator binary was found for {platform}. Choose how you would like to run your games:";

        PopupCentered();
        _standaloneButton.GrabFocus();

        return _tcs.Task;
    }

    private void OnModeSelected(ExecutionMode mode)
    {
        _tcs?.TrySetResult(mode);
        Hide();
    }

    private void OnCloseRequested()
    {
        // Default fallback choice on dialog close
        _tcs?.TrySetResult(ExecutionMode.LibretroCore);
        Hide();
    }
}
