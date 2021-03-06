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
if (Test-Path ($Destination + 'EPs\Normalize\2')) {
    $AudioList = Get-ChildItem -Path ($Destination + 'EPs\Normalize\2') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $AudioList) {
        $ArgumentList = ('"' + $file.FullName + '" -c:a ac3 -b:a 384k -ar 48000 --progress --verbose -o "' + $file.FullName.replace('Normalize\2','audio') + '"')
        Start-Process -FilePath ffmpeg-normalize -ArgumentList $ArgumentList -wait -NoNewWindow 
    }   
}

if (Test-Path ($Destination + 'HD\Normalize\2')) {
    $AudioList = Get-ChildItem -Path ($Destination + 'HD\Normalize\2') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $AudioList) {
        $ArgumentList = ('"' + $file.FullName + '" -c:a ac3 -b:a 384k -ar 48000 --progress --verbose -o "' + $file.FullName.replace('Normalize\2','audio') + '"')
        Start-Process -FilePath ffmpeg-normalize -ArgumentList $ArgumentList -wait -NoNewWindow 
    }   
}

if (Test-Path ($Destination + 'SD\Normalize\2')) {
    $AudioList = Get-ChildItem -Path ($Destination + 'SD\Normalize\2') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $AudioList) {
        $ArgumentList = ('"' + $file.FullName + '" -c:a ac3 -b:a 384k -ar 48000 --progress --verbose -o "' + $file.FullName.replace('Normalize\2','audio') + '"')
        Start-Process -FilePath ffmpeg-normalize -ArgumentList $ArgumentList -wait -NoNewWindow 
    }   
}

if (Test-Path ($Destination + '4x3\Normalize\2')) {
    $AudioList = Get-ChildItem -Path ($Destination + '4x3\Normalize\2') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($file in $AudioList) {
        $ArgumentList = ('"' + $file.FullName + '" -c:a ac3 -b:a 384k -ar 48000 --progress --verbose -o "' + $file.FullName.replace('Normalize\2','audio') + '"')
        Start-Process -FilePath ffmpeg-normalize -ArgumentList $ArgumentList -wait -NoNewWindow 
    }   
}