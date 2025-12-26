# Ensure the script runs in STA mode (required for WPF)
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Write-Error "This script must be run with -STA"
    exit 1
}

Add-Type -AssemblyName PresentationFramework

# Video URL and temp path
$videoUrl = "https://github.com/Star2likesgirls/powershell/raw/refs/heads/main/pleaseinsertcoin.mp4"
$videoPath = Join-Path $env:TEMP "insertcoin.mp4"

# Download the video
$client = New-Object System.Net.WebClient
$client.DownloadFile($videoUrl, $videoPath)

# Create window
$window = New-Object Windows.Window
$window.WindowStyle = 'None'
$window.WindowState = 'Maximized'
$window.Background = 'Black'

# Create media element
$media = New-Object Windows.Controls.MediaElement
$media.Source = [Uri]$videoPath
$media.LoadedBehavior = 'Manual'
$media.Stretch = 'Fill'

# Attach media to window
$window.Content = $media

# Play video once window is rendered
$window.Add_ContentRendered({
    $media.Play()
})

# Show window
$window.ShowDialog() | Out-Null
