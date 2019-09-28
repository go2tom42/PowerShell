function IsJpegImage {
    param(
        [string]
        $FileName
    )

    try {
        $img = [System.Drawing.Image]::FromFile($filename);
        return $img.RawFormat.Equals([System.Drawing.Imaging.ImageFormat]::Jpeg);
    }
    catch [OutOfMemoryException] {
        return $false;
    }
}

function IsPngImage {
    param(
        [string]
        $FileName
    )

    try {
        $img = [System.Drawing.Image]::FromFile($filename);
        return $img.RawFormat.Equals([System.Drawing.Imaging.ImageFormat]::Png);
    }
    catch [OutOfMemoryException] {
        return $false;
    }
}

function OCRit ($FileName) {
    $FileName = Get-Childitem -LiteralPath $FileName -ErrorAction Stop
    $wslpath = '/mnt/' + $FileName.PSDrive.name.ToLower() + $Filename.DirectoryName.substring(2).Replace("\", "/") + "/" + $Filename.Name
    $OCRwslpath = '/mnt/' + $FileName.PSDrive.name.ToLower() + $Filename.DirectoryName.substring(2).Replace("\", "/") + "/" + $Filename.Basename + '.OCR.pdf'
    If ($FileName.PSDrive.name.ToLower() -eq "x") { Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs X: /mnt/x" -wait -NoNewWindow }
    If ($FileName.PSDrive.name.ToLower() -eq "y") { Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs Y: /mnt/y" -wait -NoNewWindow }
    If ($FileName.PSDrive.name.ToLower() -eq "z") { Start-Process -FilePath "wsl" -ArgumentList "sudo mount -t drvfs Z: /mnt/z" -wait -NoNewWindow }

    $arguments = 'ocrmypdf --deskew --clean ' + '"' + $wslpath + '" "' + $OCRwslpath + '"'

    Start-Process -FilePath "wsl" -ArgumentList $arguments -wait -NoNewWindow
    
}

function jpgTOpdfOCR {
    $CurrentDir = Get-Location
    $CurrentDir = $CurrentDir.Path # |gm
    $ImageList = Get-ChildItem -Path $CurrentDir -Filter *.jpg -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($jpeg in $ImageList) {
        if (IsJpegImage($jpeg)) {
            Write-Host "Valid: $jpeg"
            if (!$jpegList) { 
                $JpegList = @(Get-ChildItem $jpeg)
            }
            Else {
                $JpegList += @(Get-ChildItem $jpeg)
            }
        }
        else {
            Write-Host "Not valid: $jpeg"
        }
    }

    foreach ($Images in $JpegList) {
        $DaList += '"' + $images.name + '" '
    }

    $FileName = Split-Path (Split-Path $Images[0].FullName -Parent) -Leaf
    $arguments = '--output "' + $filename + '.pdf" ' + $DaList
    Start-Process -FilePath "img2pdf" -ArgumentList $arguments -wait -NoNewWindow
    $arguments = $filename + '.pdf'
    OCRit $arguments
}

function pngTOpdfOCR {
    $CurrentDir = Get-Location
    $CurrentDir = $CurrentDir.Path # |gm
    $ImageList = Get-ChildItem -Path $CurrentDir -Filter *.png -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($jpeg in $ImageList) {
        if (IsPngImage($jpeg)) {
            Write-Host "Valid: $jpeg"
            if (!$jpegList) { 
                $JpegList = @(Get-ChildItem $jpeg)
            }
            Else {
                $JpegList += @(Get-ChildItem $jpeg)
            }
        }
        else {
            Write-Host "Not valid: $jpeg"
        }
    }

    foreach ($Images in $JpegList) {
        $DaList += '"' + $images.name + '" '
    }

    $FileName = Split-Path (Split-Path $Images[0].FullName -Parent) -Leaf
    $arguments = '--output "' + $filename + '.pdf" ' + $DaList
    Start-Process -FilePath "img2pdf" -ArgumentList $arguments -wait -NoNewWindow
    $arguments = $filename + '.pdf'
    OCRit $arguments
}



function SingleArchive ($FileName){
    $CurrentDir = Get-Location
    $CurrentDir = $CurrentDir.Path # |gm
    $arguments = 'e "' + $FileName.fullname + '" -o"' + $currentdir + '\' + $FileName.basename + '"'
    Start-Process -FilePath "$env:ProgramFiles\7-Zip\7z.exe" -ArgumentList $arguments -wait -NoNewWindow
    $JpegPath = $currentdir + '\' + $FileName.basename
    $ImageList = Get-ChildItem -Path $JpegPath -Filter *.jpg -ErrorAction SilentlyContinue -Force | Sort-Object


    foreach ($jpeg in $ImageList) {
        if (IsJpegImage($jpeg)) {
            Write-Host "Valid: $jpeg"
            if (!$jpegList) { 
                $JpegList = @(Get-ChildItem $jpeg)
            }
            Else {
                $JpegList += @(Get-ChildItem $jpeg)
            }
        }
        else {
            Write-Host "Not valid: $jpeg"
        }
    }

    foreach ($Images in $JpegList) {
        $DaList += '"' + (Split-Path (Split-Path $Images[0].FullName -Parent) -Leaf) + '\' + $images.name + '" '
    }

    $FileName2 = Split-Path (Split-Path $Images[0].FullName -Parent) -Leaf
    $arguments = '--output "' + $FileName2 + '.pdf" ' + $DaList
    Start-Process -FilePath "img2pdf" -ArgumentList $arguments -wait -NoNewWindow
    $arguments = $FileName2 + '.pdf'
    
    OCRit $arguments
    Remove-Item $JpegPath -Recurse
    
}




if ($args[0] -eq "*.jpg") { jpgTOpdfOCR }
if ($args[0] -ne "*.jpg") { $FileName = Get-ChildItem $args[0] }

if ($args[0] -eq "*.png") { pngTOpdfOCR }
if ($args[0] -ne "*.png") { $FileName = Get-ChildItem $args[0] }


If ($args[0] -eq "*.cbr") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item  
    }
}

If ($args[0] -eq "*.cbz") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item
    }
}

If ($args[0] -eq "*.cb7") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item 
    }
}

If ($args[0] -eq "*.zip") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item   
    }
}

If ($args[0] -eq "*.rar") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item  
    }
}

If ($args[0] -eq "*.7z") { 
    $list = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object
    foreach ($item in $list) {
        SingleArchive $item
    }
}

If ($FileName.extension -eq ".cbr") { SingleArchive $FileName }
If ($FileName.extension -eq ".cbz") { SingleArchive $FileName }
If ($FileName.extension -eq ".cb7") { SingleArchive $FileName }
If ($FileName.extension -eq ".zip") { SingleArchive $FileName }
If ($FileName.extension -eq ".rar") { SingleArchive $FileName }
If ($FileName.extension -eq ".7z") { SingleArchive $FileName }
