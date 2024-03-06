param (
    [string]$ProgressFilePath
)

while ($true) {
    if (Test-Path $ProgressFilePath) {
        try {
            $progress = Get-Content $ProgressFilePath -ErrorAction Stop
            Write-Progress -PercentComplete $progress -Status "Processing" -Activity "Deleting Empty Folders"
            
            # Check if progress is 100 and exit if true
            if ($progress -eq 100) {
                Write-Host "Task completed. Exiting..."
                Start-Sleep -Seconds 2  # Small delay to ensure the user sees the completion message
                exit
            }

        } catch {
            Write-Host "Waiting for progress update..."
        }
    } else {
        Write-Host "Progress file not found. Exiting..."
        exit
    }
    Start-Sleep -Seconds 1
}
