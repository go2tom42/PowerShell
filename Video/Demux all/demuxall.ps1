# CodecID.xml is from https://github.com/line0/MkvTools


#$file = 'C:\Video\test.mkv'
#$file = 'C:\Video\test-pos.mkv'
#$file = 'C:\Video\test-noCAP.mkv'


$MKVList = Get-ChildItem -Path $CurrentDir -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object

function _DeMuxAll($file) {
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop

    #get --identify from mkvmerge for all tracks
    $videoMKVinfo = &mkvmerge --ui-language en --identify  --identification-format json "$file" | ConvertFrom-Json

    $ChapCheck = $videoMKVinfo.chapters.count -gt 0

    #$videoMKVinfo = (&mkvmerge --ui-language en --identify  --identification-format json "$file" | ConvertFrom-Json).tracks
    $videoMKVinfo = $videoMKVinfo.tracks

    #load Xml that gets ext for a codec
    $codecIDs = [xml](Get-Content ((Get-Location).path + '\CodecID.xml')) | ForEach-Object { $_.codecs.codec }

    $NumberOfTracks = $videoMKVinfo.count

    #1st character of codec_id identifies the type of track (($videoMKVinfo | Where-Object id -eq 0).properties.codec_id).Substring(0,1) V=video A=audio S=subtitle

    $commandline = '"' + $file + '"  tracks --ui-language en  '

    New-Item -ItemType "directory" -Path ((Get-Location).path + '\video') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ((Get-Location).path + '\audio') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ((Get-Location).path + '\subtitles') -ErrorAction SilentlyContinue | Out-Null


    for ($i = 0; $i -lt $NumberOfTracks; $i++) {
        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'V') {
            $commandline = $commandline + $i + ':"video\' + $file.BaseName + '_track' + $i + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
        }

        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'A') {

            if ((($videoMKVinfo | Where-Object id -eq $i).properties.minimum_timestamp) -eq '0') {
                $commandline = $commandline + $i + ':"audio\' + $file.BaseName + '_track' + $i + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '    
            }
            else {
                $delay = (($videoMKVinfo | Where-Object id -eq $i).properties.minimum_timestamp) / 1000000
                $commandline = $commandline + $i + ':"audio\' + $file.BaseName + '_track' + $i + '_DELAY ' + $delay + 'ms.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
            }
        
        }

        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'S') {
            $commandline = $commandline + $i + ':"subtitles\' + $file.BaseName + '_track' + $i + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
        }
    }

    Start-Process -FilePath "mkvextract" -ArgumentList $commandline -wait -NoNewWindow #-RedirectStandardError nul

    if ($ChapCheck -eq 'True') {
        New-Item -ItemType "directory" -Path ((Get-Location).path + '\chapters') -ErrorAction SilentlyContinue | Out-Null
        Start-Process -FilePath "mkvextract" -ArgumentList ('"' + $file + '" chapters --ui-language en --simple "chapters\' + $file.BaseName + '.txt"') -wait -NoNewWindow #-RedirectStandardError nul
    }

}

foreach ($file in $MKVList) {
    _DeMuxAll $file
}
