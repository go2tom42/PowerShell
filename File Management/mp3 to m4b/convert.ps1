$outFile = ".\output.m4a"
$mergeText = ".\merge.txt"
$metadataText = ".\metadata.txt"

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

# Step 1 Convert Files 
Write-Host "Convert Files ..."
$convertFiles = Get-ChildItem ".\" -Filter "*.mp3"
foreach ($convertFile in $convertFiles) {
    $originalFile = $convertFile.FullName;
    $convertedFile = [IO.Path]::ChangeExtension($originalFile, ".m4a");

    if (-not (Test-Path $convertedFile)) {
        Write-Host "Converting $convertFile ...";
        &"D:\Convert\Tools\ffmpeg\bin\ffmpeg.exe" -hide_banner -loglevel warning -i "$originalFile" -c:a aac -b:a 32k -ar 22050 -ac 1 -vn -y "$convertedFile"
    }
}

# Step 2 Analyze Files
Write-Host "Analyze Files ..."
$mergeFiles = Get-ChildItem ".\" -Filter "*.m4a"
$startTime = 0;
$totalTime = 0;
$chapter = 1;

foreach ($mergeFile in $mergeFiles) {
    $fullPath = $mergeFile.FullName;

    # get duration from file and convert to timespan
    $duration = &"D:\Convert\Tools\ffmpeg\bin\ffprobe.exe" -i "$fullPath" -show_entries format=duration -v quiet -of csv="p=0"    
    $durationSpan = New-TimeSpan -Seconds $duration

    $startTime = $totalTime
    $startSpan = New-TimeSpan -Seconds $totalTime
    
    $totalTime += $duration

    # extract metadata
    If (-not(Test-Path $metadataText)){
        Write-Host "Extract Metadata ..."
        &"D:\Convert\Tools\ffmpeg\bin\ffmpeg.exe" -hide_banner -loglevel error -i "$fullPath" -f ffmetadata "$metadataText"
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
&"D:\Convert\Tools\ffmpeg\bin\ffmpeg.exe" -hide_banner -loglevel warning -f concat -safe 0 -i "$mergeText" -i "$metadataText" -map_metadata 1 -c copy "$outFile"
