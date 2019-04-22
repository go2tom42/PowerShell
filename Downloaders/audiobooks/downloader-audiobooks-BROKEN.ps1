[xml] $xml = Get-Content -Path list1.xml
#$pattern = "[{0}]" -f ([Regex]::Escape( [System.IO.Path]::GetInvalidFileNameChars() -join '' ))

for ($i=82; $i -lt 500; $i++) {
    if ($xml.xml.books.book[$i].language -eq 'English') {
        
        $xml.xml.books.book.authors.author.id[$i] = $xml.xml.books.book.authors.author.id[$i] -replace '[\W]', ''
        $xml.xml.books.book.authors.author.last_name[$i] = $xml.xml.books.book.authors.author.last_name[$i] -replace '[\W]', ''
        $xml.xml.books.book.authors.author.first_name[$i] = $xml.xml.books.book.authors.author.first_name[$i] -replace '[\W]', ''
        $xml.xml.books.book.title[$i] = $xml.xml.books.book.title[$i] -replace '[\W]', ''

        If ($xml.xml.books.book.authors.author.first_name[$i]) {
            $dir = $xml.xml.books.book.authors.author.id[$i] + ' - ' + $xml.xml.books.book.authors.author.last_name[$i] + ', ' + $xml.xml.books.book.authors.author.first_name[$i] + '_'
        }else{
            $dir = $xml.xml.books.book.authors.author.id[$i] + ' - ' + $xml.xml.books.book.authors.author.last_name[$i] + '_'
        }
        #$dir = $dir -replace '[\W]', ''
        $dir = '/data/AB/' + $dir
        If ($xml.xml.books.book.authors.author.first_name[$i]) {
            $filename = $xml.xml.books.book.authors.author.last_name[$i] + ', ' + $xml.xml.books.book.authors.author.first_name[$i] + ' - ' + $xml.xml.books.book.title[$i] + '.zip'
        }else{
            $filename = $xml.xml.books.book.authors.author.last_name[$i] + ' - ' + $xml.xml.books.book.title[$i] + '.zip'
        }
        #$filename = $filename -replace $pattern, ''
        $thisfile = $xml.xml.books.book.url_zip_file[$i]
        $body = '{"jsonrpc":"2.0","id":"qwer","method":"aria2.addUri","params":["token:1tardis1",["' + $thisfile + '"], {"out":"' + $filename +  '", "dir":"' + $dir +  '"}]}'
        $dir
        $filename
        $thisfile
        $body
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
        Invoke-WebRequest -Headers @{"Content-type"="application/json"} -Method Post -Body $body http://192.168.1.88:6800/jsonrpc
        #Start-Sleep -m 25  
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
    }
}

[xml] $xml = Get-Content -Path list1.xml
for ($i=0; $i -lt 500; $i++) {
    if ($xml.xml.books.book[$i].language -eq 'English') {
        
        $xml.xml.books.book[$i].authors.author.first_name = $xml.xml.books.book[$i].authors.author.first_name -replace '[\W]', ''
        $id = $xml.xml.books.book[$i].authors.author.id -replace '[\W]', ''
        $last_name = $xml.xml.books.book[$i].authors.author.last_name -replace '[\W]', ''
        $first_name = $xml.xml.books.book[$i].authors.author.first_name -replace '[\W]', ''
        $title = $xml.xml.books.book[$i].title -replace '[\W]', ''

        If ($xml.xml.books.book[$i].authors.author.first_name) {
            $dir = $id + ' - ' + $last_name + ', ' + $first_name + '_'
        }else{
            $dir = $id + ' - ' + $last_name + '_'
        }
        #$dir = $dir -replace '[\W]', ''
        $dir = '/data/AB/' + $dir
        If ($xml.xml.books.book[$i].authors.author.first_name) {
            $filename = $last_name + ', ' + $first_name + ' - ' + $title + '.zip'
        }else{
            $filename = $last_name + ' - ' + $title + '.zip'
        }
        #$filename = $filename -replace $pattern, ''
        $thisfile = $xml.xml.books.book[$i].url_zip_file
        $body = '{"jsonrpc":"2.0","id":"qwer","method":"aria2.addUri","params":["token:1tardis1",["' + $thisfile + '"], {"out":"' + $filename +  '", "dir":"' + $dir +  '"}]}'
        $dir
        $filename
        $thisfile
        $body
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
        Invoke-WebRequest -Headers @{"Content-type"="application/json"} -Method Post -Body $body http://192.168.1.88:6800/jsonrpc
        #Start-Sleep -m 25  
        #Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
    }
}