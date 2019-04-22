$filelist = Get-ChildItem 'z:\comics\New DC' -file

ForEach ($file in $filelist) {
    #$newdir = [regex]::match($file.name,'((\d{5}\s)(.*?)(\s\d{1}))').Groups[3].Value
    $newdir = [regex]::match($file.name,"((\d{5})(.*?)([^a-z '\-A-Z]))").Groups[3].Value
    $newdir = $file.Directoryname +'\'+$newdir.Trim()
    if (Test-Path $newdir -PathType Container) {Echo 'true' } else {New-Item -Path $newdir -ItemType "directory"}
    $newdir = $newdir + '\' + $file.name
    Move-Item -literalpath $file.fullname -Destination $newdir
}