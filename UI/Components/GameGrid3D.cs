using System;
using System.Collections.Generic;
using EmulationMenu.Core.Models;
using Godot;

namespace EmulationMenu.UI.Components;

/// <summary>
/// 3D Carousel & Cover Wall Component for Godot 4.7 .NET.
/// Renders game boxart on 3D meshes in a dynamic curved 3D space with interactive camera tracking.
/// </summary>
public partial class GameGrid3D : Node3D
{
    [Signal]
    public delegate void GameSelected3DEventHandler(string gameId);

    private Camera3D _camera = null!;
    private DirectionalLight3D _light = null!;
    private Node3D _carouselContainer = null!;

    private readonly List<GameRom> _games = [];
    private readonly List<MeshInstance3D> _card3DMeshes = [];
    private int _focusedIndex = 0;
    private float _targetRotationY = 0f;

    public override void _Ready()
    {
        // 3D Environment setup
        _camera = new Camera3D
        {
            Position = new Vector3(0, 0.5f, 4.5f),
            Fov = 60f
        };
        AddChild(_camera);

        _light = new DirectionalLight3D
        {
            RotationDegrees = new Vector3(-35, 45, 0),
            LightEnergy = 1.2f
        };
        AddChild(_light);

        _carouselContainer = new Node3D();
        AddChild(_carouselContainer);
    }

    public void SetGames(IEnumerable<GameRom> games)
    {
        // Clean up previous 3D meshes
        foreach (var mesh in _card3DMeshes)
        {
            mesh.QueueFree();
        }
        _card3DMeshes.Clear();
        _games.Clear();
        _games.AddRange(games);
        _focusedIndex = 0;

        float radius = Math.Max(3f, _games.Count * 0.4f);
        float angleStep = Mathf.Tau / Math.Max(1, _games.Count);

        for (int i = 0; i < _games.Count; i++)
        {
            var game = _games[i];

            // 3D Box Mesh creation
            var meshInst = new MeshInstance3D
            {
                Mesh = new BoxMesh { Size = new Vector3(1.2f, 1.6f, 0.1f) }
            };

            var material = new StandardMaterial3D();
            if (!string.IsNullOrEmpty(game.CoverArtPath) && System.IO.File.Exists(game.CoverArtPath))
            {
                try
                {
                    var img = Image.LoadFromFile(game.CoverArtPath);
                    if (img != null)
                    {
                        material.AlbedoTexture = ImageTexture.CreateFromImage(img);
                    }
                }
                catch (Exception ex)
                {
                    GD.PrintErr($"3D Material texture load error: {ex.Message}");
                }
            }
            meshInst.MaterialOverride = material;

            // Position 3D box along curved carousel radius
            float angle = i * angleStep;
            float posX = Mathf.Sin(angle) * radius;
            float posZ = Mathf.Cos(angle) * radius - radius;

            meshInst.Position = new Vector3(posX, 0, posZ);
            meshInst.Rotation = new Vector3(0, angle, 0);

            _carouselContainer.AddChild(meshInst);
            _card3DMeshes.Add(meshInst);
        }

        UpdateCarouselPosition(immediate: true);
    }

    public override void _Process(double delta)
    {
        if (_games.Count == 0) return;

        // Smooth camera and carousel rotation interpolation
        float currentRotY = _carouselContainer.Rotation.Y;
        _carouselContainer.Rotation = new Vector3(0, Mathf.Lerp(currentRotY, _targetRotationY, (float)delta * 8.0f), 0);
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (_games.Count == 0 || !Visible) return;

        if (Input.IsActionJustPressed("ui_right"))
        {
            Navigate3D(1);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_left"))
        {
            Navigate3D(-1);
            GetViewport().SetInputAsHandled();
        }
        else if (Input.IsActionJustPressed("ui_accept"))
        {
            if (_focusedIndex >= 0 && _focusedIndex < _games.Count)
            {
                EmitSignal(SignalName.GameSelected3D, _games[_focusedIndex].Id);
                GetViewport().SetInputAsHandled();
            }
        }
    }

    private void Navigate3D(int delta)
    {
        int targetIdx = Math.Clamp(_focusedIndex + delta, 0, _games.Count - 1);
        if (targetIdx == _focusedIndex) return;

        _focusedIndex = targetIdx;
        UpdateCarouselPosition(immediate: false);

        if (_focusedIndex >= 0 && _focusedIndex < _games.Count)
        {
            EmitSignal(SignalName.GameSelected3D, _games[_focusedIndex].Id);
        }
    }

    private void UpdateCarouselPosition(bool immediate)
    {
        float angleStep = Mathf.Tau / Math.Max(1, _games.Count);
        _targetRotationY = -_focusedIndex * angleStep;

        if (immediate)
        {
            _carouselContainer.Rotation = new Vector3(0, _targetRotationY, 0);
        }
    }
}
