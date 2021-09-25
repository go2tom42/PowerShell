
Param(
    [parameter(Mandatory = $false, 
    HelpMessage = ("`n`n`n`n`n" +
    "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n"))]
    [ValidateScript({
        if (get-command $_) {$true}
        else {
            $Message = ("`n`n`nAPP NOT FOUND`n`n" +
            "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n")
            write-host $Message
            exit
            }})]
    [String]$app,

    [parameter(Mandatory = $false,
    HelpMessage = ("`n`n`n`n`n" +
    "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n"))]
    [ValidateScript({
        if (Test-Path -Path $_) {$true}
        else {
            $Message = ("`n`n`nPATH NOT FOUND`n`n" +
            "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n")
            write-host $Message
            exit
            }})]
    [Alias('folder')]        
    [String]$pathcli,
    
    [parameter(Mandatory = $false,
    HelpMessage = ("`n`n`n`n`n" +
    "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n"))]
    [Alias('ext')]
    [ValidateScript({
        if (Test-Path -Path (Join-Path $pathcli ('*.' + $_))) {$true}
        else {
            $Message = ("`n`n`nFILE NOT FOUND`n`n" +
            "do-many input [input ...]                                                         `n" +
            "           -h/-help (This Screen)                                                 `n" +
            "           -app (app to do many of) (*Mandatory*)                                 `n" +
            "           -path (path to the many files) (*Mandatory*)                           `n" +
            "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
            "           -extra (command agruments for app besides many file)                   `n" +
            "                                                                                  `n" +
            "     You don't have to use the switches, If you don't order matters               `n" +
            "                                                                                  `n" +
            '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
            "                            IS THE SAME AS                                        `n" +
            '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n")
            write-host $Message
            exit
            }})]
    [String]$cliext,
    [parameter(Mandatory = $false,
    HelpMessage = ("`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n" +
    "do-many input [input ...]                                                         `n" +
    "           -h/-help (This Screen)                                                 `n" +
    "           -app (app to do many of) (*Mandatory*)                                 `n" +
    "           -path (path to the many files) (*Mandatory*)                           `n" +
    "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
    "           -extra (command agruments for app besides many file)                   `n" +
    "                                                                                  `n" +
    "     You don't have to use the switches, If you don't order matters               `n" +
    "                                                                                  `n" +
    '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
    "                            IS THE SAME AS                                        `n" +
    '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n"))]
    [String]$extra,
    [parameter(Mandatory = $false)]
    [Alias('h')]
    [Switch]$help = $false
)


if (($pathcli -eq "") -or ($app -eq "") -or ($cliext -eq "")) {
    $help = $true
} 

if ($help -eq $true ) {
    $Message = ("`n`n`n`n`n" +
    "do-many input [input ...]                                                         `n" +
    "           -h/-help (This Screen)                                                 `n" +
    "           -app (app to do many of) (*Mandatory*)                                 `n" +
    "           -path (path to the many files) (*Mandatory*)                           `n" +
    "           -ext (file extension to look for in the path) (*Mandatory*)           `n" +
    "           -extra (command agruments for app besides many file)                   `n" +
    "                                                                                  `n" +
    "     You don't have to use the switches, If you don't order matters               `n" +
    "                                                                                  `n" +
    '     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"                            ' + "`n" +
    "                            IS THE SAME AS                                        `n" +
    '     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"     ' + "`n")
    write-host $Message
    exit
    
}




$collection = Get-ChildItem -LiteralPath $pathcli -Include ('*.' + $cliext) -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($item in $collection) {
    (Start-Process "pwsh" -ArgumentList ('-File "' + (get-command $app).Source + '" "' + $item + '" ' + $extra) -wait -PassThru -NoNewWindow)
}
