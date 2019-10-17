
#varibles 
$makemkvcon64 = "C:\Program Files (x86)\MakeMKV\makemkvcon64.exe"
$mkvextract = "C:\Program Files\MKVToolNix\mkvextract.exe"

$BluraySource = @(
"12 Monkeys S2\12_Monkeys_Season2_D3",
"12 Monkeys S2\12_Monkeys_Season2_D1",
"12 Monkeys S2\12_Monkeys_Season2_D2"
)
$Remux_output = "C:\Work\12-1"


$ext4Audio2Norm = '*.*'
$mkvmerge = "C:\Program Files\MKVToolNix\mkvmerge.exe"
$DemuxOutFolder = "c:\Video\comm\"
$Destination = "d:\Video\comm\"

function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = “Comment” + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}


#get REMUX

#for ($i = 0; $i -lt $Discs; $i++) {
 #   $MakeMKVcommand = $makemkvcon64 + ' mkv file:"' + $BluraySource[$i] + '" all "' + $Remux_output + '"'
 #   Write-Host $MakeMKVcommand
 #   Start-Process -FilePath $makemkvcon64 -ArgumentList ('mkv file:"' + $BluraySource[$i] + '" all "' + $Remux_output + '"') -Wait
#}
#"C:\Program Files (x86)\MakeMKV\makemkvcon64.exe" mkv file:"Y:\media\HDD\Downloads\torrents\complete\btn\Star Trek The Next Generation S04 1080p Blu-ray AVC DTS-HD MA 7.1 - JonLovejoy\STAR TREK TNG S4 D1" all "C:\Work\TNG-S4"

Start-Process -FilePath "pvw32" -ArgumentList "D:\Video\s4\test.png" -wait -NoNewWindow

#Dmux files
$EPsList = Get-ChildItem -Path ($DemuxOutFolder + 'EPs') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
$4x3List = Get-ChildItem -Path ($DemuxOutFolder + '4x3') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
$HDList = Get-ChildItem -Path ($DemuxOutFolder + 'HD') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
$SDList = Get-ChildItem -Path ($DemuxOutFolder + 'SD') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object



function _DeMuxAll($file,$type) {
    $Destination = (Get-IniContent settings.ini).settings.Destination
#    $DemuxOutFolder = (Get-IniContent settings.ini).settings.DemuxOutFolder
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $videoMKVinfo = &mkvmerge --ui-language en --identify  --identification-format json "$file" | ConvertFrom-Json
    $ChapCheck = $videoMKVinfo.chapters.count -gt 0
    $videoMKVinfo = $videoMKVinfo.tracks
    $codecIDs = [xml](Get-Content ((Get-Location).path + '\CodecID.xml')) | ForEach-Object { $_.codecs.codec }
    $NumberOfTracks = $videoMKVinfo.count
    $commandline = '"' + $file + '"  tracks --ui-language en  '
    for ($i = 0; $i -lt $NumberOfTracks; $i++) {
        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'A') {
            if ((($videoMKVinfo | Where-Object id -eq $i).properties.minimum_timestamp) -eq '0') {
                $commandline = $commandline + $i + ':"' + $Destination + $type +'audio\' + $file.BaseName + '_track' + $i + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '    
            }
            else {
                $delay = (($videoMKVinfo | Where-Object id -eq $i).properties.minimum_timestamp) / 1000000
                $commandline = $commandline + $i + ':"' + $Destination + $type +'audio\' + $file.BaseName + '_track' + $i + '_DELAY ' + $delay + 'ms.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
            }
        }
        if ((($videoMKVinfo | Where-Object id -eq $i).properties.codec_id).Substring(0, 1) -eq 'S') {
            $commandline = $commandline + $i + ':"' + $Destination + $type +'subtitles\' + $file.BaseName + '_track' + $i + '.' + ($codecIDs | Where-Object { $_.id -eq (($videoMKVinfo | Where-Object id -eq $i).properties.codec_id) }).ext + '" '
        }
    }
    Start-Process -FilePath "mkvextract" -ArgumentList $commandline -wait -NoNewWindow #-RedirectStandardError nul
    if ($ChapCheck -eq 'True') {
        Start-Process -FilePath "mkvextract" -ArgumentList ('"' + $file + '" chapters --ui-language en --simple "' + $Destination + $type +'chapters\' + $file.BaseName + '.txt"') -wait -NoNewWindow #-RedirectStandardError nul
    }
}

if (Test-Path ($DemuxOutFolder + 'EPs')) {
    $type = "EPs\"
    New-Item -ItemType "directory" -Path ($Destination + 'EPs\video') -ErrorAction SilentlyContinue | Out-Null    
    New-Item -ItemType "directory" -Path ($Destination + 'EPs\audio') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'EPs\subtitles') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'EPs\chapters') -ErrorAction SilentlyContinue | Out-Null
    foreach ($file in $EPsList) {
        _DeMuxAll $file $type
    }
}

if (Test-Path ($DemuxOutFolder + 'HD')) {
    $type = "HD\"
    New-Item -ItemType "directory" -Path ($Destination + 'HD\video') -ErrorAction SilentlyContinue | Out-Null    
    New-Item -ItemType "directory" -Path ($Destination + 'HD\audio') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'HD\subtitles') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'HD\chapters') -ErrorAction SilentlyContinue | Out-Null
    foreach ($file in $HDList) {
        _DeMuxAll $file $type
    }
}

if (Test-Path ($DemuxOutFolder + 'SD')) {
    $type = "SD\"
    New-Item -ItemType "directory" -Path ($Destination + 'SD\video') -ErrorAction SilentlyContinue | Out-Null    
    New-Item -ItemType "directory" -Path ($Destination + 'SD\audio') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'SD\subtitles') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + 'SD\chapters') -ErrorAction SilentlyContinue | Out-Null
    foreach ($file in $SDList) {
        _DeMuxAll $file $type
    }
}

if (Test-Path ($DemuxOutFolder + '4x3')) {
    $type = "4x3\"
    New-Item -ItemType "directory" -Path ($Destination + '4x3\video') -ErrorAction SilentlyContinue | Out-Null    
    New-Item -ItemType "directory" -Path ($Destination + '4x3\audio') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + '4x3\subtitles') -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType "directory" -Path ($Destination + '4x3\chapters') -ErrorAction SilentlyContinue | Out-Null
    foreach ($file in $4x3List) {
        _DeMuxAll $file $type
    }
}


Start-Process -FilePath "pvw32" -ArgumentList "D:\Video\s4\test.png" -wait -NoNewWindow

Pause

#wrap audio to MKV

if (Test-Path ($Destination + "EPs\Normalize")) { $AudioEPsList = @(Get-ChildItem ($Destination + "EPs\Normalize")  -Filter ($ext4Audio2Norm) -ErrorAction SilentlyContinue -Force) | Sort-Object }
if (Test-Path ($Destination + "HD\Normalize")) { $AudioHDList = @(Get-ChildItem ($Destination + "HD\Normalize")  -Filter ($ext4Audio2Norm) -ErrorAction SilentlyContinue -Force) | Sort-Object }
if (Test-Path ($Destination + "SD\Normalize")) { $AudioSDList = @(Get-ChildItem ($Destination + "SD\Normalize")  -Filter ($ext4Audio2Norm) -ErrorAction SilentlyContinue -Force) | Sort-Object }
if (Test-Path ($Destination + "4x3\Normalize")) { $Audio4x3List = @(Get-ChildItem ($Destination + "4x3\Normalize")  -Filter ($ext4Audio2Norm) -ErrorAction SilentlyContinue -Force) | Sort-Object }



function WrapAudio($files) {
    $Destination = (Get-IniContent settings.ini).settings.Destination
    foreach ($file in $files) {
        $json = ''
        $json = "--ui-language", "en", "--output"
        $json = $json += $file.FullName.Replace($file.Extension , '.mkv')
        $json = $json += "--language","0:und","("
        $json = $json += $file.FullName
        $json = $json += ")"
        $json | ConvertTo-Json -depth 100 | Out-File "$($Destination)\A2MKV.json"
        Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($Destination)\A2MKV.json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
        Remove-Item -LiteralPath "$($Destination)\A2MKV.json"
        Remove-Item -LiteralPath $file.FullName
    }    
}

WrapAudio $AudioEPsList
WrapAudio $AudioHDList
WrapAudio $AudioSDList
WrapAudio $Audio4x3List




# divides audio into 3 groups

$groupCount = 3
#$path = ($Destination + "EPs\Normalize")
$path = ($Destination + "HD\Normalize")
$files = Get-ChildItem $path -File -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object

For($fileIndex = 0; $fileIndex -lt $files.Count; $fileIndex++){
    $targetIndex = $fileIndex % $groupCount
    $targetPath = Join-Path $path $targetIndex
    If(!(Test-Path $targetPath -PathType Container)){[void](new-item -Path $path -name $targetIndex -Type Directory)}
    $files[$fileIndex] | Move-Item -Destination $targetPath -Force
}

#starts main workload 
$procs = $(Start-Process -PassThru "pwsh" -ArgumentList '-File audio1.ps1'; Start-Process -PassThru "pwsh" -ArgumentList '-File audio2.ps1'; Start-Process -PassThru "pwsh" -ArgumentList '-File audio3.ps1';Start-Process -PassThru "pwsh" -ArgumentList '-File subtitles.ps1'; Start-Process -PassThru "pwsh" -ArgumentList '-File video.ps1')
$procs | Wait-Process

#move normmarlized files

$nomalizedList = Get-ChildItem -Path ($Destination + 'EPs\normalize') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object

foreach ($normalize in $nomalizedList) {
    $dest = $normalize.FullName.Replace('Normalize','audio')
    Move-Item -Path $normalize.FullName -Destination $dest -Force
}

Remove-Item -Path ($Destination + 'EPs\Normalize') -Recurse -Force

#remux

function _ReMuxAll($type) {
    $MyPath = (Get-Location).path
    
    $mkvmerge = (Get-IniContent settings.ini).settings.mkvmerge
    $Destination = (Get-IniContent settings.ini).settings.Destination

    $VideoList = Get-ChildItem -Path ($Destination + $type +'\video\*') -Include ("*.h264", "*.h265", "*.hevc", "*.divx", "*.avc", "*.mkv") -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $VideoList) {
        $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.BaseName -split "_")[0])
        if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
        if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
    }
    
    $AudioList = Get-ChildItem -Path ($Destination + $type + '\audio\*') -Include ("*.aac", "*.ac3", "*.dts", "*.eac3", "*.flac,", "*.mp1", "*.mp2", "*.mp3", "*.ogg", "*.mkv") -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $AudioList) {
        $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.BaseName -split "_")[0])
        if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
        if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
    }
    
    $SubtitleList = Get-ChildItem -Path ($Destination + $type + '\subtitles\*') -Include ("*.ass", "*.ssa", "*.srt", "*.sub", "*.sup") -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $SubtitleList) {
        $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.BaseName -split "_")[0])
        if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
        if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
    }
    
    $Chapterlist = Get-ChildItem -Path ($Destination + $type + '\chapters\*') -Include "*.txt" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $Chapterlist) {
        $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.BaseName -split "_")[0])
        if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
        if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
    }
    
    foreach ($file in $VideoList) {
        $epAudio = $AudioList | Where-Object { $_.CoreName -eq ($file.CoreName) }    
        $epSubtitles = $SubtitleList | Where-Object { $_.CoreName -eq ($file.CoreName) }
        $epChapter = $ChapterList | Where-Object { $_.CoreName -eq ($file.CoreName) }
    #output
        $json = ''
        $json = "--ui-language", "en", "--output"
        $json = $json += $Destination + $type + $file.CoreName + ".mkv"
        #$json = $json += $MyPath + "\" + $file.CoreName + ".mkv"
    #video    
        $json = $json += "--no-audio", "--no-subtitles", "--no-track-tags", "--no-global-tags", "--no-chapters", "--language", "0:$($file.lang)", "(", $($file.FullName) , ")"
        #$json = $json += "--no-audio", "--no-subtitles", "--no-track-tags", "--no-global-tags", "--no-chapters", "--language", "0:$($file.lang)", "--default-duration", "0:$($fps)", "(", $($file.FullName) , ")"
    #audio
        foreach ($item in $epAudio) {
            $json = $json += "--no-track-tags", "--no-global-tags", "--language", "0:$($item.Lang)", "--sync", "0:$($item.Delay)", "(", $item.FullName, ")"
        }
    #Subtitle 
        foreach ($item in $epSubtitles) {
            $json = $json += "--language", "0:$($item.Lang)", "--sync", "0:$($item.Delay)", "(", $item.FullName, ")"
        }
    #Chapter
        if ($epChapter) {
            $json = $json += "--chapter-language", "und", "--chapters", $epChapter.FullName
        }
    #footer  
        $trackcount = 1 + $epAudio.count + $epSubtitles.count
        $tracks = ''
        for ($X = 2; $X -lt $trackcount; $X++) {
            $tracks = $tracks + "," + $X + ":0"
        }
        $json = $json += "--track-order", "0:0,1:0$tracks"
        "$($MyPath)\$($file.corename).json"
        $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath "$($MyPath)\$($file.CoreName).json"
        Start-Process -FilePath $mkvmerge -ArgumentList ('"' + "@$($MyPath)\$($file.CoreName).json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
        Remove-Item -LiteralPath "$($MyPath)\$($file.CoreName).json"
    }
    
    
}

if (Test-Path ($Destination + 'EPs')) {
    $type = "EPs\"
    _ReMuxAll $type
}


if (Test-Path ($Destination + 'HD')) {
    $type = "HD\"
    _ReMuxAll $type
}

if (Test-Path ($Destination + 'SD')) {
    $type = "SD\"
    _ReMuxAll $type
}

if (Test-Path ($Destination + '4x3')) {
    $type = "4x3\"
    _ReMuxAll $type
}












#clean up





Remove-Item ($Destination + 'EPs') -Recurse -Force 
New-Item -Path ($Destination + 'EPs') -ItemType "directory" -ErrorAction SilentlyContinue | Out-Null
$MuxVideoList = Get-ChildItem -Path ($Destination + 'EPs-done') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($MuxVideo in $MuxVideoList) {
    $dest = $MuxVideo.FullName.Replace('EPs-done','EPs')
    Move-Item -Path $MuxVideo.FullName -Destination $dest -Force
}
Remove-Item ($Destination + 'EPs-done') -Recurse -Force 