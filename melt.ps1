Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ================== MINIMIZE ALL WINDOWS ==================
Add-Type @'
using System;
using System.Runtime.InteropServices;

public class User32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@

$SW_MINIMIZE = 6
[User32]::EnumWindows({
    param($hWnd, $lParam)
    [User32]::ShowWindow($hWnd, $SW_MINIMIZE) | Out-Null
    $true
}, [IntPtr]::Zero)

Start-Sleep -Milliseconds 200

# ================== GDI ==================
Add-Type @'
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
        int h, int w, int e, int o, int weight,
        uint it, uint un, uint st, uint cs,
        uint op, uint cp, uint q, uint pf, string face
    );

    [DllImport("gdi32.dll")]
    public static extern IntPtr SelectObject(IntPtr hdc, IntPtr obj);

    [DllImport("gdi32.dll")]
    public static extern bool TextOut(
        IntPtr hdc, int x, int y, string s, int len
    );
}
'@

# ================== SCREEN ==================
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$w = $screen.Width
$h = $screen.Height
$hdc = [GDI]::GetDC([IntPtr]::Zero)

Write-Host 'MELTDOWN RUNNING'

# ================== SOUND ==================
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
        Start-Sleep -Milliseconds 1
    }
} -ArgumentList ($sounds)

# ================== TEXT ==================
$text = 'weedhack'
$font = [GDI]::CreateFont(48,0,0,0,800,0,0,0,0,0,0,0,0,'Consolas')
[GDI]::SelectObject($hdc, $font) | Out-Null

# ================== MELT LOOP ==================
try {
    while ($true) {

        $sliceX = Get-Random -Minimum 0 -Maximum $w
        $sliceW = Get-Random -Minimum 4 -Maximum 16
        $drop   = Get-Random -Minimum 4 -Maximum 25

        [GDI]::BitBlt(
            $hdc,
            $sliceX,
            $drop,
            $sliceW,
            $h,
            $hdc,
            $sliceX,
            0,
            0x00CC0020
        ) | Out-Null

        [GDI]::TextOut($hdc, 50, 50, $text, $text.Length) | Out-Null

        Start-Sleep -Milliseconds 1
    }
}
finally {
    [GDI]::ReleaseDC([IntPtr]::Zero, $hdc)
    Stop-Job $soundJob
    Remove-Job $soundJob
}
