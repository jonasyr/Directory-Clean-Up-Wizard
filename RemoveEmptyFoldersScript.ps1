# Initial prompt for the user to choose the mode of operation
Write-Host "Select the mode of operation:"
Write-Host "1 - Non-recursive (Delete top-level empty folders only)"
Write-Host "2 - Recursive (Delete all empty subfolders as well)"
$modeSelection = Read-Host "Enter your choice (1 or 2)"

if ($modeSelection -ne '1' -and $modeSelection -ne '2') {
    Write-Host "Invalid selection. Exiting script."
    exit
}

# Before starting the folder processing
$global:startTime = Get-Date
$global:foldersProcessed = 0
$global:foldersDeleted = 0

# Prompt the user for the path and confirmation
$rootPath = Read-Host "Please enter the path to check (e.g., C:\Users\USERNAME\Downloads)"
$confirmation = Read-Host "You have entered '$rootPath'. Do you want to proceed? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled."
    exit
}

# Prepare the progress file path and log directory based on the script's location
$scriptLocation = $PSScriptRoot
$progressFilePath = Join-Path -Path $scriptLocation -ChildPath "progress.txt"
$logDir = Join-Path -Path $scriptLocation -ChildPath "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir
}

# Ensure progress file is cleared at start
if (Test-Path $progressFilePath) {
    Remove-Item $progressFilePath
}

# Generate a logfile name based on the date and root path
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$rootPathName = [System.IO.Path]::GetFileName($rootPath).Replace(':', '-').Replace('\', '-').Replace('/', '-')
$logFileName = "$date" + "_" + "$rootPathName" + ".txt"
$logFilePath = Join-Path $logDir $logFileName

# Automatically start the ProgressDisplayScript in a new window and capture the process
$scriptPath = Join-Path -Path $scriptLocation -ChildPath "ProgressDisplayScript.ps1"
$command = "& `"$scriptPath`" -ProgressFilePath `"$progressFilePath`""
$encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
$process = Start-Process powershell.exe -ArgumentList "-NoExit", "-EncodedCommand $encodedCommand" -PassThru


function Remove-EmptyFoldersNonRecursive {
    param (
        [string]$path
    )

    $localItems = Get-ChildItem -Path $path -Directory
    $localTotalFolders = $localItems.Count
    $localProcessedFolders = 0

    foreach ($item in $localItems) {
        $localProcessedFolders++
        # Check if the directory is empty
        if ((Get-ChildItem -Path $item.FullName).Count -eq 0) {
            Remove-Item $item.FullName -Force
            Write-Host "Deleted empty folder: $($item.FullName)"
            "$($item.FullName)" | Out-File -FilePath $logFilePath -Append -Encoding ASCII
            $global:foldersDeleted++
        }
        $percentComplete = [math]::Round(($localProcessedFolders / $localTotalFolders) * 100, 2)
        "$percentComplete" | Out-File $progressFilePath -Force -Encoding ASCII
    }
    $global:foldersProcessed += $localProcessedFolders
}


function Remove-EmptyFolders {
    param (
        [string]$path,
        [int]$totalFolders,
        [ref]$processedFolders
    )

    # Check current folder and increment foldersProcessed
    $global:foldersProcessed++

    # Initialize an indication that the current folder is initially assumed empty
    $isEmpty = $true

    # Get all items in the current directory
    $items = Get-ChildItem -Path $path

    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            # Recursively check this directory
            Remove-EmptyFolders -path $item.FullName -totalFolders $totalFolders -processedFolders $processedFolders
            # If the directory still exists, it was not empty
            if (Test-Path $item.FullName) {
                $isEmpty = $false
             
            }
        } else {
            # Found a file, so this directory is not empty
            $isEmpty = $false
            
        }
    }

    # If the directory is empty after checking its contents, delete it
    if ($isEmpty) {
        Remove-Item $path -Force
        Write-Host "Deleted empty folder: $path"
        # Log the deleted folder path to the logfile
        "$path" | Out-File -FilePath $logFilePath -Append -Encoding ASCII
        $global:foldersDeleted++
    }

    # Do not increment the processedFolders here as it's handled outside this function for top-level folders only
}

# Based on the mode selection, choose the operation
if ($modeSelection -eq '1') {
    Remove-EmptyFoldersNonRecursive -path $rootPath
} else {
    # Calculate total number of top-level folders for progress calculation
    $topLevelFolders = (Get-ChildItem -Path $rootPath -Directory).Count
    $processedFolders = [ref]0

    # Process each top-level folder and update progress
    Get-ChildItem -Path $rootPath -Directory | ForEach-Object {
        Remove-EmptyFolders -path $_.FullName -totalFolders $topLevelFolders -processedFolders $processedFolders

        # Increment the processedFolders counter here, after each top-level folder is fully processed
        $processedFolders.Value++
        $percentComplete = [math]::Round(($processedFolders.Value / $topLevelFolders) * 100, 2)
        "$percentComplete" | Out-File $progressFilePath -Force -Encoding ASCII
    }
}


# After processing all folders:
Write-Host "All folders processed."

# After processing all folders and just before closing the progress display script
$endTime = Get-Date
$duration = $endTime - $startTime
$summary = @"
StartTime: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))
EndTime: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))
Finished in: $($duration.Hours)h $($duration.Minutes)m $($duration.Seconds)s
Folders processed: $global:foldersProcessed
Folders deleted: $global:foldersDeleted
"@

# Append summary to the log file
$summary | Out-File -FilePath $logFilePath -Append -Encoding ASCII

Write-Host $summary

# Give the progress script a moment to update one last time if needed
Start-Sleep -Seconds 2

# Now close the ProgressDisplayScript window
if ($process) {
    Stop-Process -Id $process.Id -Force
}

# Delete the progress.txt file
Remove-Item $progressFilePath -Force
