using System;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Implementations;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// RetroBat System & Per-Game Emulator Configuration Modal Dialog.
/// Allows real-time customization of Aspect Ratios, Bezels, CRT Shaders, Engine Modes, and Controller Mappings.
/// </summary>
public partial class SystemConfigModal : Window
{
    private readonly SystemConfigOverrideManager _configManager;
    private PlatformType _activePlatform;

    private OptionButton _modeOption = null!;
    private OptionButton _aspectOption = null!;
    private OptionButton _bezelOption = null!;
    private OptionButton _shaderOption = null!;
    private CheckBox _autoPadCheck = null!;
    private LineEdit _argsInput = null!;
    private Label _titleLabel = null!;

    public event Action<SystemConfigOverride>? ConfigSaved;

    public SystemConfigModal(SystemConfigOverrideManager configManager)
    {
        _configManager = configManager;
        Title = "3DRetro - System & Emulator Configuration";

        Size = new Vector2I(550, 480);

        Unresizable = true;
        Exclusive = true;
        Visible = false;

        BuildUI();
    }

    private void BuildUI()
    {
        var mainContainer = new MarginContainer();
        mainContainer.AddThemeConstantOverride("margin_left", 20);
        mainContainer.AddThemeConstantOverride("margin_right", 20);
        mainContainer.AddThemeConstantOverride("margin_top", 20);
        mainContainer.AddThemeConstantOverride("margin_bottom", 20);
        AddChild(mainContainer);

        var vbox = new VBoxContainer();
        vbox.AddThemeConstantOverride("separation", 15);
        mainContainer.AddChild(vbox);

        _titleLabel = new Label
        {
            Text = "Platform System Overrides",
            HorizontalAlignment = HorizontalAlignment.Center
        };
        _titleLabel.AddThemeFontSizeOverride("font_size", 20);
        vbox.AddChild(_titleLabel);

        vbox.AddChild(new HSeparator());

        // Emulator Mode
        vbox.AddChild(CreateFieldLabel("Execution Engine Mode:"));
        _modeOption = new OptionButton();
        _modeOption.AddItem("Standalone Executable", 0);
        _modeOption.AddItem("Libretro Core (RetroArch)", 1);
        vbox.AddChild(_modeOption);

        // Aspect Ratio
        vbox.AddChild(CreateFieldLabel("Aspect Ratio:"));
        _aspectOption = new OptionButton();
        _aspectOption.AddItem("Original (4:3)", 0);
        _aspectOption.AddItem("Widescreen (16:9)", 1);
        _aspectOption.AddItem("Integer Scale", 2);
        _aspectOption.AddItem("Auto Match", 3);
        vbox.AddChild(_aspectOption);

        // Bezel Style
        vbox.AddChild(CreateFieldLabel("Artwork Bezel Overlay:"));
        _bezelOption = new OptionButton();
        _bezelOption.AddItem("Console Themed Frame", 0);
        _bezelOption.AddItem("Arcade Cabinet Frame", 1);
        _bezelOption.AddItem("Retro CRT TV Screen", 2);
        _bezelOption.AddItem("Clean Glass Border", 3);
        _bezelOption.AddItem("Disabled", 4);
        vbox.AddChild(_bezelOption);

        // Shader Preset
        vbox.AddChild(CreateFieldLabel("Visual Shader Effect:"));
        _shaderOption = new OptionButton();
        _shaderOption.AddItem("CRT Scanlines (Authentic)", 0);
        _shaderOption.AddItem("Subtle Glow & Phosphor", 1);
        _shaderOption.AddItem("Cyberpunk Neon Matrix", 2);
        _shaderOption.AddItem("None / Sharp Pixels", 3);
        vbox.AddChild(_shaderOption);

        // Auto Controller mapping
        _autoPadCheck = new CheckBox
        {
            Text = "Auto-Configure Gamepad & Hotkeys on Launch",
            ButtonPressed = true
        };
        vbox.AddChild(_autoPadCheck);

        // Additional Launch Args
        vbox.AddChild(CreateFieldLabel("Custom CLI Arguments:"));
        _argsInput = new LineEdit
        {
            PlaceholderText = "e.g. --fullscreen --vulkan"
        };
        vbox.AddChild(_argsInput);

        vbox.AddChild(new HSeparator());

        // Action Buttons
        var hboxBtns = new HBoxContainer();
        hboxBtns.Alignment = BoxContainer.AlignmentMode.End;
        hboxBtns.AddThemeConstantOverride("separation", 10);
        vbox.AddChild(hboxBtns);

        var cancelBtn = new Button { Text = "Cancel", CustomMinimumSize = new Vector2(100, 36) };
        cancelBtn.Pressed += () => Hide();
        hboxBtns.AddChild(cancelBtn);

        var saveBtn = new Button { Text = "Save Settings", CustomMinimumSize = new Vector2(130, 36) };
        saveBtn.Pressed += OnSavePressed;
        hboxBtns.AddChild(saveBtn);
    }

    private Label CreateFieldLabel(string text)
    {
        var lbl = new Label { Text = text };
        lbl.AddThemeFontSizeOverride("font_size", 14);
        return lbl;
    }

    public void OpenForPlatform(PlatformType platform)
    {
        _activePlatform = platform;
        _titleLabel.Text = $"⚙️ {platform} System Overrides";


        var cfg = _configManager.GetSystemConfig(platform);
        _modeOption.Select(cfg.PreferredMode == ExecutionMode.Standalone ? 0 : 1);
        
        _aspectOption.Select(cfg.AspectRatio switch
        {
            "16:9" => 1,
            "Integer" => 2,
            "Auto" => 3,
            _ => 0
        });

        _bezelOption.Select(cfg.BezelStyle switch
        {
            "ArcadeCabinet" => 1,
            "RetroTV" => 2,
            "CleanGlass" => 3,
            "Disabled" => 4,
            _ => 0
        });

        _shaderOption.Select(cfg.ShaderPreset switch
        {
            "Subtle-Glow" => 1,
            "Cyberpunk" => 2,
            "None" => 3,
            _ => 0
        });

        _autoPadCheck.ButtonPressed = cfg.AutoControllerConfig;
        _argsInput.Text = cfg.AdditionalLaunchArgs;

        PopupCentered();
    }

    private void OnSavePressed()
    {
        var cfg = new SystemConfigOverride
        {
            TargetPlatform = _activePlatform,
            PreferredMode = _modeOption.Selected == 0 ? ExecutionMode.Standalone : ExecutionMode.LibretroCore,
            AspectRatio = _aspectOption.Selected switch { 1 => "16:9", 2 => "Integer", 3 => "Auto", _ => "4:3" },
            BezelStyle = _bezelOption.Selected switch { 1 => "ArcadeCabinet", 2 => "RetroTV", 3 => "CleanGlass", 4 => "Disabled", _ => "ConsoleThemed" },
            ShaderPreset = _shaderOption.Selected switch { 1 => "Subtle-Glow", 2 => "Cyberpunk", 3 => "None", _ => "CRT-Scanlines" },
            AutoControllerConfig = _autoPadCheck.ButtonPressed,
            AdditionalLaunchArgs = _argsInput.Text
        };

        _configManager.SaveSystemConfig(cfg);
        ConfigSaved?.Invoke(cfg);
        Hide();
    }
}
