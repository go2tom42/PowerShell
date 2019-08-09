Param(
    [parameter(Mandatory=$true)]
    [alias("f")]
    $File,
    [parameter(Mandatory=$false)]
    $FFN = '-v -ext m4a -c:a aac -b:a 192k -pr -e="-ac 2"'
)


if ($ffn.contains('-ext') -eq $true) {
    $audioext = '.' + $ffn.Substring(($ffn.IndexOf('-ext')+5), 3)
} else {
    $audioext = '.m4a'
}

function Get-DefaultAudio($file){

#    Param ($file)
#    $file = "E:\WORK\Audio-AGAIN\Avengers.Endgame.2019.V2.1080p.HDRip.X264.AC3-EVO.NORMALIZED (1).mkv"
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop

    $video = &mkvmerge -J $file | ConvertFrom-Json
    $audio_ck = $video.tracks | Where-Object { $_.type -eq "audio" }
    $audio_ck2 = $audio_ck.properties | Where-Object { $_.default_track -eq "True" }

    if ($audio_ck2) {
        $default_track = $audio_ck2[0].number - 1
        $def_language = $audio_ck2[0].language
    }
    else {
        $default_track = $audio_ck[0].properties.number - 1
        $def_language = $audio_ck[0].properties.language
    }

    $json = "--ui-language", "en", "--output"
    $json = $json += $file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv' 
    $json = $json += "--audio-tracks"
    $json = $json += "$default_track"
    $json = $json += "--no-video", "--no-subtitles", "--no-chapters", "--language"
    $json = $json += "$default_track" + ":" + "$def_language"
    $json = $json += "--default-track"
    $json = $json += "$default_track" + ":yes"
    $json = $json += "(", $file.FullName , ")"
    $json | ConvertTo-Json -depth 100 | Out-File "$($file.DirectoryName)\file.json"

    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\file.json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    Remove-Item -LiteralPath "$($file.DirectoryName)\file.json"


}

function Start-Remux($file) {

#    Param ($file)
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $video = &mkvmerge -J $file | ConvertFrom-Json
    $json = ''
    $json = "--ui-language", "en", "--output"
    $json = $json += $file.FullName.TrimEnd($file.extension) + '.NORMALIZED.mkv' 
    
    foreach ($obj in $video.tracks) {
        if ($obj.type -eq "video") {
            $json = $json += "--language" , "$($obj.id):und" , "--default-track" , "$($obj.id):yes"
        }
        
        if ($obj.type -eq "audio") {
            $json = $json += "--language", "$($obj.id):$($obj.properties.language)"
            if ($obj.properties.track_name) {
                $json = $json += "--track-name", "$($obj.id):$($obj.properties.track_name)"
            }
        }
    
        if ($obj.type -eq "subtitles") {
            #$json = $json += "--sub-charset" , "$($obj.id):$($obj.properties.encoding)" 
            $json = $json += "--language" , "$($obj.id):$($obj.properties.language)"
            if ($obj.properties.track_name) {
                $json = $json += "--track-name" , "$($obj.id):$($obj.properties.track_name)"
            }
        }
    }
    
    $json = $json += "(" , $file.FullName , ")" # Source file
    
    $json = $json += "--language", "0:eng", "--track-name", "0:Normalized", "--default-track", "0:yes" , "("
    
    $json = $json += $file.FullName.TrimEnd($file.extension) + '.AUDIO.m4a' # normalized audio file
    $main_tracks = $video.tracks.count - 1
    $track_order = ''
    for ($i = 1; $i -le $main_tracks; $i++) {
        $track_order = $track_order + ",0:$i"
    }
    $json = $json += ")", "--track-order", "0:0,1:0$track_order"
    
    $json | ConvertTo-Json -depth 100 | Out-File "$($file.DirectoryName)\file.json"

    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\file.json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    Remove-Item -LiteralPath "$($file.DirectoryName)\file.json"

    }






    Get-DefaultAudio -file $file
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $arguments = '"' + $file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv' + '" -o "' + $file.FullName.TrimEnd($file.extension) + '.AUDIO.m4a" ' + $FFN
    Start-Process -FilePath "ffmpeg-normalize" -ArgumentList $arguments -wait -NoNewWindow #-RedirectStandardError nul
    Start-Remux -file $file

    Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv')
    Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.m4a')
    