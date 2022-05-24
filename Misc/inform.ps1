Set-MpPreference -DisableRealtimeMonitoring $true
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module -Name tom42tools -Force -AllowClobber
Import-Module -Name tom42tools -Force

If ($env:ChocolateyInstall -eq $null){Install-Choco}
Switch-WindowsDefender -Disable
Set-Location -Path "c:\Users\$env:UserName"
new-item "c:\Users\$env:UserName\work" -itemtype directory

Set-Location -Path "c:\Users\$env:UserName\work"
choco feature enable -n allowGlobalConfirmation
choco install cyg-get cygwin git

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

cyg-get clang dos2unix libclang-devel libclang8 make mingw64-i686-clang mingw64-x86_64-clang
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;c:\tools\cygwin\bin"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

git clone https://github.com/ganelson/inweb.git
cd inweb
git reset --hard aec53d3cd23fd98e0334d3b90c34ccb343a433de
cd ..
Copy-Item inweb/Materials/platforms/windows.mk inweb/platform-settings.mk
Copy-Item inweb/Materials/platforms/inweb-on-windows.mk inweb/inweb.mk
git clone https://github.com/ganelson/intest.git
cd intest
git reset --hard b70e35e7ed6b43caeba3814b0f7482d2d68b6d77
cd ..
git clone https://github.com/ganelson/inform.git
cd inform
git reset --hard 4d9ef0868f693e14f5219fd91756b6d365b7d261
cd ..

Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('#!/bin/bash')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('make -f inweb/inweb.mk initial')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('inweb/Tangled/inweb intest -prototype intest/scripts/intest.mkscript -makefile intest/intest.mk')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('make -f intest/intest.mk force')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('cd inform')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('../inweb/Tangled/inweb -prototype scripts/inform.mkscript -makefile makefile')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('make makers')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('make force')
Add-Content -Path (Join-Path ((Get-Location).Path) 'test.sh') -Value ('make -f inform6/inform6.mk interpreters')

dos2unix test.sh
Start-Process -FilePath "mintty" -ArgumentList '--exec "./test.sh"' -Wait

#cd /cygdrive/c/Users/tom42/work/inform
#../intest/Tangled/intest inform7 -show Acidity

Get-ChildItem -Path ((Get-Location).Path) -Filter '*.exe' -Recurse -ErrorAction SilentlyContinue -Force |
Compress-Archive -DestinationPath "c:\Users\$env:UserName\Desktop\Inform-CLI-Tools.zip"
exit
