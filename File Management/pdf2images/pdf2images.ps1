$FileName = Get-Childitem -LiteralPath $args[0] -ErrorAction Stop
$BaseName = $FileName.BaseName
New-Item -ItemType "directory" -Path ($FileName.DirectoryName + "\" + $BaseName) | Out-Null
$arguments = '-all "' + $args[0] + '" "' + $FileName.DirectoryName + "\" + $BaseName + "\" + $BaseName +'"'
Start-Process -FilePath "pdfimages" -ArgumentList $arguments -wait -NoNewWindow


$dirList = Get-ChildItem 'd:\work\Stargate\BEAD\Bead&Button magazine\MAIN' -Directory

foreach ($dir in $dirList) {
    $dir2 = '"' + $dir.fullname + '"'
    Set-Location -Path $dir2
    jpg2pdf *.jpg
    }