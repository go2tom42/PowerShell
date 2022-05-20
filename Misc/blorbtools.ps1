Set-MpPreference -DisableRealtimeMonitoring $true
Write-Host 'pause #1'
pause
Set-executionpolicy -Force -executionpolicy unrestricted
Write-Host 'pause #2'
pause
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host 'pause #3'
pause

Install-PackageProvider -Name NuGet -Force
Write-Host 'pause #4'
pause

Install-Module -Name tom42tools -Force -AllowClobber
Write-Host 'pause #5'
pause

Import-Module -Name tom42tools -Force
Write-Host 'pause #6'
pause


If ($env:ChocolateyInstall -eq $null){
    Install-Choco
}
Write-Host 'pause #7'
pause

Switch-WindowsDefender -Disable
Set-Location -Path "c:\Users\$env:UserName"

function _pt1 {
	Invoke-WebRequest -Uri "https://gitlab.com/DavidGriffith/blorbtools/-/archive/master/blorbtools-master.zip" -OutFile "C:\Users\$env:UserName\blorbtools-master.zip"
	Expand-Archive -LiteralPath "C:\Users\$env:UserName\blorbtools-master.zip" -DestinationPath "C:\Users\$env:UserName\blorbtools"
	choco feature enable -n allowGlobalConfirmation
	choco install strawberryperl upx
}

function _pt2 {
	Set-Location -Path "c:\Users\$env:UserName\blorbtools\blorbtools-master"
	cpanm PAR::Packer
	cpanm Sort::Fields
	refreshenv
	pp -o infoalpha.exe infoalpha.pl
	pp -o infoblorb.exe infoblorb.pl
	pp -o pblorb.exe pblorb.pl
	pp -o pix2png.exe pix2png.pl
	pp -o scanblorb.exe scanblorb.pl
	pp -o scanquetzal.exe scanquetzal.pl
	upx -9 *.exe
	Compress-Archive -Path *.exe -DestinationPath "C:\Users\$env:UserName\Desktop\blorbtools.zip"
}


Export-Function -Function _pt1 -OutPath (".\")

    $procs = $(Start-Process "powershell" -ArgumentList ('-File .\_pt1.ps1 "') -PassThru -NoNewWindow)
	$procs.WaitForExit()
	$procs | Wait-Process
	Start-Sleep -Seconds 6
	
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 	

Export-Function -Function _pt2 -OutPath ('.\')

    $procs = $(Start-Process "powershell" -ArgumentList ('-File .\_pt2.ps1 "') -PassThru -NoNewWindow)
	$procs.WaitForExit()
	$procs | Wait-Process
	Start-Sleep -Seconds 6

Set-MpPreference -DisableRealtimeMonitoring $false
Switch-WindowsDefender -Enable

