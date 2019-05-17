#$mergeText = ".\merge.txt"
$metadataText = ".\metadata.txt"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"

# cleanup working files


Write-Host "Analyze Files ..."
$mergeFiles = Get-ChildItem ".\" -Filter "*.mp3"
foreach ($mergeFile in $mergeFiles) {
    $fullPath = $mergeFile.FullName;
    $outFile = $mergeFile.Name + ".mka"
    If (Test-Path $metadataText) {
        Remove-Item $metadataText
    }

    If (-not(Test-Path $metadataText)) {
        Write-Host "Extract Metadata ..."
        &$ffmpeg -hide_banner -loglevel error -i "$fullPath" -f ffmetadata "$metadataText"
    }
    $1st = '<?xml version="1.0" encoding="ISO-8859-1" ?>'
    $2nd = '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">'
    $end = '</xs:schema>'
    $main = ((&$mediainfocli --Output=JSON "$fullPath" | ConvertFrom-Json).media.track.extra.OverDrive_MediaMarkers)
    [xml] $xml = "$($1st)  $($2nd)  $($main)  $($end)"
    
    $duration = ((&$mediainfocli --Inform="General;%Duration%" "$fullPath") / 1000)
    $count = 0
    foreach ($item in $xml.schema.markers.marker.time) {
        #----change
        #$name = $xml.schema.markers.marker.name[$count]
        if ($xml.schema.markers.marker.name.count -gt 1) {
            $name = $xml.schema.markers.marker.name[$count]
            $start = ((([int]$xml.schema.markers.marker.time[$count].split(":").split(".")[0]) * 60) + [int]$xml.schema.markers.marker.time[$count].split(":").split(".")[1])
            if (!$xml.schema.markers.marker.time[$count + 1]) {
                $end = ($duration * 1000)
            }
            else {
                $end = ((([int]$xml.schema.markers.marker.time[$count + 1].split(":").split(".")[0]) * 60) + [int]$xml.schema.markers.marker.time[$count + 1].split(":").split(".")[1])
            }
        }
        else {
            $name = $xml.schema.markers.marker.name
            $start = ((([int]$xml.schema.markers.marker.time.split(":").split(".")[0]) * 60) + [int]$xml.schema.markers.marker.time.split(":").split(".")[1])
            $end = ($duration * 1000)
        }
        
        #$start = ((([int]$xml.schema.markers.marker.time[$count].split(":").split(".")[0]) * 60) + [int]$xml.schema.markers.marker.time[$count].split(":").split(".")[1])
        
        
        
        Add-Content $metadataText "[CHAPTER]"
        Add-Content $metadataText "TIMEBASE=1/1000"
        Add-Content $metadataText "START=$($start * 1000)"
        Add-Content $metadataText "END=$($end * 1000)"    
        Add-Content $metadataText "title= $name"
        $count++;
    }
    &$ffmpeg -hide_banner -loglevel warning -i "$fullPath" -i "$metadataText" -map_metadata 1 -c copy -attach .\image.jpg -metadata:s:t mimetype=image/jpeg "$outFile"
}
