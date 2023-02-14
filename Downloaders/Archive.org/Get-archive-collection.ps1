##################
# Only downloads ORIGINAL files, skips archive.org generated files
# Script Requires "ia" https://github.com/jjjake/internetarchive
# Script Requires "aria2c" https://github.com/aria2/aria2
<# Can Change #>
Param(
    [parameter(Mandatory = $true)]
    [String]
    $collection,
    [parameter(Mandatory = $false)]
    [int]
    $throttle = 16,
    [parameter(Mandatory = $false)]
    [string]
    $destdir = (Get-Location).Path,
    [parameter(Mandatory = $false)]
    [int]
    $max_concurrent = 4,
    [parameter(Mandatory = $false)]
    [int]
    $split = 5
)
<# don't Change #>
#$collection = "red_dwarf_smegazine"
#$throttle = 20
#$max_concurrent = 4
#$split = 5


Start-Process -FilePath "ia" -ArgumentList "search `"collection:$collection`" --itemlist"  -Wait -PassThru -NoNewWindow -RedirectStandardOutput 'itemsINcollection.txt'
$ItemList = Get-Content 'itemsINcollection.txt'

$z = 0  
foreach ($Item in $ItemList) {
    write-progress -id 1 -activity "Getting items" -status "$([math]::Round(($z / $ItemList.Length)  * 100))%" -percentComplete (($z / $ItemList.Length) * 100);
    $ItemName = (ia list -l --columns=name,source $Item | select-string "original")
    for ($i = 0; $i -lt $ItemName.Length; $i++) {
        $ItemName[$i] = $ItemName[$i].ToString().split('original')[0].Trim()    
    }
    $x = 0
    foreach ($ItemURL in $ItemName) {
        #write-progress -id 2 -activity "Getting urls" -status "$([math]::Round(($x / $ItemName.Length)  * 100))%" -percentComplete (($x / $ItemName.Length)  * 100);
        $ItemURL | Out-File -FilePath "filelist.txt" -Append
        $outfile = (split-path $ItemURL -Leaf)
        Write-Output "  dir=$destdir\$collection\$Item" | Out-File -FilePath "filelist.txt" -Append
        Write-Output "  out=$outfile" | Out-File -FilePath "filelist.txt" -Append
        $x++
    }
    $z++
}

Start-Process -FilePath "aria2c" -ArgumentList "-ifilelist.txt -c -x $($throttle) -j $($max_concurrent) -s $($split)" -Wait -PassThru -NoNewWindow 
Remove-Item -Path "filelist.txt" -Force
Remove-Item -Path "itemsINcollection.txt" -Force
