# get last folder of URL $url.split('/')[$url.Split("/").value -1]

if ($args.count -ne 0) {
    $URLs = $args[0]
}
else {
    $URLFile = @"
https://archive.org/details/Mule_atari8
"@
    $URLs = $URLFile -split "`n";
    $savedPages = @();        
}

function GetCollection($url) {
    if ($global:dir.EndsWith('/')) {Echo '' } else { $global:dir = $global:dir + '/'}
    $global:dir = $global:dir + $url.split('/')[$url.Split("/").value - 1] + '_collection'
    $dirtemp = $global:dir
    $xmlurl = 'https://archive.org/advancedsearch.php?q=collection%3A%28' + $url.split('/')[$url.Split("\").value - 1] + '%29&fl%5B%5D=identifier&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=10000&page=1&callback=callback&output=rss'
    $xmllist = [xml](Invoke-WebRequest -URI $xmlurl)
    $xmllist = $xmllist.rss.channel.item.link
    foreach ($url in $xmllist) {
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
        if ($dir.Split('/').count -gt 3) {
            $global:dir = $dirtemp
        }
        ReCheck($url)
    }
}
function GetFiles($url) {
    $xmlfile = $url + '/' + $url.split('/')[$url.Split("/").value - 1] + '_files.xml'
    $xmllist = [xml](Invoke-WebRequest -URI $xmlfile.Replace("/details/" , '/download/'))
    $filelist = ($xmllist.files.file | where { $_.source.startsWith("orig") }).name
    
    ForEach ($file in $filelist) {
        $dirtemp = $global:dir
        $global:dir = $global:dir + '/' + $url.split('/')[$url.Split("/").value - 1] + '/' + (Split-Path -Path $file -Parent).replace('\', '/')
        $thisfile = $url.Replace("/details/" , '/download/') + '/' + $file
        $body = '{"jsonrpc":"2.0","id":"qwer","method":"aria2.addUri","params":["token:17@r4151",["' + $thisfile + '"], {"dir":"' + $global:dir + '", "pause":"true"}]}'
        $title
        Invoke-WebRequest -Headers @{"Content-type" = "application/json"} -Method Post -Body $body http://192.168.1.88:6800/jsonrpc
        $global:dir = $dirtemp
    }
}
function GetArchiveType($typeurl) {
    $type = Invoke-WebRequest -URI $typeurl.Replace("/download/" , '/details/')
    $type = [regex]::match($type.RawContent, 'mediaType: "(.*?)",').Groups[1].value -replace ':', '-'
    return $type
}
function ReCheck($url) {
    switch (GetArchiveType $url) 
    {
        "collection" {GetCollection $url; break}
        default {GetFiles $url; break}
    }    
}
foreach ($url in $URLs) {
    $global:dir = '/data/'
    switch (GetArchiveType $url) {
        "collection" {GetCollection $url; break}
        default {GetFiles $url; break}
    }
}