Set-MpPreference -DisableRealtimeMonitoring $true

If ($env:ChocolateyInstall -eq $null){
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Set-executionpolicy -Force -executionpolicy unrestricted;[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Install-PackageProvider -Name NuGet -Force;Install-Module -Name tom42tools -Force -AllowClobber;Import-Module -Name tom42tools -Force
Toggle-WindowsDefender -Disable
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
Toggle-WindowsDefender -Enable

