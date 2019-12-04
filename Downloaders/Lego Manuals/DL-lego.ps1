$legoURL = "https://brickset.com/exportscripts/instructions"
$wget = "C:\PATH\wget.exe" #file location
#----------------
$scriptFolder = (Get-Location).path #running in powershell
#$scriptFolder = Split-Path $PSCommandPath #running as a powershell script
#----------------

$MyArgs = "-O Brickset-instructions.csv $legoURL"
Start-Process -FilePath $wget -ArgumentList $MyArgs -wait -NoNewWindow

$P = Import-Csv -Path "$scriptFolder\Brickset-instructions.csv"
$p.URL >URLs.txt

$MyArgs = "--retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 -i URLs.txt"
Start-Process -FilePath $wget -ArgumentList $MyArgs -wait -NoNewWindow

ForEach ( $userobject in $p ) {
    $ORfileName = $scriptFolder + "\" + $userobject.URL.Replace("https://www.lego.com/biassets/bi/","")
    $newname = $scriptFolder + "\" + $userobject.SetNumber + ".pdf"
    if (Test-Path $newname ) {
        $random = Get-Random
        $newname = $scriptFolder + "\" + $userobject.SetNumber + "__" + $random + ".pdf"
    }
    Rename-Item -Path $ORfileName -NewName $newname
    }
