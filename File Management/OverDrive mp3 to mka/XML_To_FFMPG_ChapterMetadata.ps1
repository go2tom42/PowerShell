$metadataText = ".\metadata.txt"
$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
[xml]$fullxml = Get-Content -Path '.\books.xml'

$TotalTime = [TimeSpan]::FromSeconds(161755.092)
$c = 0
&$ffmpeg -hide_banner -loglevel error -i ".\It-Part01.mp3" -f ffmetadata "$metadataText"
foreach ($item in $fullxml.Markers.Marker.Time) {
    #$TotalTime = [TimeSpan]::FromSeconds(((&$mediainfocli --Inform="General;%Duration%" "$fullPath") / 1000))
    $name = $fullxml.Markers.Marker[$c].Name
    $name = $name.trim()
    $start = ([Timespan]::Parse($fullxml.Markers.Marker[$c].Time)).TotalSeconds
    if (!$fullxml.markers.marker.time[$c + 1]) {
        $end = ($TotalTime.TotalSeconds)
    }
    else {
        $end = ([Timespan]::Parse($fullxml.Markers.Marker[$c+1].Time)).TotalSeconds
    }

    Add-Content $metadataText "[CHAPTER]"
    Add-Content $metadataText "TIMEBASE=1/1000"
    Add-Content $metadataText "START=$($start * 1000)"
    Add-Content $metadataText "END=$($end * 1000)"    
    Add-Content $metadataText "title=$name"
    $c++;
    
}
