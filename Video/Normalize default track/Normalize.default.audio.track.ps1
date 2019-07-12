Param(
    [parameter(Mandatory=$true)]
    [alias("f")]
    $File,
    [parameter(Mandatory=$false)]
    $FFN = '-v -ext m4a -c:a aac -b:a 192k -pr -e="-ac 2"'
)
#-----
$File = 'Z:\Videos\Movies\Live Action\Armageddon [1998]\Armageddon 1998 Bluray-720p.mkv'
$FFN = '-v -ext m4a -c:a aac -b:a 192k -pr -e="-ac 2"'
#----=
if ($ffn.contains('-ext') -eq $true) {
    $audioext = '.' + $ffn.Substring(($ffn.IndexOf('-ext')+5), 3)
} else {
    $audioext = '.m4a'
}

$filepath = Get-Childitem -LiteralPath $File -ErrorAction Stop

$arguments = '-i "' + $filepath.FullName + '" -hide_banner -show_streams -show_format -print_format json'
Echo "Getting audio info"
Start-Process -FilePath "ffprobe" -ArgumentList $arguments -wait -NoNewWindow -RedirectStandardOutput $env:windir\temp\ffprobe.json -RedirectStandardError nul
$ffprobeJson = Get-Content -Raw -Path $env:windir\temp\ffprobe.json | ConvertFrom-Json
$loopCount = $ffprobeJson.streams.count - 1 
$audiofound = 0

$audioCount = 0
for ($i = 0; $i -le $loopcount; $i++) {
    If (($ffprobeJson.streams[$i].disposition.default -eq "1") -and ($ffprobeJson.streams[$i].codec_type -eq "audio")) {
        $codec_type = $i
        $extract_stream = $audioCount
        $audiofound = 1
    }
    Else {
        if ($ffprobeJson.streams[$i].codec_type -eq "audio") {
            $audioCount++ 
        }
    }
}

if ($audiofound -ne 1) {
    Echo "No default audio track, selecting 1st audio track instead"
    $audioCount = 0
    for ($i = 0; $i -le $loopcount; $i++) {
        if ($ffprobeJson.streams[$i].codec_type -eq "audio") {
            $codec_type = $i
            $extract_stream = $audioCount
            $audiofound = 1
            break
        }
    }
}

$2ndarguments = '-i "' + $filepath.FullName + '" -map 0:a:' + $extract_stream + ' -c copy "' + $filepath.FullName.TrimEnd($filepath.extension) + '.' + $ffprobeJson.streams[$codec_type].codec_name + '"'
Echo "Demuxing audio file"
Start-Process -FilePath "ffmpeg" -ArgumentList $2ndarguments -wait -NoNewWindow -RedirectStandardError nul 

$global:audiofile = $filepath.FullName.TrimEnd($filepath.extension) + '.' + $ffprobeJson.streams[$codec_type].codec_name
$global:audiofile = Get-ChildItem -LiteralPath $global:audiofile
$global:mainfile = $filepath

echo 'extraction done'

$3rdarguments = '"' + $audiofile.FullName + '" -o "' + $audiofile.FullName.TrimEnd($audiofile.extension) + $audioext + '" ' + $FFN

Echo "Normalizing audio file"
Start-Process -FilePath "ffmpeg-normalize" -ArgumentList $3rdarguments -wait -NoNewWindow 

Remove-Item -LiteralPath $audiofile.FullName

echo 'normalizing done'

$global:audiofile = $audiofile.FullName.TrimEnd($audiofile.extension) + $audioext
$global:audiofile = Get-ChildItem -LiteralPath $global:audiofile
 
$newfile = $mainfile.FullName.TrimEnd($mainfile.Extension) + '.normalized' + $mainfile.Extension

$4tharguments = '-i "' + $mainfile.FullName + '" -i "' + $audiofile.FullName + '" -map 0:v:0 -map 1:a:0 -map 0:a -map 0:s? -c copy -disposition:a:0 default -disposition:a:1 none "' + $newfile + '"'
Echo "Remuxing video file with new audio added as default track"
Start-Process -FilePath "ffmpeg" -ArgumentList $4tharguments -wait -NoNewWindow -RedirectStandardError nul

Remove-Item -LiteralPath $audiofile.FullName

echo 'remux done'