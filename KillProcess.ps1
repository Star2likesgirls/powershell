# KillProcess.ps1
# This script kills a process by name

# Specify the process name (without .exe)
$processName = "Taskmgr"

# Get the process
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process) {
    # Kill the process
    $process | Stop-Process -Force
    Write-Host "$processName has been terminated."
} else {
    Write-Host "Process $processName not found."
}
