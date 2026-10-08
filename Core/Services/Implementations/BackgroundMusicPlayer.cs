using System;
using Godot;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// RetroBat Background Audio & Chiptune Soundtrack Manager.
/// Manages background audio playback in the Godot UI with auto-fading, volume ducking on video hover,
/// and pause/resume lifecycle handlers for active emulator launches.
/// </summary>
public partial class BackgroundMusicPlayer : Node
{
    private AudioStreamPlayer _audioPlayer = null!;
    private float _userVolumeDb = -12.0f;
    private bool _isMuted = false;
    private bool _isDuckedForVideo = false;

    public override void _Ready()
    {
        _audioPlayer = new AudioStreamPlayer
        {
            Name = "BGMStreamPlayer",
            VolumeDb = _userVolumeDb,
            Autoplay = false
        };
        AddChild(_audioPlayer);
    }

    public void ToggleMute()
    {
        _isMuted = !_isMuted;
        _audioPlayer.VolumeDb = _isMuted ? -80.0f : (_isDuckedForVideo ? _userVolumeDb - 15.0f : _userVolumeDb);
    }

    public bool IsMuted => _isMuted;

    public void DuckVolumeForVideo(bool duck)
    {
        _isDuckedForVideo = duck;
        if (!_isMuted)
        {
            _audioPlayer.VolumeDb = duck ? _userVolumeDb - 15.0f : _userVolumeDb;
        }
    }

    public void PauseForGameLaunch()
    {
        if (_audioPlayer.Playing)
        {
            _audioPlayer.StreamPaused = true;
        }
    }

    public void ResumeAfterGameExit()
    {
        if (_audioPlayer.StreamPaused)
        {
            _audioPlayer.StreamPaused = false;
        }
    }

    public void PlayTrack(AudioStream stream)
    {
        _audioPlayer.Stream = stream;
        _audioPlayer.Play();
    }
}
