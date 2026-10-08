using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using EmulationMenu.Core.Enums;
using EmulationMenu.Core.Models;
using EmulationMenu.Core.Services.Interfaces;
using Godot;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Thread-safe Win32 Process Management & Launcher for Emulators.
/// Manages window visibility, process argument generation (Standalone vs RetroArch -L),
/// playtime tracking, and clean focus restoration.
/// </summary>
public class EmulatorLauncher : IEmulatorLauncher
{
    private readonly object _lock = new();
    private Process? _activeProcess;
    private Stopwatch? _playTimer;

    public event EventHandler<TimeSpan>? GameExited;
    public bool IsRunning => _activeProcess is { HasExited: false };

    // Win32 API Imports for seamless focus swapping on Windows
    [DllImport("user32.dll")]
    private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    private const int SW_HIDE = 0;
    private const int SW_RESTORE = 9;

    public async Task<bool> LaunchGameAsync(GameRom game, EmulatorDefinition emulatorConfig, string retroArchBasePath)
    {
        await Task.Yield(); // Ensures caller yielding for process start initiation

        lock (_lock)
        {
            if (IsRunning)
                throw new InvalidOperationException("An emulator process is already active.");
        }

        string exePath;
        string commandArgs;

        if (game.ActiveExecutionMode == ExecutionMode.Standalone)
        {
            string emulatorDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Emulators", game.Platform.ToString());
            exePath = Path.Combine(emulatorDir, emulatorConfig.StandaloneExePath ?? $"{emulatorConfig.DisplayName}.exe");
            
            if (!File.Exists(exePath))
                throw new FileNotFoundException($"Standalone emulator binary not found at: {exePath}");

            // Standard argument placeholder format replacement
            commandArgs = string.Format(emulatorConfig.DefaultLaunchArgs, game.FilePath);
        }
        else
        {
            // Libretro Core Fallback via RetroArch executable
            exePath = Path.Combine(retroArchBasePath, "retroarch.exe");
            if (!File.Exists(exePath))
                throw new FileNotFoundException($"RetroArch executable not found at: {exePath}");

            string coreDllPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App", "Emulators", game.Platform.ToString(), $"{emulatorConfig.LibretroCoreName}.dll");
            if (!File.Exists(coreDllPath))
                throw new FileNotFoundException($"Libretro core DLL not found at: {coreDllPath}");

            // Libretro standard command string: retroarch.exe -L "C:\path\to\core.dll" "C:\path\to\rom.iso"
            commandArgs = $"-L \"{coreDllPath}\" \"{game.FilePath}\"";
        }

        ProcessStartInfo startInfo = new()
        {
            FileName = exePath,
            Arguments = commandArgs,
            UseShellExecute = false,
            CreateNoWindow = false,
            WorkingDirectory = Path.GetDirectoryName(exePath) ?? string.Empty
        };

        try
        {
            _activeProcess = new Process { StartInfo = startInfo, EnableRaisingEvents = true };
            _playTimer = Stopwatch.StartNew();

            // Hide Godot Window on Desktop launch
            Callable.From(() =>
            {
                DisplayServer.WindowSetMode(DisplayServer.WindowMode.Minimized);
            }).CallDeferred();

            _activeProcess.Exited += OnProcessExited;
            bool started = _activeProcess.Start();

            if (!started)
            {
                RestoreGodotWindow();
                return false;
            }

            // Async wait for process exit off main thread
            _ = Task.Run(async () =>
            {
                await _activeProcess.WaitForExitAsync();
            });

            return true;
        }
        catch (Exception ex)
        {
            GD.PrintErr($"Failed to launch emulator process: {ex.Message}");
            RestoreGodotWindow();
            return false;
        }
    }

    private void OnProcessExited(object? sender, EventArgs e)
    {
        _playTimer?.Stop();
        TimeSpan sessionTime = _playTimer?.Elapsed ?? TimeSpan.Zero;

        lock (_lock)
        {
            if (_activeProcess != null)
            {
                _activeProcess.Exited -= OnProcessExited;
                _activeProcess.Dispose();
                _activeProcess = null;
            }
        }

        // Restore Godot Window focus deferred to Godot Main Thread
        Callable.From(RestoreGodotWindow).CallDeferred();

        // Raise event to update game database record
        GameExited?.Invoke(this, sessionTime);
    }

    private void RestoreGodotWindow()
    {
        DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
        DisplayServer.WindowSetMode(DisplayServer.WindowMode.Maximized);
        DisplayServer.WindowMoveToForeground();
    }

    public void ForceKillActiveProcess()
    {
        lock (_lock)
        {
            if (_activeProcess is { HasExited: false })
            {
                _activeProcess.Kill(entireProcessTree: true);
            }
        }
    }
}
