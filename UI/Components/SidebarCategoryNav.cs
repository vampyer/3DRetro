using System;
using System.Collections.Generic;
using EmulationMenu.Core.Services.Implementations;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// Navigation Sidebar Control in Godot 4.7.
/// Provides real-time text search line edit and category buttons for All Games, Favorites, Recently Played, and 33 Platform categories.
/// </summary>
public partial class SidebarCategoryNav : PanelContainer
{
    [Signal]
    public delegate void CategorySelectedEventHandler(string categoryName);

    [Signal]
    public delegate void SearchTextChangedEventHandler(string searchText);

    private LineEdit _searchBox = null!;
    private VBoxContainer _buttonContainer = null!;
    private readonly List<Button> _categoryButtons = [];

    public override void _Ready()
    {
        CustomMinimumSize = new Vector2(240, 0);

        var margin = new MarginContainer();
        margin.AddThemeConstantOverride("margin_top", 12);
        margin.AddThemeConstantOverride("margin_bottom", 12);
        margin.AddThemeConstantOverride("margin_left", 12);
        margin.AddThemeConstantOverride("margin_right", 12);
        AddChild(margin);

        var mainVBox = new VBoxContainer();
        margin.AddChild(mainVBox);

        // Search Input LineEdit
        _searchBox = new LineEdit
        {
            PlaceholderText = "🔍 Search Games...",
            ClearButtonEnabled = true
        };
        _searchBox.TextChanged += (text) => EmitSignal(SignalName.SearchTextChanged, text);
        mainVBox.AddChild(_searchBox);

        mainVBox.AddChild(new Control { CustomMinimumSize = new Vector2(0, 10) });

        var scroll = new ScrollContainer
        {
            SizeFlagsVertical = SizeFlags.ExpandFill,
            HorizontalScrollMode = ScrollContainer.ScrollMode.Disabled
        };
        mainVBox.AddChild(scroll);

        _buttonContainer = new VBoxContainer();
        scroll.AddChild(_buttonContainer);

        PopulateCategories();
    }

    private void PopulateCategories()
    {
        AddCategoryHeader("SMART COLLECTIONS");
        AddCategoryButton("🎮 All Games");
        AddCategoryButton("⭐ Favorites");
        AddCategoryButton("🕒 Recently Played");
        AddCategoryButton("🆕 Never Played");
        AddCategoryButton("👥 2-Player (2P+)");
        AddCategoryButton("🎉 Party Games (4P+)");
        AddCategoryButton("🕹️ Arcade Classics");

        _buttonContainer.AddChild(new HSeparator());
        AddCategoryHeader("CUSTOM PLAYLISTS");
        AddCategoryButton("📁 Mario Franchise");
        AddCategoryButton("📁 Zelda Series");
        AddCategoryButton("📁 Final Fantasy");
        AddCategoryButton("📁 Beat 'em Ups");

        _buttonContainer.AddChild(new HSeparator());
        AddCategoryHeader("SYSTEM PLATFORMS");
        foreach (var platformInfo in RomDirectoryManager.GetAllSupportedPlatforms())
        {
            AddCategoryButton(platformInfo.SystemDisplayName);
        }
    }

    private void AddCategoryHeader(string headerText)
    {
        var lbl = new Label
        {
            Text = headerText,
            HorizontalAlignment = HorizontalAlignment.Left
        };
        lbl.AddThemeFontSizeOverride("font_size", 11);
        lbl.Modulate = new Color(0.6f, 0.6f, 0.6f);
        _buttonContainer.AddChild(lbl);
    }

    private void AddCategoryButton(string label)
    {
        var btn = new Button
        {
            Text = label,
            Alignment = HorizontalAlignment.Left,
            CustomMinimumSize = new Vector2(0, 36),
            FocusMode = FocusModeEnum.All
        };

        btn.Pressed += () => EmitSignal(SignalName.CategorySelected, label);
        _buttonContainer.AddChild(btn);
        _categoryButtons.Add(btn);
    }
}

