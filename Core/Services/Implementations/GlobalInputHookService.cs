using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace EmulationMenu.Core.Services.Implementations;

/// <summary>
/// Global Win32 Input Hook Service.
/// Listens for emergency exit hotkeys (e.g. Alt + Esc, Ctrl + Q, or Gamepad shortcuts)
/// while an external emulator process is active, allowing seamless termination and return to Godot.
/// </summary>
public class GlobalInputHookService : IDisposable
{
    [DllImport("user32.dll")]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    private const int HOTKEY_ID = 9000;
    private const uint MOD_ALT = 0x0001;
    private const uint MOD_CONTROL = 0x0002;
    private const uint VK_ESCAPE = 0x1B; // ESC key
    private const uint VK_Q = 0x51;      // Q key

    public event EventHandler? EmergencyExitRequested;

    private bool _isListening;
    private CancellationTokenSource? _cts;

    public void StartMonitoring(Process emulatorProcess)
    {
        if (_isListening) return;
        _isListening = true;
        _cts = new CancellationTokenSource();

        _ = Task.Run(async () =>
        {
            while (!_cts.Token.IsCancellationRequested && !emulatorProcess.HasExited)
            {
                // Check if emergency shortcut key (Alt + Esc or Ctrl + Q) is pressed
                if ((GetAsyncKeyState(0x12) < 0 && GetAsyncKeyState(0x1B) < 0) || // Alt + Esc
                    (GetAsyncKeyState(0x11) < 0 && GetAsyncKeyState(0x51) < 0))    // Ctrl + Q
                {
                    EmergencyExitRequested?.Invoke(this, EventArgs.Empty);
                    break;
                }

                await Task.Delay(100, _cts.Token);
            }
            _isListening = false;
        });
    }

    [DllImport("user32.dll")]
    private static extern short GetAsyncKeyState(int vKey);

    public void StopMonitoring()
    {
        _cts?.Cancel();
        _isListening = false;
    }

    public void Dispose()
    {
        StopMonitoring();
        _cts?.Dispose();
        GC.SuppressFinalize(this);
    }
}
