#ubuntu1804 config --default-user root

$FileName = Get-Childitem -LiteralPath $args[0] -ErrorAction Stop
$wslpath = '/mnt/' + $FileName.PSDrive.name.ToLower() + $Filename.DirectoryName.substring(2).Replace("\","/") + "/" + $Filename.Name
$OCRwslpath = '/mnt/' + $FileName.PSDrive.name.ToLower() + $Filename.DirectoryName.substring(2).Replace("\","/") + "/" + $Filename.Basename + '.OCR.pdf'
If($FileName.PSDrive.name.ToLower() -eq "x") {Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs X: /mnt/x" -wait -NoNewWindow}
If($FileName.PSDrive.name.ToLower() -eq "y") {Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs Y: /mnt/y" -wait -NoNewWindow}
If($FileName.PSDrive.name.ToLower() -eq "z") {Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs Z: /mnt/z" -wait -NoNewWindow}

$arguments = 'ocrmypdf --deskew --clean ' + '"' + $wslpath + '" "' + $OCRwslpath + '"'

Start-Process -FilePath "wsl" -ArgumentList $arguments -wait -NoNewWindow