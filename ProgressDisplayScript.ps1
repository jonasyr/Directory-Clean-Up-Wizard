param (
    [string]$ProgressFilePath
)

while ($true) {
    if (Test-Path $ProgressFilePath) {
        try {
            $progress = Get-Content $ProgressFilePath -ErrorAction Stop
            Write-Progress -PercentComplete $progress -Status "Processing" -Activity "Deleting Empty Folders"
        } catch {
            Write-Host "Waiting for progress update..."
        }
    } else {
        Write-Host "Progress file not found. Exiting..."
        break
    }
    Start-Sleep -Seconds 1
}
