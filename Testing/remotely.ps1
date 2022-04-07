(New-Object Net.WebClient).DownloadFile('https://remotely.tom42.pw/Content/Remotely_Installer.exe', (join-path (Get-Location).Path 'Remotely_Installer.exe'))
(New-Object Net.WebClient).DownloadFile('https://remotely.tom42.pw/Content/Remotely-Win10-x64.zip', (join-path (Get-Location).Path 'Remotely-Win10-x64.zip'))
Start-Process -FilePath "Remotely_Installer.exe"-ArgumentList '-install -quiet -organizationid "4cdb842b-3104-4d01-83b6-5d117f61550c" -serverurl "https://remotely.tom42.pw" -path "Remotely-Win10-x64.zip"'
