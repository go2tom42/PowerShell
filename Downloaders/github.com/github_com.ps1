$pagecount = 1
for ($i = 0; $i -lt 3; $i++) {
    $page = Invoke-RestMethod -URI ('https://api.github.com/users/historicalsource/repos?page=' + $pagecount + '&per_page=100')
    If ($page.clone_url.count -eq 0) {
        foreach ($link in $links) {
            Start-Process -FilePath "git" -ArgumentList ("clone " + $link) -Wait
            $pagecount = 1
            $i = 50
        }
    }
    Else {
        $links = $links + $page.clone_url
        $pagecount++
        $i = 0
    }
}