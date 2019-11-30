#Uses https://github.com/stax76/Get-MediaInfo (included)
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
        If (!(Test-Path ($video.DirectoryName + "\4K"))) { New-Item -ItemType Directory ($video.DirectoryName + "\4K") }
        Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\4K\" + $video.Name)
    }
    if ($length -eq '1080') {
        If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
        Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name)
    }
    if ($length -eq '720') {
        If (!(Test-Path ($video.DirectoryName + "\HD"))) { New-Item -ItemType Directory ($video.DirectoryName + "\HD") }
        Move-Item -Path ($video.FullName) -Destination ($video.DirectoryName + "\HD\" + $video.Name)
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
