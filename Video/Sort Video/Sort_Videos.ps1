#Uses https://github.com/stax76/Get-MediaInfo (included)
#Uses HandBrakeCLI.exe not included https://handbrake.fr/downloads2.php


Param(
    [Alias('tv')]
    [Switch]$43check = $false,

    [Alias( "h" )]
    [Switch]$help = $false
)

if ($help -eq $true) {
    Write-Host
    Write-Host "Scans *.mkv files in working folder and moves them based on resolution"
    Write-Host "Option -tv requires HandBrakeCLI should only be used on TV episodes"
    Write-Host
    exit
}

$HandBrakeCLI = 'C:\Program Files\HandBrake\HandBrakeCLI.exe'
function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = “Comment” + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}
function Get-MediaInfo {
    [CmdletBinding()]
    [Alias("gmi")]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet("General", "Video", "Audio", "Text", "Image", "Menu")]
        [String] $Kind,

        [int] $Index,

        [Parameter(Mandatory = $true)]
        [string] $Parameter
    )

    begin {
        #$scriptFolder = (Get-Location).path
        $scriptFolder = Split-Path $PSCommandPath
        Add-Type -Path ($scriptFolder + '\MediaInfoNET.dll')

        if ($Env:Path.IndexOf($scriptFolder + ';') -eq -1) {
            $Env:Path = $scriptFolder + ';' + $Env:Path
        }
    }

    Process {
        $mi = New-Object MediaInfo -ArgumentList $Path
        $value = $mi.GetInfo($Kind, $Index, $Parameter)
        $mi.Dispose()
        return $value
    }
}

$VideoList = Get-ChildItem -Path ((Get-Location).path) -Filter "*.mkv" -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($video in $VideoList) {
    $length = Get-MediaInfo $video.FullName -Kind Video -Parameter Height

    if ($length -eq '2160') {
        if ($43check -eq $true) {
            $fullname = $video.FullName
            [String]$AspectCheck = &$HandBrakeCLI --scan -t1 -i "$FullName" --json 2>1$
            if ((($AspectCheck.substring(($AspectCheck.indexof("JSON Title Set:") + 15)) | ConvertFrom-Json).TitleList.Crop[2]) -gt 360) {
                If (!(Test-Path ($video.DirectoryName + "\4x3"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4x3") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4x3\" + $video.Name)        
            } else {               
                If (!(Test-Path ($video.DirectoryName + "\4K"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4K") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4K\" + $video.Name)
            }
        } else {               
            If (!(Test-Path ($video.DirectoryName + "\4K"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4K") }
            Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4K\" + $video.Name)
        }
    }


    if ($length -eq '1080') {
        if ($43check -eq $true) { 
            $fullname = $video.FullName
            [String]$AspectCheck = &$HandBrakeCLI --scan -t1 -i "$FullName" --json 2>1$
            if ((($AspectCheck.substring(($AspectCheck.indexof("JSON Title Set:") + 15)) | ConvertFrom-Json).TitleList.Crop[2]) -gt 180) {
                If (!(Test-Path ($video.DirectoryName + "\4x3"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4x3") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4x3\" + $video.Name)        
            } else { 
                If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name)
            }
        } else { 
            If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
            Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name) 
        }
    }

    if ($length -eq '720') {
        if ($43check -eq $true) { 
            $fullname = $video.FullName
            [String]$AspectCheck = &$HandBrakeCLI --scan -t1 -i "$FullName" --json 2>1$
            if ((($AspectCheck.substring(($AspectCheck.indexof("JSON Title Set:") + 15)) | ConvertFrom-Json).TitleList.Crop[2]) -gt 120) {
                If (!(Test-Path ($video.DirectoryName + "\4x3"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4x3") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4x3\" + $video.Name)        
            } else { 
                If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
                Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name)
            }
        } else { 
            If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
            Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name)
        }
    }
    if ($length -eq '576') {
        If (!(Test-Path ($video.DirectoryName + "\SD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\SD") }
        Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\SD\" + $video.Name)
    }
    if ($length -eq '480') {
        If (!(Test-Path ($video.DirectoryName + "\SD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\SD") }
        Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\SD\" + $video.Name)
    }
}