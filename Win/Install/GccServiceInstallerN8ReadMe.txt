
Download
https://github.com/tiesky/yadroSys/blob/master/Win/Install/GccServiceInstallerN8.ps1

Run PowerShell (Version more than 5) as Administrator

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