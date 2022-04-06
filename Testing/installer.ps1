function IPUpdater {
    function Get-TimeBasedOneTimePassword
    {
    [CmdletBinding()]
    [Alias('Get-TOTP')]
    param
    (
        # Base 32 formatted shared secret (RFC 4648).
        [Parameter(Mandatory = $true)]
        [System.String]
        $SharedSecret,

        # The date and time for the target calculation, default is now (UTC).
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $Timestamp = (Get-Date).ToUniversalTime(),

        # Token length of the one-time password, default is 6 characters.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Length = 6,

        # The hash method to calculate the TOTP, default is HMAC SHA-1.
        [Parameter(Mandatory = $false)]
        [System.Security.Cryptography.KeyedHashAlgorithm]
        $KeyedHashAlgorithm = (New-Object -TypeName 'System.Security.Cryptography.HMACSHA1'),

        # Baseline time to start counting the steps (T0), default is Unix epoch.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $Baseline = '1970-01-01 00:00:00',

        # Interval for the steps in seconds (TI), default is 30 seconds.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Interval = 30
    )

    # Generate the number of intervals between T0 and the timestamp (now) and
    # convert it to a byte array with the help of Int64 and the bit converter.
    $numberOfSeconds   = ($Timestamp - $Baseline).TotalSeconds
    $numberOfIntervals = [Convert]::ToInt64([Math]::Floor($numberOfSeconds / $Interval))
    $byteArrayInterval = [System.BitConverter]::GetBytes($numberOfIntervals)
    [Array]::Reverse($byteArrayInterval)

    # Use the shared secret as a key to convert the number of intervals to a
    # hash value.
    $KeyedHashAlgorithm.Key = Convert-Base32ToByte -Base32 $SharedSecret
    $hash = $KeyedHashAlgorithm.ComputeHash($byteArrayInterval)

    # Calculate offset, binary and otp according to RFC 6238 page 13.
    $offset = $hash[($hash.Length-1)] -band 0xf
    $binary = (($hash[$offset + 0] -band '0x7f') -shl 24) -bor
              (($hash[$offset + 1] -band '0xff') -shl 16) -bor
              (($hash[$offset + 2] -band '0xff') -shl 8) -bor
              (($hash[$offset + 3] -band '0xff'))
    $otpInt = $binary % ([Math]::Pow(10, $Length))
    $otpStr = $otpInt.ToString().PadLeft($Length, '0')

    Write-Output $otpStr
    }
    function Convert-Base32ToByte
    {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Base32
    )

    # RFC 4648 Base32 alphabet
    $rfc4648 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

    $bits = ''

    # Convert each Base32 character to the binary value between starting at
    # 00000 for A and ending with 11111 for 7.
    foreach ($char in $Base32.ToUpper().ToCharArray())
    {
        $bits += [Convert]::ToString($rfc4648.IndexOf($char), 2).PadLeft(5, '0')
    }

    # Convert 8 bit chunks to bytes, ignore the last bits.
    for ($i = 0; $i -le ($bits.Length - 8); $i += 8)
    {
        [Byte] [Convert]::ToInt32($bits.Substring($i, 8), 2)
    }
    }
    Function New-GuacToken()
    {
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [System.String]
        $Username,

        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [System.String]
        $Password,

        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [System.String]
        $TOTP,

        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 3,
            Mandatory = $true
        )]
        [System.String]
        $Server
    )

    begin
    {
        if ($Null -eq $Password -or $Password.Length -eq 0)
        {
            $SecurePassword = Read-Host "Enter password" -AsSecureString

            # Decode SecureString to Plain text for Guacamole (https://www.powershelladmin.com/wiki/Powershell_prompt_for_password_convert_securestring_to_plain_text)
            # Create a "password pointer"
            $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)

            # Get the plain text version of the password
            $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)

            # Free the pointer
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
        }

        $Body = @{
            username = $Username
            password = $Password
        }

        if($Null -ne $TOTP)
        {
            $Body.Add("guac-totp",$TOTP)
        }

        $Uri = "$Server/api/tokens"
    }
    process
    {

        try
        {
            $RestCall = Invoke-RestMethod -Method POST -Body $Body -Uri $Uri
        }
        catch
        {
            Write-Output "If TOTP is enabled, please provid -TOTP parameters with your TOTP code"
            Write-Warning $_.Exception.Message
            return $False
        }

    }
    end
    {
        $Script:Token = $RestCall.authToken
        $Script:Server = $Server
        return $RestCall
    }
    }
    Function Update-GuacConnection()
    {
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [System.String]
        $DataSource,

        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [System.String]
        $ConnectionId,

        [Parameter(
            Position = 2,
            Mandatory = $True
        )]
        [System.Array]
        $Parameters
    )

    begin
    {
        $Body = $Parameters | ConvertTo-Json
        $Uri = "$Server/api/session/data/$($DataSource)/connections/$($ConnectionId)/?token=$($Token)"
    }
    process
    {
        try
        {
            $RestCall = Invoke-RestMethod -Method PUT -Uri $Uri -ContentType 'application/json' -Body $Body
        }
        catch
        {
            Write-Warning $_.Exception.Message
            return $False
        }
    }
    end
    {
        return $True
    }
    }
    $ipext = ((Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
    $ipint = (Get-NetIPConfiguration|Where-Object{$_.ipv4defaultgateway -ne $null}).IPv4Address.ipaddress
    $TelnetParameters = @{
        "parentIdentifier"= "ROOT"
        "name"= "VMware"
        "protocol"= "vnc"
        "parameters"= @{
          "port"= "5900"
          "read-only"= ""
          "swap-red-blue"= ""
          "cursor"= ""
          "color-depth"= ""
          "clipboard-encoding"= ""
          "disable-copy"= ""
          "disable-paste"= ""
          "dest-port"= ""
          "recording-exclude-output"= ""
          "recording-exclude-mouse"= ""
          "recording-include-keys"= ""
          "create-recording-path"= ""
          "enable-sftp"= ""
          "sftp-port"= ""
          "sftp-server-alive-interval"= ""
          "enable-audio"= ""
          "color-scheme"= ""
          "font-size"= ""
          "scrollback"= ""
          "backspace"= ""
          "terminal-type"= ""
          "create-typescript-path"= ""
          "hostname"= "$ipext"
          "username"= ""
          "password"= "1tardis1"
          "username-regex"= ""
          "password-regex"= ""
          "login-success-regex"= ""
          "login-failure-regex"= ""
          "font-name"= ""
          "typescript-path"= ""
          "typescript-name"= ""
          "recording-path"= ""
          "recording-name"= ""
        }
        "attributes"= @{
          "max-connections"= ""
          "max-connections-per-user"= ""
          "weight"= ""
          "failover-only"= ""
          "guacd-port"= ""
          "guacd-encryption"= ""
          "guacd-hostname"= ""
        }
    }
    New-GuacToken -Username "guacadmin" -Password "guacadmin" -TOTP (Get-TimeBasedOneTimePassword -SharedSecret 'YOHCC4TKKATXG2F4UJRU2J4AHK7YO2FO') -Server "https:\\guac.tom42.pw"
    Update-GuacConnection -DataSource postgresql -Parameters $TelnetParameters -ConnectionId 2 
}
function Install-Choco {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
Function Export-Function {
    <#
    .Synopsis
       Exports a function from a module into a user given path
    
    .Description
       As synopsis
    
    .PARAMETER Function
       This Parameter takes a String input and is used in Both Parameter Sets
    
    .PARAMETER ResolvedFunction
       This should be passed the Function that you want to work with as an object making use of the following
       $ResolvedFunction = Get-Command "Command"
    
    .PARAMETER OutPath
       This is the location that you want to output all the module files to. It is recommended not to use the same location as where the module is installed.
       Also always check the files output what you expect them to.
    
    .PARAMETER PrivateFunction
       This is a switch that is used to correctly export Private Functions and is used internally in Export-AllModuleFunction
    
    .EXAMPLE
        Export-Function -Function Get-TwitterTweet -OutPath C:\TextFile\
    
        This will export the function into the C:\TextFile\Get\Get-TwitterTweet.ps1 file and also create a basic test file C:\TextFile\Get\Get-TwitterTweet.Tests.ps1
    
    .EXAMPLE
        Get-Command -Module SPCSPS | Where-Object {$_.CommandType -eq 'Function'} | ForEach-Object { Export-Function -Function $_.Name -OutPath C:\TextFile\SPCSPS\ }
    
        This will get all the Functions in the SPCSPS module (if it is loaded into memory or in a $env:PSModulePath as required by ModuleAutoLoading) and will export all the Functions into the C:\TextFile\SPCSPS\ folder under the respective Function Verbs. It will also create a basic Tests.ps1 file just like the prior example
    #>
    [cmdletbinding(DefaultParameterSetName='Basic')]
    
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Basic',ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Parameter(Mandatory=$true,ParameterSetName='Passthru',ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [Alias('Command')]
        [Alias('Name')]
        [String]
        $Function,
    
        [Parameter(Mandatory=$true,ParametersetName='Passthru')]
        $ResolvedFunction,
    
        [Parameter(Mandatory=$true,ParameterSetName='Basic')]
        [Parameter(Mandatory=$true,ParameterSetName='Passthru')]
        [Alias('Path')]
        [String]
        $OutPath,
    
        [Parameter(Mandatory=$false,ParametersetName='Passthru')]
        [Alias('Private')]
        [Switch]
        $PrivateFunction
    
        )
    
    $sb = New-Object -TypeName System.Text.StringBuilder
    
     If (!($ResolvedFunction)) { $ResolvedFunction = Get-Command $function}
         $code = $ResolvedFunction | Select-Object -ExpandProperty Definition
         $PublicOutPath = "$OutPath\"
         $ps1 = "$PublicOutPath$($ResolvedFunction.Verb)\$($ResolvedFunction.Name).ps1"
    
            foreach ($line in ($code -split '\r?\n')) {
                $sb.AppendLine('{0}' -f $line) | Out-Null
            }
    
            New-Item $ps1 -ItemType File -Force | Out-Null
            Write-Verbose -Message "Created File $ps1"

            Set-Content -Path $ps1 -Value $($sb.ToString())  -Encoding UTF8
            Write-Verbose -Message "Added the content of function $Function into the file"
    
}

function Add-ScheduledTask {
    $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-ExecutionPolicy Bypass -File ' + [Environment]::SystemDirectory + "\IPUpdater.ps1")
# Create a new trigger (Daily at 3 AM)
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 3PM

# The name of your scheduled task.
$taskName = "IP-UPDATER"

# Describe the scheduled task.
$description = "Updated IP for guac"

# Stops pop up when run
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest


# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $principal -Description $description
}

Export-Function -Function IPUpdater -OutPath (([Environment]::SystemDirectory) + "\")
Install-Choco
choco feature enable -n allowGlobalConfirmation
choco install tightvnc -ia 'SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=1tardis1 SET_REMOVEWALLPAPER=1 VALUE_OF_REMOVEWALLPAPER=0 SET_RUNCONTROLINTERFACE=1 VALUE_OF_RUNCONTROLINTERFACE=0'
Add-ScheduledTask


#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/go2tom42/PowerShell/master/Testing/installer.ps1'))

