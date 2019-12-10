Set-Clipboard -Value ((Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content