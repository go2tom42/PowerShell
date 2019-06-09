
###########################################################################################
################################# Media Check #############################################
###########################################################################################
<#
    A validation check on video files to make sure there are no errors with the file.

    Script use: Takes a PATH paramater to a folder for scanning media
                .\ScanMedia.ps1 "C:\Media\Videos"
                To scan media and attempt to Auto Repair files use -autorepair
                .\ScanMedia.ps1 -autorepair "C:\Media\Videos"
                To scan media and force a rescan of all files use -rescan
                .\ScanMedia.ps1 -rescan "C:\Media\Videos"
                To Change the crf Value used for encodes, change the following
                .\ScanMedia.ps1 -crf 18

    Version: 1.9.2

		Changelog:
            1.O - Initial Script creation
            1.1 - Separated the Error Log files as some could be very big
            1.2 - Incorporated an Auto-Repair function
            1.3 - Added additional logging to CSV file for easy sorting
            1.4 - Corrected issue with detecting old error logs
            1.5 - Added check to make sure ffmpeg exists and change calling behaviour
            1.6 - Implemented Join-Path to allow script to be run on non-Windows machines
            1.7 - Enable file scanned history and added a -rescan switch to force scanning
                  all files.
            1.8 - Found an Error with Get-ChildItem and -path where it wouldn't scan top
                  level folders with [] in the name. Using -LiteralPath now.
            1.9 - Fixed an issue with LiteralPath ignoring ignored extensions
            1.9.1 Changed how the auto-repair function worked to duplicate plex's optimized
                  version settings to create an x264 file to better address file errors. It
                  can now correct more issues but not everything. Added a crf argument so
                  users can now select the quality of the repaired video files.
                  Enabled autodelete on repaired files only that have failed checks
            1.9.2 Corrected issue with not getting the file size on a video file for a PASSED
                  video file. Modified the writing of the CSV into a function to remove commas
                  from file names
#>

Param (
    # Auto-repair switch for the command line to have the script attempt to auto repair media if there is an issue
    [switch]$autorepair,
    # Auto-delete switch for the command line to have the script delete media that was successfully repaired
    [switch]$autodelete,
    # Forces the script to ignore the Scan History File and forces a re-scan of all files in the path
    [switch]$rescan,
    [Parameter(Mandatory=$true)][string]$ScanPath,
    [Int]$crf = 21
)

# Excluded file types. Add more extensions that you want the scan to ignore
$exclude = ".png",".jpg",".srt",".txt",".idx",".sub",".nfo",".db",".mp3"

$fullName = ""
$fileName = ""
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scanHistory = Join-Path -path $scriptPath -childpath "ScanHistory.txt"
$Date = "$((Get-Date).ToString('yyyy-MM-dd'))"
$LogPath = Join-Path -path $scriptPath -childpath "Log_$Date"
$ffmpegLog = Join-Path -path $LogPath -childpath "ffmpegerror.log"
$Logfile = Join-Path -path $LogPath -childpath "results.log"
$CSVfile = Join-Path -path $LogPath -childpath "results.csv"
$env:PATH = $env:PATH+";."
$OrigLength = $null
$RepairLength = $null
$ScriptVersion = 1.9.2

# Funtion to write lines to a log file
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

# Function to attempt to repair a video object with ffmpeg.exe if -autorepair is selected
Function RepairFile
{
    Param ([Object]$VideoFile)

    # Get only the file name of the Video Object
    $RepairFileName = $VideoFile.Name

    # Get only the file name without the extension of the video object and remove the brackets
    $RepairFileBaseName = $VideoFile.BaseName -replace '[][]',''

    # Get all the variables to create the another file in the same directory with _repaired in the filename
    $dir = $VideoFile.DirectoryName
    $RepairVFileName = "$RepairFileBaseName" + "_repaired.mp4"
    $RepairFullName = Join-Path -path $dir -ChildPath $RepairVFileName

    Write-Host "$(Get-Date -Format o) Creating Repair File: $RepairFullName"
    LogWrite "$(Get-Date -Format o) Creating Repair File: $RepairFullName"

    $RepairFileName = $RepairFileName -replace '[][]',''
    $RepairFileName = $RepairFileName + "_repair.log"

    $errorLog = Join-Path -path $LogPath -childpath $RepairFileName

    # Attempt to repair the video file with ffmpeg

    #ffmpeg.exe -i $VideoFile.FullName -c:v copy -c:a copy $RepairFullName 2> $errorLog
    ffmpeg.exe -y -i $VideoFile.FullName -c:v libx264 -crf $crf -c:a aac -q:a 100 -strict -2 -movflags faststart -level 41 $RepairFullName 2> $errorLog

    # Check to see if the repaired file still has errors
    $RepairFile = Get-Item $RepairFullName
    CheckFile ($RepairFile) -autorepaired
}

# Function to check a supplied video object with ffmpeg.exe
Function CheckFile
{
    Param (
        [Object]$VideoFile,
        [switch]$autorepaired,
        [switch]$rescanvideo
    )

    # Get the full name of the Video Object with path included
    $fullName = $VideoFile.FullName

    # Get only the name of the video file
    $fileName = $VideoFile.Name

    # Save the length of the video file to make sure the repaired video file length matches original
    If ($autorepaired)
    {
        $RepairLength = GetLength $VideoFile
    } Else {
        $OrigLength = GetLength $VideoFile
    }

    Write-Host "$(Get-Date -Format o) Scanning File: $fullName"
    LogWrite "$(Get-Date -Format o) Scanning File: $fullName"

    # Scan the file with FFMPEG
    ffmpeg.exe -v error -i $fullName -f null - >$ffmpegLog 2>&1

    # Check to see if the ffmpeg error log was empty
    If ((Get-Content $ffmpegLog) -eq $Null )
    {   
        # Get information to log to the CSV file
        $FileSize = "{0:N2}" -f (($VideoFile | Measure-Object -property length -sum ).sum / 1MB)
        $Date = $((Get-Date).ToString('yyyy-MM-dd'))

        If ($autorepaired)
        {  

            # File is only repaired successfully if the video file length matches original
            If (($RepairLength -eq $OrigLength) -and ($RepairLength -ne $Null))
            {
                Write-Host "$(Get-Date -Format o) File Repaired Successfully: $fileName" -ForegroundColor Green
                LogWrite "$(Get-Date -Format o) File Repaired Successfully: $fullName"
                Write-CSV -VidfileName $fileName -VidfilePath $fullName -TestResults "Passed" -Date $Date -VidFileSize $FileSize -VidLength $RepairLength
            }
            Else {
                Write-Host "$(Get-Date -Format o) Error Found in Repaired File. Video Length does not match Original: $fileName" -ForegroundColor Red
                LogWrite "$(Get-Date -Format o) ERROR REPAIR: Error Found in Repaired File. Video Length does not match Original: $fullName"
                Write-CSV -VidfileName $fileName -VidfilePath $fullName -TestResults "Failed" -Date $Date -VidFileSize $FileSize -VidLength $RepairLength

                If ($autodelete)
                {
                    Write-Host "$(Get-Date -Format o) Deleting Repaired File: $fileName"
                    LogWrite "$(Get-Date -Format o) Deleting Repaired File: $fileName"
                    Remove-Item -Path $VideoFile
                }
            }

        } else {
            Write-Host "$(Get-Date -Format o) Scanned Successfully: $fileName" -ForegroundColor Green
            LogWrite "$(Get-Date -Format o) Scanned Successfully: $fullName"
            Write-CSV -VidfileName $fileName -VidfilePath $fullName -TestResults "Passed" -Date $Date -VidFileSize $FileSize -VidLength $OrigLength
        }

        # If the video file is not a rescanned file, add it to the scan history
        If (!$rescanvideo) 
        {
            Add-content $scanHistory $fullName
        }

    # Check to see if the ffmpeg error log was not empty
    } Elseif ((Get-Content $ffmpegLog) -ne $Null) 
    {
        # Get information to log to the CSV file
        $FileSize = "{0:N2}" -f (($VideoFile | Measure-Object -property length -sum ).sum / 1MB)
        $Date = $((Get-Date).ToString('yyyy-MM-dd'))

        If ($autorepaired)
        {  
            Write-Host "$(Get-Date -Format o) Error Found in Repaired File: $fileName" -ForegroundColor Red
            LogWrite "$(Get-Date -Format o) ERROR REPAIRED: Error found in Repaired File: $fullName"
            Write-CSV -VidfileName $fileName -VidfilePath $fullName -TestResults "Failed" -Date $Date -VidFileSize $FileSize -VidLength $RepairLength

            If ($autodelete)
            {
                Write-Host "$(Get-Date -Format o) Deleting Repaired File: $fileName"
                LogWrite "$(Get-Date -Format o) Deleting Repaired File: $fileName"
                Remove-Item -Path $VideoFile
            }
        } else {
            Write-Host "$(Get-Date -Format o) Error Found: $fileName" -ForegroundColor Red
            LogWrite "$(Get-Date -Format o) ERROR: Error found: $fullName"
            Write-CSV -VidfileName $fileName -VidfilePath $fullName -TestResults "Failed" -Date $Date -VidFileSize $FileSize -VidLength $OrigLength
        }

        # If the video file is not a rescanned file, add it to the scan history
        If (!$rescanvideo) 
        {
            Add-content $scanHistory $fullName
        }

        $fileName = $fileName -replace '[][]',''
        $fileName = $fileName + "_error.log"
        $errorLog = Join-Path -path $LogPath  -ChildPath $fileName

        If (Test-Path $errorLog)
        {
            Write-Host "$(Get-Date -Format o) Removing Error Log : $errorLog"
            LogWrite "$(Get-Date -Format o) Removing Error Log : $errorLog"
            Remove-Item -Path $errorLog
        }

        try {
            Rename-Item $ffmpegLog $errorLog
        } catch
        {
            $ErrorMessage = $_.Exception.Message
            Write-Host "$(Get-Date -Format o) Failed to rename the ffmpeg log" -ForegroundColor Red
            LogWrite "$(Get-Date -Format o) Failed to stop the ffmpeg log: $ErrorMessage"
            $errorLog = Join-Path -path $LogPath -childpath "GenericError.log"
            Get-Content $ffmpegLog | Add-Content $errorLog
            Remove-item $ffmpegLog
        }

        # Only contiune if the file is not already flaged as auto-repaired
        if (!$autorepaired) 
        {
            # Only continue if auto-repair is selected
            if ($autorepair)
            {
                Write-Host "$(Get-Date -Format o) Attempting to Repair : $VideoFile"
                LogWrite "$(Get-Date -Format o) Attempting to Repair : $VideoFile"
                # Supply the video object to the repair function
                RepairFile $VideoFile
            }
        }
    }
}

Function GetLength
{
    Param ([Object]$VideoFile)

    $LengthColumn = 27
    $objShell = New-Object -ComObject Shell.Application 
    $objFolder = $objShell.Namespace($VideoFile.DirectoryName)
    $objFile = $objFolder.ParseName($VideoFile.Name)
    $VideoLength = $objFolder.GetDetailsOf($objFile, $LengthColumn) 

    return $VideoLength
}

Function Write-CSV
{
    Param (
        [String]$VidfileName,
        [String]$VidfilePath,
        [String]$TestResults,
        [String]$Date,
        [String]$VidFileSize,
        [String]$VidLength
    )

    $VidfileName = $VidfileName -replace ',',''
    $VidfilePath = $VidfilePath -replace ',',''

    $CSVContent = "$VidfileName,$TestResults,$Date,$VidFileSize,$VidLength,$VidfilePath"
    try {
        Add-content $CSVfile -Value $CSVContent
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$(Get-Date -Format o) Failed to log the result to the csv file $CSVfile" -ForegroundColor Red
        LogWrite "$(Get-Date -Format o) Failed to log the result to the csv file $CSVfile : $ErrorMessage"
    }
}

# Test to see if the log directory exists and create it if not
If(!(test-Path $LogPath))
{
	New-Item -ItemType Directory -Force -Path $LogPath | Out-Null
}

Clear-Host

Write-Host "$(Get-Date -Format o) Starting script $($MyInvocation.MyCommand.Name)"
Write-Host " "

# Test the CSV file path and create the CSV with the header line if it does not exist
If (!(test-Path $CSVfile))
{
    Set-Content $CSVfile -Value "File Name,FFMPEG Test,Check Date,File Size (MB),Video Length,Location"
}

If (!(test-Path $scanHistory))
{
    Set-Content $scanHistory -Value "This is a history of all scanned items. Please do not delete or modify this file."
    Write-Host "$(Get-Date -Format o) Creating a history file: $scanHistory " 
    Write-Host "$(Get-Date -Format o) Please do not remove this file if you would like to keep a history of scanned items."
    LogWrite "$(Get-Date -Format o) Creating a history file: $scanHistory "
}

If ($autorepair)
{
    Write-Host "$(Get-Date -Format o) Auto-Repair has been enabled" -ForegroundColor Cyan
    LogWrite "$(Get-Date -Format o) Auto-Repair has been enabled"
}

If ($autodelete)
{
    Write-Host "$(Get-Date -Format o) " -ForegroundColor Cyan -NoNewline
    Write-Host "WARNING " -ForegroundColor Red -NoNewline
    Write-Host "Auto-Delete has been enabled" -ForegroundColor Cyan
    Write-Host "$(Get-Date -Format o) All repaired files that have errors will be automatically removed"
    LogWrite "$(Get-Date -Format o) Auto-Delete has been enabled"
}

If ($rescan)
{
    Write-Host "$(Get-Date -Format o) Media Rescan has been enabled. All files will be scanned." -ForegroundColor Cyan
    LogWrite "$(Get-Date -Format o) Media Rescan has been enabled. All files will be scanned."
}

# Check to see if ffmpeg exists and if it is installed on the local machine and added to path
If ((Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue) -eq $null)
{ 
    Write-Host "$(Get-Date -Format o) Unable to find ffmpeg.exe on the computer or in the local script directory" -ForegroundColor Red
    Write-Host "$(Get-Date -Format o) Please download ffmpeg and place ffmpeg.exe in: $scriptPath"
    Write-Host "$(Get-Date -Format o) Exiting Script" -ForegroundColor Red
    LogWrite "$(Get-Date -Format o) Unable to find ffmpeg.exe on the computer or in the local script directory"
    LogWrite "$(Get-Date -Format o) Please download ffmpeg and place ffmpeg.exe in: $scriptPath"
    LogWrite "$(Get-Date -Format o) Exiting Script"
    Exit
}

Write-Host "$(Get-Date -Format o) Begining Scan on $ScanPath"
LogWrite "###########################################################"
LogWrite "$(Get-Date -Format o) Begining Scan on $ScanPath"
LogWrite "###########################################################"

LogWrite "$(Get-Date -Format o) Script Version is $ScriptVersion"

# Get all the child items of the supplied directory and attempt to scan the files with the function CheckFile
Get-ChildItem -LiteralPath $ScanPath -File -Recurse | Where-Object { $exclude -notcontains $_.Extension } | % {

    # Check the scan history file to see if the file has been scanned
    $scanHistoryCheck = (Get-Content $scanHistory | Select-String -pattern $_.FullName -SimpleMatch)

    # If the file exists in the scan history and rescan has not been enabled, skip
    If (($scanHistoryCheck -ne $null) -and ($rescan -eq $false))
    {
        Write-Host "$(Get-Date -Format o) Skipping scanned file:" $_.Name
        LogWrite "$(Get-Date -Format o) Skipping scanned file:" $_.Name
    }
    # If the file exists in the scan history and rescan has been  enabled, scan the file
    Elseif (($scanHistoryCheck -ne $null) -and ($rescan -eq $true)) 
    {
        CheckFile $_ -rescanvideo
    } 
    Else 
    {
        CheckFile $_
    }
}

Write-Host "$(Get-Date -Format o) Scan Complete. Open Log file for details: $Logfile"
LogWrite "$(Get-Date -Format o) Scan Complete."