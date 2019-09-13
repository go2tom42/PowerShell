$CurrentDir = Get-Location
$CurrentDir = $CurrentDir.Path # |gm

$ImageList = Get-ChildItem -Path $CurrentDir -Filter $args[0] -ErrorAction SilentlyContinue -Force | Sort-Object

foreach ($Images in $ImageList) {
    $DaList += $images.name + " "
}

$FileName = Split-Path (Split-Path $ImageList.FullName[0] -Parent) -Leaf
$arguments = "--output " + $filename + ".pdf " + $DaList
Start-Process -FilePath "img2pdf" -ArgumentList $arguments -wait -NoNewWindow