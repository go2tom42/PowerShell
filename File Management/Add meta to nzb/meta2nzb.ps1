
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

 if ($help -eq $true) {
  Write-Host "nzbtool input [input.nzb] [-h] [-c Category]  [-n Name] [-p Password] [-t Tag]"
  exit
 }

if ($filename) {
  [string]$newxml = ''
  $newxml = '<?xml version="1.0" encoding="utf-8"?>' + "`n", '<!DOCTYPE nzb PUBLIC "-//newzBin//DTD NZB 1.1//EN" "http://www.newzbin.com/DTD/nzb/nzb-1.1.dtd">' + "`n", '<nzb xmlns="http://www.newzbin.com/DTD/2003/nzb">' + "`n", '  <head>' + "`n"
  if ($name) { $newxml = $newxml += '    <meta type="name">' + "$name</meta>" + "`n" }
  if ($category) { $newxml = $newxml += '    <meta type="category">' + "$category</meta>" + "`n" }
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
