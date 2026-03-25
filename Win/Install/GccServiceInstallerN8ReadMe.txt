
Download
https://github.com/tiesky/yadroSys/blob/master/Win/Install/GccServiceInstallerN8.ps1

Run PowerShell (Version more than 5) as Administrator

grant ability to be run
> Unblock-File .\GccServiceInstallerN8.ps1

if you want to install/update it on 27999
> .\GccServiceInstallerN8.ps1 27999

to deinstall type (note Windows Service Panel GUI is closed)
> sc.exe stop GpsCarControl.Server.ManageService27999
> sc.exe delete GpsCarControl.Server.ManageService27999


--- Extra useful commands

sc.exe create GpsCarControl.Server.ManageService27999 binPath= 'C:\ProgramData\S-TEC GmbH\GpsCarControl\Server\Port_27999\ServerService\GpsCarControl.Server.ServiceN8.exe 27999' start= auto
sc.exe start GpsCarControl.Server.ManageService27999
sc.exe stop GpsCarControl.Server.ManageService27999
sc.exe delete GpsCarControl.Server.ManageService27999


--- Automatic ways to download

# 1. Define URL and local path
$url = "https://github.com/tiesky/yadroSys/raw/refs/heads/master/Win/Install/GccServiceInstallerN8.ps1"
$scriptPath = "$env:TEMP\GccServiceInstallerN8.ps1"

# 2. Download the script
Invoke-WebRequest -Uri $url -OutFile $scriptPath

# 3. Unblock the script (remove Mark-of-the-Web)
Unblock-File -Path $scriptPath

# 4. Execute with port argument (example: 27999)
& $scriptPath 27999

--- another way if execution policy blocks it
powershell -ExecutionPolicy Bypass -File $scriptPath 27999