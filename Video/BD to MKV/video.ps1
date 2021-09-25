#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\1080p_x265.json') + '" -Z "1080p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\1080p_x265.json') + '" -Z "1080p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\4x3_1080p_720p.json') + '" -Z "4x3 1080p to 720p" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\SD_x264.json') + '" -Z "SD x264" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\HD 16x9 720p x265.json') + '" -Z "HD 16x9 720p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
#$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\HD 16x9 720p x264.json') + '" -Z "HD 16x9 720p x264" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 

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
$SourceFolder = (Get-IniContent settings.ini).settings.SourceFolder



if (Test-Path ($SourceFolder + "EPs")) { 
    $VideoList = Get-ChildItem -Path ($SourceFolder + 'EPs') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    $count = 1
    foreach ($video in $VideoList) {
        $Destination = (Get-IniContent settings.ini).settings.Destination
        $Destination = ($Destination + 'EPs\video\')
        $SourceFolder = (Get-IniContent settings.ini).settings.SourceFolder
        $HandBrakeCLI = (Get-IniContent settings.ini).settings.HandBrakeCLI
        $video2 = ($Destination + $video.Name)
        New-Item -ItemType "directory" -Path $Destination -ErrorAction SilentlyContinue | Out-Null
        $mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\HD 16x9 720p x265.json') + '" -Z "HD 16x9 720p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        #$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\1080p_x265.json') + '" -Z "1080p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        Start-Process -FilePath $HandBrakeCLI -ArgumentList $mytmp2  -wait -NoNewWindow  | Tee-Object -FilePath "c:\$count.log"
        $count++
    }
}

if (Test-Path ($SourceFolder + "SD")) { 
    $VideoList = Get-ChildItem -Path ($SourceFolder + 'SD') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($video in $VideoList) {
        $Destination = (Get-IniContent settings.ini).settings.Destination
        $Destination = ($Destination + 'SD\video\')
        $SourceFolder = (Get-IniContent settings.ini).settings.SourceFolder
        $HandBrakeCLI = (Get-IniContent settings.ini).settings.HandBrakeCLI
        $video2 = ($Destination + $video.Name)
        New-Item -ItemType "directory" -Path $Destination -ErrorAction SilentlyContinue | Out-Null
        $mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\SD_x264.json') + '" -Z "SD x264" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        Start-Process -FilePath $HandBrakeCLI -ArgumentList $mytmp2  -wait -NoNewWindow | Tee-Object -FilePath ($video2.Replace('mkv' , 'log'))
    }
}





if (Test-Path ($SourceFolder + "HD")) { 
    $VideoList = Get-ChildItem -Path ($SourceFolder + 'HD') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($video in $VideoList) {
        $Destination = (Get-IniContent settings.ini).settings.Destination
        $Destination = ($Destination + 'HD\video\')
        $SourceFolder = (Get-IniContent settings.ini).settings.SourceFolder
        $HandBrakeCLI = (Get-IniContent settings.ini).settings.HandBrakeCLI
        $video2 = ($Destination + $video.Name)
        New-Item -ItemType "directory" -Path $Destination -ErrorAction SilentlyContinue | Out-Null
        $mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\HD 16x9 720p x265.json') + '" -Z "HD 16x9 720p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        #$mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\1080p_x265.json') + '" -Z "1080p x265" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        Start-Process -FilePath $HandBrakeCLI -ArgumentList $mytmp2  -wait -NoNewWindow  | Tee-Object -FilePath ($video2.Replace('mkv' , 'log'))
    }
}


if (Test-Path ($SourceFolder + "4x3")) { 
    $VideoList = Get-ChildItem -Path ($SourceFolder + '4x3') -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($video in $VideoList) {
        $Destination = (Get-IniContent settings.ini).settings.Destination
        $Destination = ($Destination + '4x3\video\')
        $SourceFolder = (Get-IniContent settings.ini).settings.SourceFolder
        $HandBrakeCLI = (Get-IniContent settings.ini).settings.HandBrakeCLI
        $video2 = ($Destination + $video.Name)
        New-Item -ItemType "directory" -Path $Destination -ErrorAction SilentlyContinue | Out-Null
        $mytmp2 = ('--preset-import-file "' + ((Get-Location).path + '\4x3_1080p_720p.json') + '" -Z "4x3 1080p to 720p" -i "' + $($video.Fullname) + '" -o "' + $($video2) + '"') 
        Start-Process -FilePath $HandBrakeCLI -ArgumentList $mytmp2  -wait -NoNewWindow  | Tee-Object -FilePath ($video2.Replace('mkv' , 'log'))
    }
}






    