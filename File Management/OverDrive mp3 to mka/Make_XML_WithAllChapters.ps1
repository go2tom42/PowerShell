$mediainfocli = "C:\WORK\audio stuff\shit\MediaInfo.exe"

Write-Host "Analyze Files ..."
$mergeFiles = Get-ChildItem ".\" -Filter "*.mp3"
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
$fullxml.Save(".\books.xml")
