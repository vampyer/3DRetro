using System;
using System.Collections.Generic;
using EmulationMenu.Core.Models;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// High-Performance Virtualized Grid Control for Godot 4.7 .NET.
/// Capable of rendering 10,000+ games at locked 60+ FPS by recycling a pool of visible UI nodes.
/// Supports dynamic card size density scaling and Joypad controller navigation.
/// </summary>
public partial class VirtualGameGrid : ScrollContainer
{
    [Signal]
    public delegate void GameSelectedEventHandler(string gameId);

    [Export] public Vector2 ItemSize = new(180, 240);
    [Export] public Vector2 Spacing = new(16, 16);

    private readonly List<GameRom> _allGames = [];
    private readonly Dictionary<int, Control> _activeVisibleCards = [];
    private readonly Queue<Control> _recycledCardPool = new();

    private Control _contentContainer = null!;
    private int _columnsCount = 4;
    private int _firstVisibleIndex = -1;
    private int _lastVisibleIndex = -1;
    private int _focusedIndex = 0;

    public override void _Ready()
    {
        _contentContainer = new Control();
        AddChild(_contentContainer);

        GetVScrollBar().ValueChanged += OnScrollValueChanged;
        Resized += RecalculateLayout;
    }

    public void SetCardSize(Vector2 newSize)
    {
        ItemSize = newSize;
        RecalculateLayout();
    }

    public void SetGames(IEnumerable<GameRom> games)
    {
        _allGames.Clear();
        _allGames.AddRange(games);
        _focusedIndex = 0;
        RecalculateLayout();
    }

    private void RecalculateLayout()
    {
        if (_contentContainer == null) return;

        float availableWidth = Size.X - GetVScrollBar().Size.X;
        _columnsCount = Math.Max(1, (int)((availableWidth + Spacing.X) / (ItemSize.X + Spacing.X)));

        int totalRows = Mathf.CeilToInt((float)_allGames.Count / _columnsCount);
        float totalHeight = totalRows * (ItemSize.Y + Spacing.Y);

        _contentContainer.CustomMinimumSize = new Vector2(availableWidth, totalHeight);
        UpdateVisibleRange(forceRefresh: true);
    }

    private void OnScrollValueChanged(double value)
    {
        UpdateVisibleRange(forceRefresh: false);
    }

    private void UpdateVisibleRange(bool forceRefresh)
    {
        if (_allGames.Count == 0) return;

        float scrollY = (float)GetVScrollBar().Value;
        float viewportHeight = Size.Y;

        int startRow = Math.Max(0, (int)(scrollY / (ItemSize.Y + Spacing.Y)) - 1);
        int endRow = (int)((scrollY + viewportHeight) / (ItemSize.Y + Spacing.Y)) + 1;

        int newFirstIdx = Math.Clamp(startRow * _columnsCount, 0, _allGames.Count - 1);
        int newLastIdx = Math.Clamp((endRow + 1) * _columnsCount - 1, 0, _allGames.Count - 1);

        if (!forceRefresh && newFirstIdx == _firstVisibleIndex && newLastIdx == _lastVisibleIndex)
            return;

        _firstVisibleIndex = newFirstIdx;
        _lastVisibleIndex = newLastIdx;

        List<int> toRemove = [];
        foreach (var (index, cardNode) in _activeVisibleCards)
        {
            if (index < _firstVisibleIndex || index > _lastVisibleIndex || forceRefresh)
            {
                cardNode.Visible = false;
                _recycledCardPool.Enqueue(cardNode);
                toRemove.Add(index);
            }
        }

        foreach (int idx in toRemove)
        {
            _activeVisibleCards.Remove(idx);
        }

        for (int i = _firstVisibleIndex; i <= _lastVisibleIndex; i++)
        {
            if (_activeVisibleCards.ContainsKey(i)) continue;

            Control card = FetchOrCreateCardNode();
            PositionCard(card, i);
            BindCardData(card, _allGames[i], i);

            card.Visible = true;
            _activeVisibleCards[i] = card;
        }
    }

    private Control FetchOrCreateCardNode()
    {
        if (_recycledCardPool.TryDequeue(out Control? recycledCard))
        {
            recycledCard.CustomMinimumSize = ItemSize;
            return recycledCard;
        }

        Button newCard = new()
        {
            CustomMinimumSize = ItemSize,
            FocusMode = FocusModeEnum.All
        };

        _contentContainer.AddChild(newCard);
        return newCard;
    }

    private void PositionCard(Control card, int index)
    {
        int row = index / _columnsCount;
        int col = index % _columnsCount;

        float posX = col * (ItemSize.X + Spacing.X);
        float posY = row * (ItemSize.Y + Spacing.Y);

        card.Position = new Vector2(posX, posY);
    }

    private void BindCardData(Control card, GameRom game, int index)
    {
        if (card is Button button)
        {
            button.Text = game.Title;
            button.TooltipText = $"{game.Title} ({game.Platform})";
            
            var callable = Callable.From(() => OnCardPressed(game, index));
            if (button.IsConnected(Button.SignalName.Pressed, callable))
            {
                button.Disconnect(Button.SignalName.Pressed, callable);
            }
            button.Connect(Button.SignalName.Pressed, callable);
        }
    }

    private void OnCardPressed(GameRom game, int index)
    {
        _focusedIndex = index;
        EmitSignal(SignalName.GameSelected, game.Id);
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (_allGames.Count == 0 || !Visible) return;

        if (Input.IsActionJustPressed("ui_right"))
        {
            NavigateFocus(1);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_left"))
        {
            NavigateFocus(-1);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_down"))
        {
            NavigateFocus(_columnsCount);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_up"))
        {
            NavigateFocus(-_columnsCount);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_accept"))
        {
            if (_focusedIndex >= 0 && _focusedIndex < _allGames.Count)
            {
                EmitSignal(SignalName.GameSelected, _allGames[_focusedIndex].Id);
                GetViewport().SetInputAsHandled();
            }
        }
    }

    private void NavigateFocus(int delta)
    {
        int targetIdx = Math.Clamp(_focusedIndex + delta, 0, _allGames.Count - 1);
        if (targetIdx == _focusedIndex) return;

        _focusedIndex = targetIdx;

        int targetRow = _focusedIndex / _columnsCount;
        float targetY = targetRow * (ItemSize.Y + Spacing.Y);
        
        EnsureYVisible(targetY);
        UpdateVisibleRange(forceRefresh: false);

        if (_activeVisibleCards.TryGetValue(_focusedIndex, out Control? card))
        {
            card.GrabFocus();
        }
    }

    private void EnsureYVisible(float targetY)
    {
        float scrollY = (float)GetVScrollBar().Value;
        float viewportHeight = Size.Y;

        if (targetY < scrollY)
        {
            GetVScrollBar().Value = targetY;
        }
        else if (targetY + ItemSize.Y > scrollY + viewportHeight)
        {
            GetVScrollBar().Value = targetY + ItemSize.Y - viewportHeight;
        }
    }
}
