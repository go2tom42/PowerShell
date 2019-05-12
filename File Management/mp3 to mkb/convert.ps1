$outFile = ".\output.mka"
$mergeText = ".\merge.txt"
$metadataText = ".\metadata.txt"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"

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
    $duration = ((&$mediainfocli --Inform="General;%Duration%" "$fullPath")/1000)
    
    $startTime = $totalTime
    $totalTime += $duration

    # extract metadata
    If (-not(Test-Path $metadataText)){
        Write-Host "Extract Metadata ..."
        &$ffmpeg -hide_banner -loglevel error -i "$fullPath" -f ffmetadata "$metadataText"
    }



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
