$fps = '24000/1001p'
if ($args.count -gt 0) {
    If ($args[0] -eq '24') {$fps = '24000/1001p'}
    If ($args[0] -eq '25') {$fps = '25p'}
    If ($args[0] -eq '30') {$fps = '30000/1001p'}
}

$MyPath = (Get-Location).path
$mkvmerge = 'C:\Program Files\MKVToolNix\mkvmerge.exe'

$VideoList = Get-ChildItem -Path ((Get-Location).path +'\*') -Include ("*.h264", "*.h265", "*.hevc", "*.divx", "*.avc") -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($file in $VideoList) {
    $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name -split "_")[0])
    if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
    if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
}

$AudioList = Get-ChildItem -Path ((Get-Location).path +'\*') -Include ("*.aac", "*.ac3", "*.dts", "*.eac3", "*.flac,", "*.mp1", "*.mp2", "*.mp3", "*.ogg") -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($file in $AudioList) {
    $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name -split "_")[0])
    if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
    if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
}

$SubtitleList = Get-ChildItem -Path ((Get-Location).path +'\*') -Include ("*.ass", "*.ssa", "*.srt", "*.sub", "*.sup") -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($file in $SubtitleList) {
    $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name -split "_")[0])
    if ($file.name -match '(\[(?<Lang>.*)\])') {$file | add-member -NotePropertyName Lang -NotePropertyValue ($Matches.Lang)} else {$file | add-member -NotePropertyName Lang -NotePropertyValue und}
    if ($file.name -match '(_DELAY (?<DELAY>.*)ms\.)') {$file | add-member -NotePropertyName Delay -NotePropertyValue ($Matches.DELAY)} else {$file | add-member -NotePropertyName Delay -NotePropertyValue 0}
}

$Chapterlist = Get-ChildItem -Path ((Get-Location).path +'\*') -Include "*.txt" -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($file in $Chapterlist) {
    $file | add-member -NotePropertyName CoreName -NotePropertyValue (($file.Name -split "_")[0])
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
    $json = $json += $MyPath + "\" + $file.CoreName + ".mkv"
#video    
    $json = $json += "--language", "0:$($file.lang)", "--default-duration", "0:$($fps)", "(", $($file.FullName) , ")"
#audio
    foreach ($item in $epAudio) {
        $json = $json += "--language", "0:$($item.Lang)", "--sync", "0:$($item.Delay)", "(", $item.FullName, ")"
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

