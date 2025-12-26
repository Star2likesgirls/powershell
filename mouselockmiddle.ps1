Add-Type @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class MouseLock {
    public delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelMouseProc _proc = HookCallback;
    private static IntPtr _hookID = IntPtr.Zero;

    public static void Lock() {
        _hookID = SetHook(_proc);
    }

    public static void Unlock() {
        UnhookWindowsHookEx(_hookID);
        ClipCursor(IntPtr.Zero);
    }

    private static IntPtr SetHook(LowLevelMouseProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(14, proc,
                GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        // Block ALL mouse movement + buttons
        if (nCode >= 0)
            return (IntPtr)1;
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll")]
    public static extern bool ClipCursor(ref RECT rect);

    [DllImport("user32.dll")]
    public static extern bool ClipCursor(IntPtr rect);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left, Top, Right, Bottom;
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$x = [int]($screen.Width / 2)
$y = [int]($screen.Height / 2)

$rect = New-Object MouseLock+RECT
$rect.Left = $x
$rect.Top = $y
$rect.Right = $x + 1
$rect.Bottom = $y + 1

# Hard lock
[MouseLock]::ClipCursor([ref]$rect)
[MouseLock]::Lock()

Write-Host "CURSOR HARD-LOCKED. Press CTRL+C to unlock."

try {
    while ($true) { Start-Sleep 1 }
}
finally {
    [MouseLock]::Unlock()
}
