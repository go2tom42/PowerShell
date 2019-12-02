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
$Destination = (Get-IniContent settings.ini).settings.Destination
$SubtitleEdit = (Get-IniContent settings.ini).settings.SubtitleEdit


if (Test-Path ($Destination + "EPs\subtitles")) {
    Start-Process -FilePath $SubtitleEdit -ArgumentList "/convert *.sup subrip /removetextforhi /redocasing /fixcommonerrors /reversertlstartend" -WorkingDirectory "$($Destination)EPs\subtitles"  -wait -NoNewWindow
    Remove-Item ($Destination + 'EPs\subtitles\*.sup') -Force  
}
if (Test-Path ($Destination + "HD\subtitles")) {
    Start-Process -FilePath $SubtitleEdit -ArgumentList "/convert *.sup subrip /removetextforhi /redocasing /fixcommonerrors /reversertlstartend" -WorkingDirectory "$($Destination)HD\subtitles"  -wait -NoNewWindow 
    Remove-Item ($Destination + 'HD\subtitles\*.sup') -Force  
}
if (Test-Path ($Destination + "SD\subtitles")) {
    Start-Process -FilePath $SubtitleEdit -ArgumentList "/convert *.sup subrip /removetextforhi /redocasing /fixcommonerrors /reversertlstartend" -WorkingDirectory "$($Destination)SD\subtitles"  -wait -NoNewWindow 
    Remove-Item ($Destination + 'SD\subtitles\*.sup') -Force  
}
if (Test-Path ($Destination + "4x3\subtitles")) {
    Start-Process -FilePath $SubtitleEdit -ArgumentList "/convert *.sup subrip /removetextforhi /redocasing /fixcommonerrors /reversertlstartend" -WorkingDirectory "$($Destination)4x3\subtitles"  -wait -NoNewWindow 
    Remove-Item ($Destination + '4x3\subtitles\*.sup') -Force  
}

