Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = "None"
$form.WindowState = "Maximized"
$form.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$form.TopMost = $true
$form.DoubleBuffered = $true
$container = New-Object System.Windows.Forms.Panel
$container.Dock = "Fill"
$form.Controls.Add($container)
$layout = New-Object System.Windows.Forms.TableLayoutPanel
$layout.AutoSize = $true
$layout.ColumnCount = 1
$layout.RowCount = 4
$layout.BackColor = $form.BackColor
$container.Controls.Add($layout)
$form.Add_Resize({
    $layout.Left = ($container.Width  - $layout.Width)  / 2
    $layout.Top  = ($container.Height - $layout.Height) / 2
})
$spinnerPanel = New-Object System.Windows.Forms.Panel
$spinnerPanel.Width = 120
$spinnerPanel.Height = 40
$spinnerPanel.Anchor = "None"
$title = New-Object System.Windows.Forms.Label
$title.Text = "Working on updates"
$title.Font = New-Object System.Drawing.Font("Segoe UI",18)
$title.ForeColor = "White"
$title.AutoSize = $true
$title.Anchor = "None"
$status = New-Object System.Windows.Forms.Label
$status.Text = "0% complete"
$status.Font = New-Object System.Drawing.Font("Segoe UI",16)
$status.ForeColor = "White"
$status.AutoSize = $true
$status.Anchor = "None"
$footer = New-Object System.Windows.Forms.Label
$footer.Text = "Don't turn off your computer"
$footer.Font = New-Object System.Drawing.Font("Segoe UI",14)
$footer.ForeColor = "White"
$footer.AutoSize = $true
$footer.Anchor = "None"
$layout.Controls.Add($spinnerPanel)
$layout.Controls.Add($title)
$layout.Controls.Add($status)
$layout.Controls.Add($footer)
$script:dotIndex = 0
$spinnerPanel.Add_Paint({
    param($s,$e)
    $e.Graphics.SmoothingMode = "AntiAlias"
    $e.Graphics.Clear($form.BackColor)

    for ($i = 0; $i -lt 8; $i++) {
        $alpha = if ($i -eq $script:dotIndex) { 255 } else { 70 }
        $brush = New-Object System.Drawing.SolidBrush(
            [System.Drawing.Color]::FromArgb($alpha,255,255,255)
        )

        $angle = $i * 45 * [Math]::PI / 180
        $x = 55 + [Math]::Cos($angle) * 12
        $y = 15 + [Math]::Sin($angle) * 12

        $e.Graphics.FillEllipse($brush,$x,$y,6,6)
        $brush.Dispose()
    }
})

# Spinner timer
$spinnerTimer = New-Object System.Windows.Forms.Timer
$spinnerTimer.Interval = 100
$spinnerTimer.Add_Tick({
    $script:dotIndex = ($script:dotIndex + 1) % 8
    $spinnerPanel.Invalidate()
})
$spinnerTimer.Start()
$script:percent = 0
$percentTimer = New-Object System.Windows.Forms.Timer
$percentTimer.Interval = 6900
$percentTimer.Add_Tick({
    if ($script:percent -lt 100) {
        $script:percent++
        $status.Text = "$script:percent% complete"
    }
    else {
        $percentTimer.Stop()
        $spinnerTimer.Stop()
        $layout.Controls.Clear()

        $troll = New-Object System.Windows.Forms.Label
        $troll.Text = "weedhack premium is in your system!"
        $troll.Font = New-Object System.Drawing.Font("Segoe UI",48,[System.Drawing.FontStyle]::Bold)
        $troll.ForeColor = "White"
        $troll.AutoSize = $true

        $layout.Controls.Add($troll)
        $form.Refresh()
    }
})
$percentTimer.Start()

$form.ShowDialog()
