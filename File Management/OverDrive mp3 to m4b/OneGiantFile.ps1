$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"
$metadataText = ".\metadata.txt"
$ffmpeg = "c:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin\ffmpeg.exe"
$catmp3 = "C:\Users\tom42\Documents\My Media\MP3 Audiobooks\It\mp3cat.exe"
Write-Host "Analyze Files ..."
$mergeFiles = Get-ChildItem ".\" -Filter "*.mp3"
$folder = $mergeFiles.DirectoryName[0]
$tempfile = $mergeFiles.fullname[0]
&$ffmpeg -hide_banner -loglevel error -i "$tempfile" -f ffmetadata "$metadataText"
[xml]$fullxml = @'
<Markers>
</Markers>
'@

$Totaltime = [TimeSpan]::FromSeconds(0)
#get all chapters & times from all MP3 in folder
foreach ($mergeFile in $mergeFiles) {
    $fullPath = $mergeFile.FullName;
    [xml]$xml = ((&$mediainfocli --Output=JSON "$fullPath" | ConvertFrom-Json).media.track.extra.OverDrive_MediaMarkers)
    $CurrentTime = [TimeSpan]::FromSeconds(((&$mediainfocli --Inform="General;%Duration%" "$fullPath") / 1000))
    
    foreach ($marker in $xml.markers.marker) {
        # create node <name>
        $namelabel = $fullxml.CreateNode('element', 'Name', '')
        $namedesc = $fullxml.CreateTextNode($marker.Name.trim())
        $namelabel.AppendChild($namedesc) | Out-Null
        # create node <name>
        $time = [TimeSpan]::FromSeconds(((([int]$marker.time.split(":").split(".")[0]) * 60) + [int]$marker.time.split(":").split(".")[1]))
        $time = $time + $Totaltime        
        # create node <time>
        $timelabel = $fullxml.CreateNode('element', 'Time', '')
        $timedesc = $fullxml.CreateTextNode(("{0:dd\:hh\:mm\:ss\.fff}" -f $time))
        $timelabel.AppendChild($timedesc) | Out-Null
        # create node <time>

        # create node <Source> and append child nodes <Composition> and <ServiceRef>
        $src = $fullxml.CreateNode('element', 'Marker', '')
        $src.AppendChild($namelabel) | Out-Null
        $src.AppendChild($timelabel) | Out-Null

        # append node <Source> to node <Service>
        $svc = $fullxml.SelectSingleNode('//Markers')
        $svc.AppendChild($src) | Out-Null
    }

    $Totaltime = $Totaltime + $CurrentTime
    # echo total time is $Totaltime
}

&$catmp3 --dir $folder

$c = 0
foreach ($item in $fullxml.Markers.Marker.Time) {
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

&$ffmpeg -hide_banner -loglevel warning -i "output.mp3" -i "$metadataText" -map_metadata 1 -c copy -attach .\image.jpg -metadata:s:t mimetype=image/jpeg "output.mka"