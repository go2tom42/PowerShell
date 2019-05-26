# set these for your setup
#$magick = 'C:\PROGRA~1\IMAGEM~1.8-Q\magick.exe'
$magick = 'C:\PROGRA~1\GRAPHI~1.31-\gm.exe'
$Logfile = ".\errorlog.txt"
$path = 'y:\media\HDD\Downloads\completed\aria2\knittingreferencelibrary_collection\missing\'
$filelist = ".\filelist.txt"
$tempfolder = 'c:\scripttest\dump'
$i = 150
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Write-Host "Analyze Files ..."
$Files = Get-ChildItem $path -Filter "*.zip"
$1 = (($i * 827) / 100)
$2 = (($i * 1169) / 100)

foreach ($File in $Files) {
    if (Test-path $tempfolder ) {
        Remove-Item -Path $tempfolder -Recurse
    }
    $fullPath = $File.FullName;
    $xmlpath = $fullPath.replace('_images.zip', '_meta.xml')
    $md5XMLpath = $File.FullName.Replace('_images.zip', '_files.xml')
    $BaseName = $File.Name.Replace('_images.zip', '')

    [xml] $md5xml = Get-Content -Path $md5XMLpath
    $md5 = ($md5xml.files.file | Where-Object { $_.name -eq $File.Name }).md5

    [xml] $xml = Get-Content -Path $xmlpath
    $title = $xml.metadata.title

    $hashFromFile = Get-FileHash -Path $fullPath -Algorithm MD5

    if ($hashFromFile.hash -eq $md5) {
        if (Test-Path $filelist ) {
            Remove-Item -Path $filelist -Force   
        }
        
        Expand-Archive -Path $fullpath -DestinationPath $tempfolder
        $ImageFiles = Get-ChildItem $tempfolder -Recurse | Where-Object { $_.Extension -match 'tif|png|jpg' }
        
        foreach ($Image in $ImageFiles) {
            Add-Content $filelist $Image.FullName
        }
        
        $illegalchars2 = [string]::join('', ([System.IO.Path]::GetInvalidFileNameChars())) -replace '\\', '\\'
        $title = $title -replace "[$illegalchars2]", ''
        $title = $title[0..50] -join ''
        $name = """$path\$BaseName - $title.pdf"""

        Write-Host "Starting magick..."
        Start-Process -FilePath $magick -ArgumentList "convert @$filelist -compress jpeg -quality 70 -verbose -density $ix$i -units PixelsPerInch -resize $1x$2 $name" -NoNewWindow -Wait
        Write-Host "Magick done..."
        if (Test-Path $filelist ) {
            Remove-Item -Path $filelist -Force
        }
        Remove-Item -Path $tempfolder -Recurse
    }
    else {
        Add-Content $Logfile "$fullPath had MD5 error"
    }

}