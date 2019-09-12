$URLFile = @"
https://archive.org/details/StreamRiverSea
https://archive.org/details/Torchwood_201809
"@


$URLs = $URLFile -split "`n";
$savedPages = @();
foreach ($url in $URLs) {

    $title = Invoke-WebRequest -URI $url.Replace("/download/" , '/details/')
    $title = [regex]::match($title.RawContent, '<span itemprop="name">(.*?)<\/span>').Groups[1].value -replace ':', '-'
    $temp = Invoke-WebRequest -URI $url.Replace("/details/" , '/download/')
    $dir = '/data/BBC Radio/' + $title
    $files = $temp.links.href -match "\.mp3|\.jpg|\.txt|\.gif|\.xml|\.zip" -notmatch "/"
    foreach ($file in $files) {
        $thisfile = $url.Replace("/details/" , '/download/') + '/' + $file
        $body = '{"jsonrpc":"2.0","id":"qwer","method":"aria2.addUri","params":["token:1tardis1",["' + $thisfile + '"], {"dir":"' + $dir +  '", "pause":"true"}]}'
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
        $title
        Invoke-WebRequest -Headers @{"Content-type"="application/json"} -Method Post -Body $body http://192.168.1.88:6800/jsonrpc
    }
       
}



