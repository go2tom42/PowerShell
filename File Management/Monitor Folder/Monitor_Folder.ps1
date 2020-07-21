### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:\FolderWhereStuffChanges"
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true  
### DEFINE ACTIONS AFTER A EVENT IS DETECTED
$action = { 

            Write-Host "start"
            $path = $Event.SourceEventArgs.FullPath
            $changeType = $Event.SourceEventArgs.ChangeType
            $logline = "$(Get-Date), $changeType, $path"
            $extcheck = Get-Childitem -LiteralPath $path -ErrorAction Stop
            $path
            While ($True)
            {
                Write-Host "File Still Being Copied"
                Try { 
                    [IO.File]::OpenWrite($path).Close() 
                    Break
                    }
                Catch { Start-Sleep -Seconds 1 }
            }

            if (($extcheck.Extension -eq ".mp4") -or ($extcheck.Extension -eq ".avi") -or ($extcheck.Extension -eq ".mkv")) {

                if (($extcheck.name.contains(".NORMALIZED.")) -Or ($extcheck.name.contains(".AUDIO."))) {

                    Start-Sleep 1
                } else {
                        $bob = (Test-Path ((Join-Path $extcheck.DirectoryName $extcheck.BaseName) + '.mkv')) -and (Test-Path ((Join-Path $extcheck.DirectoryName $extcheck.BaseName) + '.mp4'))
                        $rob = (Test-Path ((Join-Path $extcheck.DirectoryName $extcheck.BaseName) + '.mkv')) -and (Test-Path ((Join-Path $extcheck.DirectoryName $extcheck.BaseName) + '.avi'))
                        if (($rob -eq "True") -or ($bob -eq "True")) {
                            Start-Sleep 1  
                        } else {
                            Start-Process -PassThru "pwsh" -ArgumentList ('-File c:\PATH\normalize.ps1 "' + $path + '"')    
                        }
                    }
            }
            Write-Host $logline
            
          }    

### DECIDE WHICH EVENTS SHOULD BE WATCHED + SET CHECK FREQUENCY  
$created = Register-ObjectEvent $watcher Created -Action $action

while ($true) {sleep 5} 

