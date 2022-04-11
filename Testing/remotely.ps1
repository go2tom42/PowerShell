(New-Object Net.WebClient).DownloadFile('https://remotely.tom42.pw/Content/Remotely_Installer.exe', (join-path $env:TEMP 'Remotely_Installer.exe')) 
(New-Object Net.WebClient).DownloadFile('https://remotely.tom42.pw/Content/Remotely-Win10-x64.zip', (join-path $env:TEMP 'Remotely-Win10-x64.zip')) 
Start-Process -FilePath "Remotely_Installer.exe"-ArgumentList "-install -quiet -organizationid `"7dffa4eb-e4f6-4b37-9cc4-cc4ac23a9910`" -serverurl `"https://remotely.tom42.pw`" -path `"Remotely-Win10-x64.zip`"" -WorkingDirectory $env:TEMP -Wait 
Start-Sleep -Seconds 10 
Remove-Item -Path (join-path $env:TEMP 'Remotely_Installer.exe') -Force 
Remove-Item -Path (join-path $env:TEMP 'Remotely-Win10-x64.zip') -Force
