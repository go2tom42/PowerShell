$FileName = Get-Childitem -LiteralPath $args[0] -ErrorAction Stop
$BaseName = $FileName.BaseName
New-Item -ItemType "directory" -Path ($FileName.DirectoryName + "\" + $BaseName) | Out-Null
$arguments = '-all "' + $args[0] + '" "' + $FileName.DirectoryName + "\" + $BaseName + "\" + $BaseName +'"'
Start-Process -FilePath "pdfimages" -ArgumentList $arguments -wait -NoNewWindow
