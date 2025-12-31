Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- AUDIO SETUP ---
$audioUrl = "https://github.com/Star2likesgirls/powershell/raw/refs/heads/main/dariacore-full-breakbeat_155bpm_A%23_minor.wav"
$tempAudio = "$env:TEMP\weedhack_audio.wav"
if (-not (Test-Path $tempAudio)) {
    try { (New-Object System.Net.WebClient).DownloadFile($audioUrl, $tempAudio) } catch {}
}
if (-not ([System.Management.Automation.PSTypeName]'WinSound').Type) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinSound {
        [DllImport("winmm.dll")] public static extern bool PlaySound(string pszSound, IntPtr hmod, uint fdwSound);
    }
"@
}
[WinSound]::PlaySound($tempAudio, [IntPtr]::Zero, 0x20009)

# --- FORM SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.BackColor = 'Black'
$form.FormBorderStyle = 'None'
$form.WindowState = 'Maximized'
$form.TopMost = $true
$form.DoubleBuffered = $true

# --- MATRIX RAIN SETUP ---
$script:columns = @()
$script:chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$#@%&*"
$random = New-Object System.Random
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$charWidth = 20

# Initialize columns
for ($i = 0; $i -lt ($screenWidth / $charWidth); $i++) {
    $script:columns += New-Object PSObject -Property @{
        X = $i * $charWidth
        Y = $random.Next(-$screenHeight, 0)
        Speed = $random.Next(5, 15)
        Value = ""
    }
}

$script:angle = 0

# Interconnected Weed Leaf Vertices
$v = @(
    @(0, 0, 0), @(0, -2.5, 0), @(-0.5, -0.8, 0.1), @(-1.8, -1.8, 0.2), @(-0.9, -0.2, 0.1), 
    @(-2.4, -0.4, 0.1), @(-0.8, 0.5, 0.1), @(-1.6, 1.4, 0), @(0.5, -0.8, 0.1), @(1.8, -1.8, 0.2), 
    @(0.9, -0.2, 0.1), @(2.4, -0.4, 0.1), @(0.8, 0.5, 0.1), @(1.6, 1.4, 0), @(0, 0.5, 0), @(0, 2.2, -0.1)
)

$e = @(
    @(0,2), @(2,1), @(1,8), @(8,0), @(0,4), @(4,3), @(3,2), @(0,6), @(6,5), @(5,4),
    @(0,14), @(14,7), @(7,6), @(0,10), @(10,9), @(9,8), @(0,12), @(12,11), @(11,10),
    @(14,13), @(13,12), @(14,15)
)

$form.Add_Paint({
    param($sender, $paintEv)
    $g = $paintEv.Graphics
    
    # 1. DRAW MATRIX RAIN (Background)
    $matrixFont = New-Object System.Drawing.Font("Consolas", 12)
    $matrixBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 70, 0)) # Darker Green
    
    foreach ($col in $script:columns) {
        $char = $script:chars[$random.Next(0, $script:chars.Length)]
        $g.DrawString($char, $matrixFont, $matrixBrush, $col.X, $col.Y)
        
        $col.Y += $col.Speed
        if ($col.Y -gt $screenHeight) {
            $col.Y = -20
            $col.Speed = $random.Next(5, 15)
        }
    }

    # 2. DRAW SPINNING LEAF (Foreground)
    $g.SmoothingMode = 'AntiAlias'
    $cx = $form.ClientSize.Width / 2
    $cy = $form.ClientSize.Height / 2
    $scale = [Math]::Min($cx, $cy) / 3.5
    $rad = $script:angle * [Math]::PI / 180
    $cos = [Math]::Cos($rad); $sin = [Math]::Sin($rad)

    $pMain = New-Object System.Drawing.Pen([System.Drawing.Color]::Lime, 3)
    $pGlow = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 0, 255, 0), 10)

    foreach ($edge in $e) {
        $v1 = $v[$edge[0]]; $v2 = $v[$edge[1]]
        $x1 = ($v1[0] * $cos - $v1[2] * $sin) * $scale + $cx
        $y1 = $v1[1] * $scale + $cy
        $x2 = ($v2[0] * $cos - $v2[2] * $sin) * $scale + $cx
        $y2 = $v2[1] * $scale + $cy
        $g.DrawLine($pGlow, [float]$x1, [float]$y1, [float]$x2, [float]$y2)
        $g.DrawLine($pMain, [float]$x1, [float]$y1, [float]$x2, [float]$y2)
    }

    # 3. DRAW TEXT
    $font = New-Object System.Drawing.Font("Impact", 80)
    $tSize = $g.MeasureString("WEEDHACK", $font)
    $g.DrawString("WEEDHACK", $font, [System.Drawing.Brushes]::Lime, ($cx - $tSize.Width/2), ($cy + $scale + 40))
    
    $pMain.Dispose(); $pGlow.Dispose(); $font.Dispose(); $matrixFont.Dispose(); $matrixBrush.Dispose()
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$timer.Add_Tick({ $script:angle += 2; $form.Invalidate() })
$timer.Start()

$form.Add_KeyDown({ if ($_.KeyCode -eq 'Escape') { $form.Close() } })
[void]$form.ShowDialog()
