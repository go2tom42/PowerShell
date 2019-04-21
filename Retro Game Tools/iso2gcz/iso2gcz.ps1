$ListOf7zFile = (Get-ChildItem -Path '*.7z' ).FullName

:Outer foreach ($7zfile in $ListOf7zFile)
{
    if(Test-Path -Path $7zfile.Replace("7z" , "gcz"))
    {
        $echo = $7zfile.Replace("7z" , "gcz") +" Already Exists"
    Echo $echo
    continue :Outer    
    }
    $arguments = "x " + '"' + $7zfile + '"'
    Start-Process -FilePath "7za" -ArgumentList $arguments -Wait -NoNewWindow
    $ListOfiso = (Get-ChildItem -Path '*.iso' ).FullName
    $arguments = 'COPY "' + $ListOfiso + '" --gcz "' + $ListOfiso.Replace("iso" , "gcz") + '"'
    Start-Process -FilePath "wit"  -ArgumentList $arguments -Wait -NoNewWindow
    if(Test-Path -Path $ListOfiso.Replace("iso" , "gcz"))
    {
    Remove-Item $ListOfiso
    }
}
