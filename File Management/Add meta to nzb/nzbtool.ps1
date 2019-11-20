
#$category = 'tv'
#$name = 'billy bob joe s01e22'
#$nzbpass = 'sjdkafksaldfgh'
#$tag = 'h265'
#$filename = "C:\work\xml-powershell\test2.xml"

Param(
  [parameter(Position = 0)]
  [string]$filename = $null,

  [Alias('h')]
  [Switch]$help = $false,

  [Alias('c')]
  [String]$category = $null,

  [Alias('n')]
  [String]$name = $null,

  [Alias('p')]
  [String]$nzbpass = $null,

  [Alias('t')]
  [String]$tag = $null
)
function Write-Color {
    [alias('Write-Colour')]
    [CmdletBinding()]
    param (
        [alias ('T')] [String[]]$Text,
        [alias ('C', 'ForegroundColor', 'FGC')] [ConsoleColor[]]$Color = [ConsoleColor]::White,
        [alias ('B', 'BGC')] [ConsoleColor[]]$BackGroundColor = $null,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $LinesBefore = 0,
        [int] $LinesAfter = 0,
        [int] $StartSpaces = 0,
        [alias ('L')] [string] $LogFile = '',
        [Alias('DateFormat', 'TimeFormat')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [alias ('LogTimeStamp')][bool] $LogTime = $true,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf7', 'utf32', 'ascii', 'default', 'oem')][string]$Encoding = 'Unicode',
        [switch] $ShowTime,
        [switch] $NoNewLine
    )
    $DefaultColor = $Color[0]
    if ($null -ne $BackGroundColor -and $BackGroundColor.Count -ne $Color.Count) { Write-Error "Colors, BackGroundColors parameters count doesn't match. Terminated." ; return }
    #if ($Text.Count -eq 0) { return }
    if ($LinesBefore -ne 0) { for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host -Object "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) { for ($i = 0; $i -lt $StartTab; $i++) { Write-Host -Object "`t" -NoNewLine } }  # Add TABS before text
    if ($StartSpaces -ne 0) { for ($i = 0; $i -lt $StartSpaces; $i++) { Write-Host -Object ' ' -NoNewLine } }  # Add SPACES before text
    if ($ShowTime) { Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))]" -NoNewline } # Add Time before output
    if ($Text.Count -ne 0) {
        if ($Color.Count -ge $Text.Count) {
            # the real deal coloring
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
            }
            else {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
            }
        }
        else {
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
            }
            else {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackGroundColor[0] -NoNewLine }
            }
        }
    }
    if ($NoNewLine -eq $true) { Write-Host -NoNewline } else { Write-Host } # Support for no new line
    if ($LinesAfter -ne 0) { for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host -Object "`n" -NoNewline } }  # Add empty line after
    if ($Text.Count -ne 0 -and $LogFile -ne "") {
        # Save to file
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        try {
            if ($LogTime) {
                Write-Output -InputObject "[$([datetime]::Now.ToString($DateTimeFormat))]$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            }
            else {
                Write-Output -InputObject "$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            }
        }
        catch {
            $_.Exception
        }
    }
}

if ($help -eq $true) {
    Write-Host
    Write-Host
    Write-Host
    Write-Host "nzbtool input [input.nzb] [-h] [-c Category]  [-n Name] [-p Password] [-t Tag]"
    Write-Color -Text "Surround entrees with apostrophes like" , " -p 'Sandy has a place'" -Color White, Green
    Write-Color -Text "If password has an apostrophe you must add another apostrophe, so ", "'Sandy's place' ", "becomes ", "'Sandy''s place'" -Color White, Green, White, Green
    Write-Host
    Write-Host
    exit
}

if (!$filename) {
    Write-Host
    Write-Host
    Write-Host
    Write-Host "nzbtool input [input.nzb] [-h] [-c Category]  [-n Name] [-p Password] [-t Tag]"
    Write-Color -Text "Surround entrees with apostrophes like" , " -p 'Sandy has a place'" -Color White, Green
    Write-Color -Text "If password has an apostrophe you must add another apostrophe, so ", "'Sandy's place' ", "becomes ", "'Sandy''s place'" -Color White, Green, White, Green
    Write-Host
    Write-Host
}

if ($filename) {
  [string]$newxml = ''
  $newxml = '<?xml version="1.0" encoding="utf-8"?>' + "`n", '<!DOCTYPE nzb PUBLIC "-//newzBin//DTD NZB 1.1//EN" "http://www.newzbin.com/DTD/nzb/nzb-1.1.dtd">' + "`n", '<nzb xmlns="http://www.newzbin.com/DTD/2003/nzb">' + "`n", '  <head>' + "`n"
  if ($name) { $newxml = $newxml += '    <meta type="name">' + "$name</meta>" + "`n" }
  if ($category) { $newxml = $newxml += '    <meta type="category">' + "$category</meta>" + "`n" }
  if ($nzbpass) { $nzbpass = $nzbpass.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')}
  if ($nzbpass) { $newxml = $newxml += '    <meta type="password">' + "$nzbpass</meta>" + "`n" }
  if ($tag) { $newxml = $newxml += '    <meta type="tag">' + "$tag</meta>" + "`n" }
  $newxml = $newxml += '  </head>' + "`n", '</nzb>'
  [xml]$file1 = $newxml 
  [xml]$File = Get-Content $filename
  ForEach ($XmlNode in $File.DocumentElement.ChildNodes) { $File1.DocumentElement.AppendChild($File1.ImportNode($XmlNode, $true)) }
  Rename-Item -Path $filename -NewName ($filename + ".bak")
  $File1.Save($filename)
}



#Write-Host "file = $file"
#Write-Host "help = $help"
#Write-Host "category = $category"
#Write-Host "nzbpass = $nzbpass"
#Write-Host "tag = $tag"
