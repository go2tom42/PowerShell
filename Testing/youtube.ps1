$api_key = 'YOUR API KEY'

function get-channel-uploads ($channel_id) {
    $result = Invoke-RestMethod `
        "https://www.googleapis.com/youtube/v3/channels?id=$channel_id&key=$api_key&part=contentDetails"

    $result.items[0].contentDetails.relatedPlaylists.uploads
}

function get-playlist-videos ($id) {
    $items = @()
    $ls = ''

    while ($true) {
        if ($ls.nextPageToken -eq $null) {
            $ls = Invoke-RestMethod `
            ('https://www.googleapis.com/youtube/v3/playlistItems?playlistId={0}&key={1}&part=snippet&maxResults=50' -f $id, $api_key)

            $items = $items + $ls.items
        }
        else {
            $ls = Invoke-RestMethod `
            ('https://www.googleapis.com/youtube/v3/playlistItems?playlistId={0}&key={1}&part=snippet&maxResults=50&pageToken={2}' -f $id, $api_key, $ls.nextPageToken)

            $items = $items + $ls.items
        }

        Write-Host -ForegroundColor Yellow ('totalResults = {0}   Count = {1}' -f $ls.pageInfo.totalResults, $items.Count)

        Start-Sleep -Seconds 1    

        if ($items.Count -ge $ls.pageInfo.totalResults) {
            break
        }
    }   

    $items
}