$CurrentDir = Get-Location
$mkvlist = Get-ChildItem -Path $CurrentDir -Filter *.mkv -ErrorAction SilentlyContinue -Force


foreach ($mkv in $mkvlist)
{
    $json = ''
    $json = "--ui-language", "en", "--output"
    $json = $json += $mkv.DirectoryName + '\out.mka' 
    $json = $json += "--no-video", "--language", "1:eng", "--default-track", "1:yes"
    $json = $json += "(" , $mkv.FullName , ")" # Source file
    $json | ConvertTo-Json -depth 100 | Out-File "$($mkv.DirectoryName)\file.json"

    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($mkv.DirectoryName)\file.json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    Remove-Item -LiteralPath "$($mkv.DirectoryName)\file.json"    


    Start-Process -FilePath "eac3to" -ArgumentList "out.mka","fixed.ac3","-25.000","-changeTo23.976","-128" -wait -NoNewWindow

    $json = ''
    $json = "--ui-language", "en", "--output"
    $json = $json += $mkv.FullName.TrimEnd($mkv.extension) + '.FIXED.mkv' # normalized audio file
    $json = $json += "--no-audio", "--language", "0:und", "--default-track", "0:yes", "--default-duration", "0:24000/1001p"
    $json = $json += "(" , $mkv.FullName , ")" # Source file
    $json = $json += "--language", "0:und"
    $json = $json += "(", ($mkv.DirectoryName + '\fixed.ac3'), ")"
    $json = $json += "--track-order", "0:0,1:0"
    $json | ConvertTo-Json -depth 100 | Out-File "$($mkv.DirectoryName)\file2.json"

    Start-Process -FilePath "mkvmerge" -ArgumentList ('"' + "@$($mkv.DirectoryName)\file2.json" + '"') -wait -NoNewWindow #-RedirectStandardError nul
    Remove-Item -LiteralPath "$($mkv.DirectoryName)\out.mka"
    Remove-Item -LiteralPath "$($mkv.DirectoryName)\fixed.ac3"
    Remove-Item -LiteralPath "$($mkv.DirectoryName)\file2.json"    
    Remove-Item -LiteralPath "$($mkv.DirectoryName)\fixed - Log.txt"


}
