$outFile = ".\output.mka"
$mergeText = ".\merge.txt"
$metadataText = ".\metadata.txt"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
$ffprobe = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffprobe.exe"

# cleanup working files
If (Test-Path $outFile){
    Remove-Item $outFile
}
If (Test-Path $mergeText){
    Remove-Item $mergeText
}
If (Test-Path $metadataText){
    Remove-Item $metadataText
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
    $duration = &$ffprobe -i "$fullPath" -show_entries format=duration -v quiet -of csv="p=0"    
    $durationSpan = New-TimeSpan -Seconds $duration

    $startTime = $totalTime
    $startSpan = New-TimeSpan -Seconds $totalTime
    
    $totalTime += $duration

    # extract metadata
    If (-not(Test-Path $metadataText)){
        Write-Host "Extract Metadata ..."
        &$ffmpeg -hide_banner -loglevel error -i "$fullPath" -f ffmetadata "$metadataText"
    }

    Write-Host $mergeFile Duration: $duration Span: $durationSpan.ToString("hh\:mm\:ss\.fff") Start: $startSpan.ToString("hh\:mm\:ss\.fff");

    # create merge and chapter files
    Add-Content $mergeText "file '$mergeFile'"
    
    Add-Content $metadataText "[CHAPTER]"
    Add-Content $metadataText "TIMEBASE=1/1000"
    Add-Content $metadataText "START=$($startTime * 1000)"
    Add-Content $metadataText "END=$($totalTime * 1000)"
    Add-Content $metadataText "title=Chapter $chapter"

    $chapter++;
}

# Step 3 Merge Files
Write-Host "Merging Files ..."
&$ffmpeg -hide_banner -loglevel warning -f concat -safe 0 -i "$mergeText" -i "$metadataText" -map_metadata 1 -c copy -attach .\image.jpg -metadata:s:t mimetype=image/jpeg "$outFile"
