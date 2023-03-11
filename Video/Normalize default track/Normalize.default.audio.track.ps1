Param(
    [parameter(Mandatory = $true)]
    [alias("f")]
    $File,
    [parameter(Mandatory = $false)]
    [Alias('c')]
    [String]$codec = "ac3",
    [parameter(Mandatory = $false)]
    [Alias('ext')]
    [String]$audioext = "ac3" ,
    [parameter(Mandatory = $false)]
    [Alias('b')]
    [String]$bitrate = "384k",
    [parameter(Mandatory = $false)]
    [Alias('ar')]
    [String]$freq = "48000"
    
)

[string]$mkvSTDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$mkvSTDERROUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$AudioExtJson = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".json")
[string]$STDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$STDERR_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")


$Extcheck = Get-Childitem -LiteralPath $File -ErrorAction Stop
if ($Extcheck.Extension -eq ".avi") {
    Start-Process -Wait "mkvmerge" -ArgumentList ('--output "' + $Extcheck.FullName.Replace('.avi','.mkv') + '" "' + $File + '"')
    $File = $Extcheck.FullName.Replace('.avi','.mkv')
}
if ($Extcheck.Extension -eq ".mp4") {
    Start-Process -Wait "mkvmerge" -ArgumentList ('--output "' + $Extcheck.FullName.Replace('.mp4','.mkv') + '" "' + $File + '"')
    $File = $Extcheck.FullName.Replace('.mp4','.mkv')
}

$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.NORMALIZED.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}

$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.AUDIO.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}


function Get-DefaultAudio($file) {

    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
    $video = &mkvmerge -J $file | ConvertFrom-Json    
    $audio_newCK = $video.tracks.properties |  Where-Object { ($_.language -eq $language) -and $_.audio_channels }
    if ($audio_newCK.count -lt 1) {
        $audio_newCK = $video.tracks.properties |  Where-Object { $_.audio_channels }
    }

    $defaultCK = $audio_newCK | Where-Object { ($_.default_track -eq "True") -and $_.language -eq $language } | Select-Object -First 1

    if ($defaultCK.count -lt 1) {
        $default_track = $audio_newCK[0].number - 1
        $def_language = $audio_newCK[0].language
    }
    else {
        $default_track = $defaultCK[0].number - 1
        $def_language = $defaultCK[0].language
    }


    
    $AudioMid = Join-Path ([IO.Path]::GetTempPath()) ($file.BaseName + '.AUDIO.mkv')

    $json = "--output" , "$AudioMid"
    $json = $json += "--audio-tracks"
    $json = $json += "$default_track"
    $json = $json += "--no-video", "--no-subtitles", "--no-chapters", "--language"
    $json = $json += "$default_track" + ":" + "$def_language"
    $json = $json += "--default-track"
    $json = $json += "$default_track" + ":yes"
    $json = $json += "(", $file.FullName , ")"
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath $AudioExtJson
    
    
    $nid = (Get-Process mkvmerge -ErrorAction SilentlyContinue).id 
    if ($nid) {
        Write-Output "Waiting for MKVMERGE to finish"
        Wait-Process -Id $nid
        Start-Sleep 5
        Clear-Host
    }
        
    $mkvmergePROS = Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$AudioExtJson" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep -m 1
    Do{        
        Start-Sleep -m 1
        $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object {$_ -like "Progress*"}
        If($MKVProgress){
            $MKVPercent = $MKVProgress -replace '\D+'
            write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Extracting audio file {0:n2}% completed..." -f $MKVPercent)
        
        }

    }Until ($mkvmergePROS.HasExited)
    
    $script:def_language = $def_language

    write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Extracting audio file {0:n2}% completed..." -f 100)
    
    Remove-Item -Path $mkvSTDOUT_FILE
    Remove-Item -Path $mkvSTDERROUT_FILE
    Remove-Item -LiteralPath $AudioExtJson
}

function Normalize($file) {
    [string]$OutputFileExt = "." + $audioext
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $Source_Path = $file.FullName.TrimEnd($file.extension) + '.mkv' 
    
    $script:PASS2_FILE = $file.FullName.TrimEnd($file.extension) + $OutputFileExt

    $ArgumentList = "-progress - -nostats -nostdin -y -i  ""$file"" -af loudnorm=i=-23.0:lra=7.0:tp=-2.0:offset=0.0:print_format=json -hide_banner -f null -"    

    $totalTime = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $file
    $ffmpeg = Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep 1
    Do{
        Start-Sleep 1
        $ffmpegProgress = [regex]::split((Get-content $STDOUT_FILE | Select-Object -Last 9), '(,|\s+)') | Where-Object {$_ -like "out_time=*"}
        If($ffmpegProgress){
            $gettimevalue = [TimeSpan]::Parse(($ffmpegProgress.Split("=")[1]))
            $starttime = $gettimevalue.ToString("hh\:mm\:ss\,fff") 
            $a = [datetime]::ParseExact($starttime,"HH:mm:ss,fff",$null)
            $ffmpegTimelapse = (New-TimeSpan -Start (Get-Date).Date -End $a).TotalSeconds
            $ffmpegPercent = $ffmpegTimelapse / $totalTime * 100
            write-progress -parentId 1 -Activity "2 pass loudnorm" -PercentComplete $ffmpegPercent -Status ("Pass 1 of 2 is {0:n2}% completed..." -f $ffmpegPercent)
            
        }

    }Until ($ffmpeg.HasExited)

    $input_i = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_tp = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_lra = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_thresh = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $target_offset = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*target_offset*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")

    Remove-Item -Path $STDOUT_FILE
    Remove-Item -Path $STDERR_FILE

    $ArgumentList = "-progress - -nostats -nostdin -y -i ""$Source_Path"" -threads 0 -hide_banner -filter_complex `"[0:0]loudnorm=I=-23:TP=-2.0:LRA=7:measured_I=""$input_i"":measured_LRA=""$input_lra"":measured_TP=""$input_tp"":measured_thresh=""$input_thresh"":offset=""$target_offset"":linear=true:print_format=json[norm0]`" -map_metadata 0 -map_metadata:s:a:0 0:s:a:0 -map_chapters 0 -c:v copy -map [norm0] -c:a $codec -b:a $bitrate -ar $freq -c:s copy -ac 2 ""$PASS2_FILE"""
    write-progress -id 1 -activity "Normalizing audio" -status "Stage 3/4" -PercentComplete 46
    $ffmpeg = Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep 1
    Do{
        Start-Sleep 1
        $ffmpegProgress = [regex]::split((Get-content $STDOUT_FILE | Select-Object -Last 9), '(,|\s+)') | Where-Object {$_ -like "out_time=*"}
        If($ffmpegProgress){
            $gettimevalue = [TimeSpan]::Parse(($ffmpegProgress.Split("=")[1]))
            $starttime = $gettimevalue.ToString("hh\:mm\:ss\,fff") 
            $a = [datetime]::ParseExact($starttime,"HH:mm:ss,fff",$null)
            $ffmpegTimelapse = (New-TimeSpan -Start (Get-Date).Date -End $a).TotalSeconds
            $ffmpegPercent = $ffmpegTimelapse / $totalTime * 100
            write-progress -parentId 1 -Activity "2 pass loudnorm" -PercentComplete $ffmpegPercent -Status ("Pass 2 of 2 is {0:n2}% completed..." -f $ffmpegPercent)
            
        }

    }Until ($ffmpeg.HasExited)
    Remove-Item -Path $STDERR_FILE
    Remove-Item -Path $STDOUT_FILE
    Remove-Item -Path $file
}

function Start-Remux($file) {
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $video = &mkvmerge -J $file | ConvertFrom-Json
    $json = ''
    $json = "--output" , ($file.FullName.TrimEnd($file.extension) + '.NORMALIZED.mkv')
    
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
                $json = $json += "--language" , "$($obj.id):$($obj.properties.language)"
            if ($obj.properties.track_name) {
                $json = $json += "--track-name" , "$($obj.id):$($obj.properties.track_name)"
            }
        }
    }
    
    $json = $json += "(" , $file.FullName , ")" # Source file
    $json = $json += "--language", "0:$def_language", "--track-name", "0:Normalized", "--default-track", "0:yes" , "("

    $json = $json += $PASS2_FILE # normalized audio file
    
    $main_tracks = $video.tracks.count - 1
    $track_order = ''
    for ($i = 1; $i -le $main_tracks; $i++) {
        $track_order = $track_order + ",0:$i"
    }
    $json = $json += ")", "--track-order", "0:0,1:0$track_order"
    
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath $AudioExtJson
    

    $nid = (Get-Process mkvmerge -ErrorAction SilentlyContinue).id 
    if ($nid) {
        Write-Output "Waiting for MKVMERGE to finish"
        Wait-Process -Id $nid
        Start-Sleep 3
        Clear-Host
    }

        [string]$mkvSTDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
        [string]$mkvSTDERROUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
    
        $mkvmergePROS = Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$AudioExtJson" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -PassThru -NoNewWindow
    
        Start-Sleep -m 1
        Do{
            Start-Sleep -m 1
            $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object {$_ -like "Progress*"}
                If($MKVProgress){
                $MKVPercent = $MKVProgress -replace '\D+'
                write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Muxing video file {0:n2}% completed..." -f $MKVPercent)
            
            }
    
        }Until ($mkvmergePROS.HasExited)
    
        write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Muxing video file {0:n2}% completed..." -f 100)
        Remove-Item -Path $mkvSTDERROUT_FILE
        Remove-Item -Path $mkvSTDOUT_FILE
        Remove-Item -Path $PASS2_FILE
        Remove-Item -LiteralPath $AudioExtJson
}

Clear-Host



$Host.PrivateData.ProgressBackgroundColor=’Green’
$Host.PrivateData.ProgressForegroundColor=’Black’

$totalTime = &ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file"

write-progress -id 1 -activity "Normalizing audio" -status "Stage 1/4" -PercentComplete 0
write-progress -parentId 1 -Activity "Mkvmerge"

Get-DefaultAudio($file)

$file = Get-Childitem -LiteralPath $file -ErrorAction Stop
$file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
write-progress -id 1 -activity "Normalizing audio" -status "Stage 2/4" -PercentComplete 1
write-progress -parentId 1 -Activity "2 pass loudnorm" -Status "Pass 1 of 2"

Normalize (Join-Path ([IO.Path]::GetTempPath()) ($file.BaseName + '.AUDIO.mkv'))


write-progress -id 1 -activity "Normalizing audio" -status "Stage 4/4" -PercentComplete 96
write-progress -parentId 1 -Activity "Mkvmerge"

Start-Remux($file)
