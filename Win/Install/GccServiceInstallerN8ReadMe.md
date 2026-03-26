## .NET 8 GpsCarControl Service (that runs GCC server).

Instruction how to install it on Windows on port 27999


### Download (Download raw file)
https://github.com/tiesky/yadroSys/blob/master/Win/Install/GccServiceInstallerN8.ps1

### Run PowerShell (Version more than 5) as Administrator (navigate to the folder with the file)

### Grant permissions
> Unblock-File .\GccServiceInstallerN8.ps1

or

> powershell -ExecutionPolicy Bypass -File .\GccServiceInstallerN8.ps1 27999

### INSTALL/UPDATE GccWinService on 27999  (Windows Service Panel GUI must be closed)
> .\GccServiceInstallerN8.ps1 27999

---

### DE-INSTALL GccWinService on 27999 (Windows Service Panel GUI must be closed)
> sc.exe stop GpsCarControl.Server.ManageService27999

> sc.exe delete GpsCarControl.Server.ManageService27999

---

## Extra useful commands  (Windows Service Panel GUI must be closed)

> sc.exe create GpsCarControl.Server.ManageService27999 binPath= 'C:\ProgramData\S-TEC GmbH\GpsCarControl\Server\Port_27999\ServerService\GpsCarControl.Server.ServiceN8.exe 27999' start= auto

> sc.exe start GpsCarControl.Server.ManageService27999

> sc.exe stop GpsCarControl.Server.ManageService27999

> sc.exe delete GpsCarControl.Server.ManageService27999

Setting up WinService user (also possible via GUI, but Default should be OK)
> sc config GpsCarControl.Server.ManageService27999 obj= LocalSystem

