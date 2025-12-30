Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION ---
$PARTICLE_COUNT = 60
$TIMER_INTERVAL = 30

# Download audio FIRST
$audioUrl = "https://github.com/Star2likesgirls/powershell/raw/refs/heads/main/nostalgic-melody-piano-vocals-bass-soft-loop_73bpm_A%23.wav"
$tempAudioPath = [System.IO.Path]::Combine($env:TEMP, "euphoric_dream.wav")

Write-Host "Downloading audio..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
try {
    if (-not (Test-Path $tempAudioPath)) {
        (New-Object System.Net.WebClient).DownloadFile($audioUrl, $tempAudioPath)
    }
    Write-Host "Audio ready!"
} catch {
    Write-Warning "Could not download audio. Continuing without sound."
}

# Start playing audio
if (Test-Path $tempAudioPath) {
    $audioPlayer = New-Object System.Media.SoundPlayer
    $audioPlayer.SoundLocation = $tempAudioPath
    $audioPlayer.Load()
    $audioPlayer.PlayLooping()
}

# Keyboard hook
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class KeyboardHook {
    public delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);
    
    [DllImport("user32.dll")]
    public static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern bool UnhookWindowsHookEx(IntPtr hhk);
}
"@

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Euphoric Dreams"
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 10, 30)
$form.TopMost = $true
$form.Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# CRITICAL: Proper double buffering setup
$form.DoubleBuffered = $true
$formType = $form.GetType()
$doubleBufferPropertyInfo = $formType.GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic)
$doubleBufferPropertyInfo.SetValue($form, $true, $null)

# Global variables
$script:counter = 0
$script:hookPtr = [IntPtr]::Zero
$script:particles = @()

# Initialize particles
for ($i = 0; $i -lt $PARTICLE_COUNT; $i++) {
    $script:particles += @{
        x = Get-Random -Minimum 0 -Maximum $form.Width
        y = Get-Random -Minimum 0 -Maximum $form.Height
        vx = (Get-Random -Minimum -2.0 -Maximum 2.0)
        vy = (Get-Random -Minimum -2.0 -Maximum 2.0)
        size = Get-Random -Minimum 2 -Maximum 8
        hue = Get-Random -Minimum 0.0 -Maximum 360.0
    }
}

# Install keyboard hook
$hookProc = [KeyboardHook+HookProc] {
    param($nCode, $wParam, $lParam)
    if ($nCode -ge 0) {
        $vkCode = [Runtime.InteropServices.Marshal]::ReadInt32($lParam)
        if ($vkCode -ne 35) {
            return [IntPtr]1
        }
    }
    return [KeyboardHook]::CallNextHookEx([IntPtr]::Zero, $nCode, $wParam, $lParam)
}
$script:hookPtr = [KeyboardHook]::SetWindowsHookEx(13, $hookProc, [IntPtr]::Zero, 0)

# HSV to RGB
function HSVtoRGB($h, $s, $v) {
    $c = $v * $s
    $x = $c * (1 - [Math]::Abs((($h / 60) % 2) - 1))
    $m = $v - $c
    
    $rp = 0; $gp = 0; $bp = 0
    if ($h -lt 60) { $rp = $c; $gp = $x; $bp = 0 }
    elseif ($h -lt 120) { $rp = $x; $gp = $c; $bp = 0 }
    elseif ($h -lt 180) { $rp = 0; $gp = $c; $bp = $x }
    elseif ($h -lt 240) { $rp = 0; $gp = $x; $bp = $c }
    elseif ($h -lt 300) { $rp = $x; $gp = 0; $bp = $c }
    else { $rp = $c; $gp = 0; $bp = $x }
    
    return [System.Drawing.Color]::FromArgb(255, [int](($rp + $m) * 255), [int](($gp + $m) * 255), [int](($bp + $m) * 255))
}

# Pre-allocate
$global:infoFont = [System.Drawing.Font]::new("Arial", 12, [System.Drawing.FontStyle]::Bold)

# Paint event
$form.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    
    # CRITICAL FIX: Clear entire canvas first with solid color
    $g.Clear([System.Drawing.Color]::FromArgb(20, 10, 30))
    
    # Set rendering modes AFTER clear
    $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighSpeed
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighSpeed
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::Low
    
    $width = $form.ClientSize.Width
    $height = $form.ClientSize.Height
    $t = $script:counter * 0.01

    # 1. Background Gradient
    $c1 = HSVtoRGB (($t * 10) % 360) 0.3 0.15
    $c2 = HSVtoRGB ((($t * 10) + 180) % 360) 0.3 0.25
    
    $gradBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Point]::new(0, 0),
        [System.Drawing.Point]::new($width, $height),
        $c1, $c2
    )
    $g.FillRectangle($gradBrush, 0, 0, $width, $height)
    $gradBrush.Dispose()

    # Enable AntiAlias for shapes
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # 2. Floating Orbs
    for ($i = 0; $i -lt 8; $i++) {
        $angle = ($script:counter * 0.015 + $i * 0.5)
        $radius = 150 + [Math]::Sin($script:counter * 0.02 + $i) * 80
        $cx = ($width / 2) + ([Math]::Cos($angle) * $radius)
        $cy = ($height / 2) + ([Math]::Sin($angle) * $radius)
        $orbSize = 40 + [Math]::Sin($script:counter * 0.03 + $i * 0.7) * 20
        
        $col = HSVtoRGB (($script:counter * 2 + $i * 30) % 360) 0.8 1.0
        
        # Glow first (draw behind)
        $glowColor = [System.Drawing.Color]::FromArgb(60, $col)
        $b2 = [System.Drawing.SolidBrush]::new($glowColor)
        $glowSize = $orbSize + 20
        $g.FillEllipse($b2, $cx - $glowSize/2, $cy - $glowSize/2, $glowSize, $glowSize)
        $b2.Dispose()
        
        # Core orb on top
        $brushColor = [System.Drawing.Color]::FromArgb(200, $col)
        $b1 = [System.Drawing.SolidBrush]::new($brushColor)
        $g.FillEllipse($b1, $cx - $orbSize/2, $cy - $orbSize/2, $orbSize, $orbSize)
        $b1.Dispose()
    }

    # 3. Ribbons
    for ($i = 0; $i -lt 4; $i++) {
        $points = @()
        for ($x = 0; $x -lt $width; $x += 100) {
            $y = ($height / 2) + ([Math]::Sin(($x * 0.01) + $t * 5 + $i) * 80) + ($i * 50 - 100)
            $points += [System.Drawing.PointF]::new($x, $y)
        }
        
        if ($points.Count -gt 2) {
            $col = HSVtoRGB (($script:counter + $i * 72) % 360) 0.7 0.9
            $penColor = [System.Drawing.Color]::FromArgb(120, $col)
            $pen = [System.Drawing.Pen]::new($penColor, 6)
            $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
            $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
            $g.DrawCurve($pen, $points)
            $pen.Dispose()
        }
    }

    # 4. Particles
    foreach ($p in $script:particles) {
        $col = HSVtoRGB $p.hue 0.9 1.0
        $brushColor = [System.Drawing.Color]::FromArgb(180, $col)
        $brush = [System.Drawing.SolidBrush]::new($brushColor)
        $g.FillEllipse($brush, $p.x, $p.y, $p.size, $p.size)
        $brush.Dispose()
    }

    # 5. Mandalas
    for ($layer = 0; $layer -lt 2; $layer++) {
        $points = 6
        $radius = 200 + ($layer * 100) + ([Math]::Sin($t * 4 + $layer) * 30)
        
        $col = HSVtoRGB (($script:counter + $layer * 60) % 360) 0.6 0.8
        $penColor = [System.Drawing.Color]::FromArgb(80, $col)
        $pen = [System.Drawing.Pen]::new($penColor, 2)

        for ($i = 0; $i -lt $points; $i++) {
            $a1 = ($i / $points) * [Math]::PI * 2 + $t
            $x1 = ($width / 2) + ([Math]::Cos($a1) * $radius)
            $y1 = ($height / 2) + ([Math]::Sin($a1) * $radius)
            $g.DrawLine($pen, $x1, $y1, $width/2, $height/2)
        }
        $pen.Dispose()
    }

    # 6. Radial burst
    $burstPoints = 12
    for ($i = 0; $i -lt $burstPoints; $i++) {
        $angle = ($i / $burstPoints) * [Math]::PI * 2
        $pulse = [Math]::Sin($script:counter * 0.05 + ($i * 0.2))
        $length = 100 + ($pulse * 80)
        
        $x1 = $width / 2
        $y1 = $height / 2
        $x2 = $x1 + ([Math]::Cos($angle) * $length)
        $y2 = $y1 + ([Math]::Sin($angle) * $length)
        
        $hue = (($script:counter * 5 + $i * 30) % 360)
        $col = HSVtoRGB $hue 0.7 1.0
        $alpha = [int](40 + ($pulse * 60))
        $penColor = [System.Drawing.Color]::FromArgb($alpha, $col)
        $pen = [System.Drawing.Pen]::new($penColor, 2)
        $g.DrawLine($pen, $x1, $y1, $x2, $y2)
        $pen.Dispose()
    }

    # 7. Bokeh circles
    for ($i = 0; $i -lt 15; $i++) {
        $speed = 0.005 + ($i * 0.001)
        $x = $width / 2 + ([Math]::Cos($script:counter * $speed + $i) * ($width * 0.4))
        $y = $height / 2 + ([Math]::Sin($script:counter * $speed * 1.3 + $i) * ($height * 0.4))
        $size = 20 + [Math]::Sin($script:counter * 0.02 + $i) * 15
        
        $hue = (($script:counter * 3 + $i * 24) % 360)
        $col = HSVtoRGB $hue 0.5 0.9
        $brushColor = [System.Drawing.Color]::FromArgb(60, $col)
        $brush = [System.Drawing.SolidBrush]::new($brushColor)
        $g.FillEllipse($brush, $x - $size/2, $y - $size/2, $size, $size)
        $brush.Dispose()
    }

    # 8. Text
    $g.DrawString(">>> made by starrydev! <<<", $global:infoFont, [System.Drawing.Brushes]::White, 20, $height - 40)
})

# Timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $TIMER_INTERVAL
$timer.Add_Tick({
    $script:counter++
    $w = $form.ClientSize.Width
    $h = $form.ClientSize.Height
    
    foreach ($p in $script:particles) {
        $p.x += $p.vx
        $p.y += $p.vy
        $p.hue = ($p.hue + 0.5) % 360
        
        if ($p.x -lt 0) { $p.x = $w } elseif ($p.x -gt $w) { $p.x = 0 }
        if ($p.y -lt 0) { $p.y = $h } elseif ($p.y -gt $h) { $p.y = 0 }
        
        # Gentle center attraction
        $dx = ($w / 2) - $p.x
        $dy = ($h / 2) - $p.y
        $p.vx += $dx * 0.00005
        $p.vy += $dy * 0.00005
    }
    $form.Invalidate()
})

# Input
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "End") {
        $form.Close()
    }
})

$form.Add_FormClosing({
    $timer.Stop()
    $timer.Dispose()
    if ($audioPlayer) { $audioPlayer.Stop(); $audioPlayer.Dispose() }
    if ($script:hookPtr -ne [IntPtr]::Zero) { [KeyboardHook]::UnhookWindowsHookEx($script:hookPtr) }
    if ($global:infoFont) { $global:infoFont.Dispose() }
})

# Launch
$timer.Start()
[void]$form.ShowDialog()
$form.Dispose()
