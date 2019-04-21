if ($args.count -ne 0) {
    $URLs = $args[0]
} else {
    $URLFile = @"
https://www.cbs.com/shows/star_trek_the_next_generation/video/star-trek-the-next-generation-all-good-things-part-1-of-2/
https://www.cbs.com/shows/star_trek_the_next_generation/video/star-trek-the-next-generation-all-good-things-part-2-of-2/
"@
    $URLs = $URLFile -split "`n";
    $savedPages = @();
}
    

$UserCount = 0
foreach($url in $URLs) 
{
    # Limit 5 downloads at once
    if(++$UserCount % 5 -eq 0) 
    {
        Wait-Process -Name youtube-dl
    }
    #CBS.com's 1080p videos are bitstarved
	Start-Process -FilePath "youtube-dl" -ArgumentList ('--cookies c:\scripts\cookies.txt -f "best[height=720]" ' + $url)
}