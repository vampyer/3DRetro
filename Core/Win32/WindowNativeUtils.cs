using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;

namespace EmulationMenu.Core.Win32;

/// <summary>
/// Win32 Native Interop Helper for Windows Desktop Emulation Frontend.
/// Manages window focus, borderless state, OS taskbar hiding, and process safety.
/// </summary>
public static class WindowNativeUtils
{
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    public const int SW_HIDE = 0;
    public const int SW_SHOW = 5;
    public const int SW_MINIMIZE = 6;
    public const int SW_RESTORE = 9;

    public static readonly IntPtr HWND_TOPMOST = new(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new(-2);
    public const uint SWP_SHOWWINDOW = 0x0040;

    /// <summary>
    /// Forces a target process window into the foreground on Windows.
    /// </summary>
    public static void FocusProcessWindow(Process process)
    {
        if (process.MainWindowHandle != IntPtr.Zero)
        {
            ShowWindow(process.MainWindowHandle, SW_RESTORE);
            SetForegroundWindow(process.MainWindowHandle);
        }
    }

    /// <summary>
    /// Minimizes or restores Godot's window natively via DisplayServer.
    /// </summary>
    public static void SetGodotWindowMode(DisplayServer.WindowMode mode)
    {
        Callable.From(() =>
        {
            DisplayServer.WindowSetMode(mode);
        }).CallDeferred();
    }
}
