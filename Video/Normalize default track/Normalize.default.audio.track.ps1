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


$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.NORMALIZED.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}
  

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
    #$json | ConvertTo-Json -depth 100 | Out-File "$($file.DirectoryName)\file.json"
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


    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\$($file.basename).json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
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

    
    
    
    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($file.DirectoryName)\$($file.basename).json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    Remove-Item -LiteralPath "$($file.DirectoryName)\$($file.basename).json"
}

function Normalize($file) {
    

    [string]$STDOUT_LOUDNORM_FILE = "2ndpass.txt"
    [string]$STDOUT_FILE = "1stpass.txt"
    [string]$OutputFileExt = "." + $audioext


    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $Source_Path = $file.FullName.TrimEnd($file.extension) + '.mkv' 
    
    $PASS2_FILE = $file.FullName.TrimEnd($file.extension) + $OutputFileExt

    $ArgumentList = "-progress - -nostats -nostdin -y -i  ""$file"" -af loudnorm=i=-23.0:lra=7.0:tp=-2.0:offset=0.0:print_format=json -hide_banner -f null -"    

    Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardError $STDOUT_FILE
    
    $input_i = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*input_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_tp = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*input_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_lra = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*input_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_thresh = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*input_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    #$output_i = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*output_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    #$output_tp = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*output_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    #$output_lra = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*output_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    #$output_thresh = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*output_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    #$normalization_type = (Get-Content -LiteralPath $STDOUT_FILE | Where-Object {$_ -Like '*normalization_type*'}).Replace('"',"").Replace(',',"")
    $target_offset = (((Get-Content -LiteralPath $STDOUT_FILE | Where-Object { $_ -Like '*target_offset*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")

    #Write-Host -ForegroundColor Cyan 'input_i:'$input_i
    #Write-Host -ForegroundColor Cyan 'input_tp:'$input_tp
    #Write-Host -ForegroundColor Cyan 'input_lra:'$input_lra
    #Write-Host -ForegroundColor Cyan 'input_thresh:'$input_thresh
    #Write-Host -ForegroundColor Cyan 'output_i:'$output_i
    #Write-Host -ForegroundColor Cyan 'output_tp:'$output_tp
    #Write-Host -ForegroundColor Cyan 'output_lra:'$output_lra
    #Write-Host -ForegroundColor Cyan 'output_thresh:'$output_thresh
    #Write-Host -ForegroundColor Cyan 'target_offset:'$target_offset

    $ArgumentList = "-progress - -nostats -nostdin -y -i ""$Source_Path"" -threads 0 -hide_banner -filter_complex `"[0:0]loudnorm=I=-23:TP=-2.0:LRA=7:measured_I=""$input_i"":measured_LRA=""$input_lra"":measured_TP=""$input_tp"":measured_thresh=""$input_thresh"":offset=""$target_offset"":linear=true:print_format=json[norm0]`" -map_metadata 0 -map_metadata:s:a:0 0:s:a:0 -map_chapters 0 -c:v copy -map [norm0] -c:a $codec -b:a $bitrate -ar $freq -c:s copy -ac 2 ""$PASS2_FILE"""
   
    Start-Process -FilePath ffmpeg -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardError $STDOUT_LOUDNORM_FILE
}


Get-DefaultAudio -file $file
$file = Get-Childitem -LiteralPath $file -ErrorAction Stop
$file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
Normalize -file ($file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv')
Start-Remux -file $file

Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.mkv')
Remove-Item -LiteralPath ($file.FullName.TrimEnd($file.extension) + '.AUDIO.' + $audioext)
Remove-Item -Path ".\1stpass.txt"
Remove-Item -Path ".\2ndpass.txt"
#Remove-Item -Path $file #deletes orignal file
