Get-BAFile 'https://remotely.tom42.pw/Content/Remotely_Installer.exe' (join-path $env:TEMP 'Remotely_Installer.exe') 'tom42' '1tardis1'
Get-BAFile 'https://remotely.tom42.pw/Content/Remotely-Win10-x64.zip' (join-path $env:TEMP 'Remotely-Win10-x64.zip') 'tom42' '1tardis1'
Start-Process -FilePath "Remotely_Installer.exe"-ArgumentList "-install -quiet -organizationid `"9ad46f38-6ec3-410f-b853-2f3bd3ec16c3`" -serverurl `"https://remotely.tom42.pw`" -path `"Remotely-Win10-x64.zip`"" -WorkingDirectory $env:TEMP -Wait 
Start-Sleep -Seconds 10 
Remove-Item -Path (join-path $env:TEMP 'Remotely_Installer.exe') -Force 
Remove-Item -Path (join-path $env:TEMP 'Remotely-Win10-x64.zip') -Force
