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


function Get-DefaultAudio($file) {

    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
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
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath "$($file.DirectoryName)\$($file.basename).json"
 
    $nid = get-process mkvmerge -ErrorAction SilentlyContinue
    if ($nid) {
        echo "Waiting for MKVMERGE to finish"
        wait-process -id $nid.id
        $time = Get-Random -Maximum 10
        Start-Sleep -s $time
        Remove-Variable nid
    }

    $nid = get-process mkvmerge -ErrorAction SilentlyContinue
    if ($nid) {
        echo "Waiting for MKVMERGE to finish"
        wait-process -id $nid.id
        Remove-Variable nid
    }

    [string]$mkvSTDOUT_FILE = "mkvSTD.txt"
    [string]$mkvSTDERROUT_FILE = "mkvERR.txt"
    $mkvmergePROS = Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\$($file.basename).json" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -WindowStyle Hidden -PassThru
    Start-Sleep -m 1
    Do{
        Start-Sleep -m 1
        $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object {$_ -like "Progress*"}
        If($MKVProgress){
            $MKVPercent = $MKVProgress -replace '\D+'
            write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Extracting audio file {0:n2}% completed..." -f $MKVPercent)
        
        }

    }Until ($mkvmergePROS.HasExited)

    write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Extracting audio file {0:n2}% completed..." -f 100)
    Remove-Item -Path ".\mkvSTD.txt"
    Remove-Item -Path ".\mkvERR.txt"
    Remove-Item -LiteralPath "$($file.DirectoryName)\$($file.basename).json"
}

function Start-Remux($file) {
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
    $json = $json += $file.FullName.TrimEnd($file.extension) + '.AUDIO.' + $audioext # normalized audio file
    $main_tracks = $video.tracks.count - 1
    $track_order = ''
    for ($i = 1; $i -le $main_tracks; $i++) {
        $track_order = $track_order + ",0:$i"
    }
    $json = $json += ")", "--track-order", "0:0,1:0$track_order"
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath "$($file.DirectoryName)\$($file.basename).json"
    
    $nid = get-process mkvmerge -ErrorAction SilentlyContinue
       
    if ($nid) {
        echo "Waiting for MKVMERGE to finish"
        wait-process -id $nid.id
        $time = Get-Random -Maximum 10
        Start-Sleep -s $time
        Remove-Variable nid
    }

    $nid = get-process mkvmerge -ErrorAction SilentlyContinue
       
    if ($nid) {
        echo "Waiting for MKVMERGE to finish"
        wait-process -id $nid.id
        Remove-Variable nid
    }
        [string]$mkvSTDOUT_FILE = "mkvSTD.txt"
        [string]$mkvSTDERROUT_FILE = "mkvERR.txt"
    
            $mkvmergePROS = Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\$($file.basename).json" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -WindowStyle Hidden -PassThru
            #progress bar monitors the trancoding log for time duration and ends when process has exited
        Start-Sleep -m 1
        Do{
            Start-Sleep -m 1
            $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object {$_ -like "Progress*"}
            #$MKVProgress = [regex]::split((Get-content $mkvSTDOUT_FILE | Select-Object -Last 1), '(,|\s+)') | Where-Object {$_ -like "Progress*"}
            If($MKVProgress){
                $MKVPercent = $MKVProgress -replace '\D+'
                write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Muxing video file {0:n2}% completed..." -f $MKVPercent)
            
            }
    
        }Until ($mkvmergePROS.HasExited)

        write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Muxing video file {0:n2}% completed..." -f 100)
        Remove-Item -Path ".\mkvSTD.txt"
        Remove-Item -Path ".\mkvERR.txt"
        Remove-Item -LiteralPath "$($file.DirectoryName)\$($file.basename).json"
}

function Normalize($file) {

    [string]$STDOUT_FILE = "stdout.txt"
    [string]$OutputFileExt = "." + $audioext
    [string]$STDERR_FILE = "stderr.txt"

    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $Source_Path = $file.FullName.TrimEnd($file.extension) + '.mkv' 
    
    $PASS2_FILE = $file.FullName.TrimEnd($file.extension) + $OutputFileExt

    $ArgumentList = "-progress - -nostats -nostdin -y -i  ""$file"" -af loudnorm=i=-23.0:lra=7.0:tp=-2.0:offset=0.0:print_format=json -hide_banner -f null -"    

    $totalTime = FFProbe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $file
    $ffmpeg = Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -WindowStyle Hidden -PassThru
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
    $output_i = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*output_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $output_tp = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*output_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $output_lra = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*output_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $output_thresh = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*output_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $normalization_type = (Get-Content -LiteralPath $STDERR_FILE | Where-Object {$_ -Like '*normalization_type*'}).Replace('"',"").Replace(',',"")
    $target_offset = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*target_offset*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")

    Remove-Item -Path ".\stdout.txt"
    Remove-Item -Path ".\stderr.txt"

    $ArgumentList = "-progress - -nostats -nostdin -y -i ""$Source_Path"" -threads 0 -hide_banner -filter_complex `"[0:0]loudnorm=I=-23:TP=-2.0:LRA=7:measured_I=""$input_i"":measured_LRA=""$input_lra"":measured_TP=""$input_tp"":measured_thresh=""$input_thresh"":offset=""$target_offset"":linear=true:print_format=json[norm0]`" -map_metadata 0 -map_metadata:s:a:0 0:s:a:0 -map_chapters 0 -c:v copy -map [norm0] -c:a $codec -b:a $bitrate -ar $freq -c:s copy -ac 2 ""$PASS2_FILE"""
    write-progress -id 1 -activity "Normalizing audio" -status "Stage 3/4" -PercentComplete 46
    $ffmpeg = Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -WindowStyle Hidden -PassThru
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
    Remove-Item -Path ".\stdout.txt"
    Remove-Item -Path ".\stderr.txt"

}

$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.NORMALIZED.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}

$Host.PrivateData.ProgressBackgroundColor=’Green’
$Host.PrivateData.ProgressForegroundColor=’Black’
$totalTime = FFProbe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file"

write-progress -id 1 -activity "Normalizing audio" -status "Stage 1/4" -PercentComplete 0
write-progress -parentId 1 -Activity "Mkvmerge"
Get-DefaultAudio -file $file

$file = Get-Childitem -LiteralPath $file -ErrorAction Stop
$file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
write-progress -id 1 -activity "Normalizing audio" -status "Stage 2/4" -PercentComplete 1
write-progress -parentId 1 -Activity "2 pass loudnorm" -Status "Pass 1 of 2"
Normalize -file ($file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv')


write-progress -id 1 -activity "Normalizing audio" -status "Stage 4/4" -PercentComplete 96
write-progress -parentId 1 -Activity "Mkvmerge"
Start-Remux -file $file

Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv')
Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.' + $audioext)

#Remove-Item -Path $file #deletes orignal file