$outFile = ".\output.mp3"
$mergeText = ".\merge.txt"
$Length = ".\length.txt"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"

# cleanup working files
If (Test-Path $outFile){
    Remove-Item $outFile
}
If (Test-Path $mergeText){
    Remove-Item $mergeText
}
If (Test-Path $Length){
    Remove-Item $Length
}


# Step 1 Analyze Files
Write-Host "Analyze Files ..."
$mergeFiles = Get-ChildItem ".\" -Filter "*.mp3"
$startTime = 0;
$totalTime = 0;
$chapter = 1;

foreach ($mergeFile in $mergeFiles) {
    $fullPath = $mergeFile.FullName;

    # get duration from file and convert to timespan
    $duration = ((&$mediainfocli --Inform="General;%Duration%" "$fullPath")/1000)
    
    $startTime = $totalTime
    $totalTime += $duration

    Add-Content $mergeText "file '$mergeFile'"
    Add-Content $Length $totalTime
}

# Step 3 Merge Files
Write-Host "Merging Files ..."
&$ffmpeg -hide_banner -loglevel warning -f concat -safe 0 -i "$mergeText" -acodec copy "$outFile"
