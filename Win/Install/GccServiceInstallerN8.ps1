param(
    [Parameter(Mandatory = $true)]
    [int]$Port
)

# --- Config ---
$basePath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)
$workingFolder = Join-Path $basePath "S-TEC GmbH\GpsCarControl\Server\Port_$Port\ServerService"

$zipUrl = "https://github.com/tiesky/yadroSys/raw/refs/heads/master/Win/Install/GpsCarControl.Server.ServiceN8.zip"
$versionUrl = "https://github.com/tiesky/yadroSys/raw/refs/heads/master/Win/Install/GccServiceN8Version.txt"

$zipFile = Join-Path $workingFolder "GpsCarControl.Server.ServiceN8.zip"
$versionFile = Join-Path $workingFolder "GccServiceN8Version.txt"

$serviceName = "GpsCarControl.Server.ManageService$Port"
$exePath = Join-Path $workingFolder "GpsCarControl.Server.ServiceN8.exe"

# --- Ensure folder exists ---
if (!(Test-Path $workingFolder)) {
    New-Item -ItemType Directory -Path $workingFolder -Force | Out-Null
}

# --- Helper: download file ---
function Download-File($url, $destination) {
    Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
}

# --- Version handling ---
$downloadRequired = $false

try {
    $remoteVersion = (Invoke-WebRequest -Uri $versionUrl -UseBasicParsing).Content.Trim()
} catch {
    Write-Error "Failed to fetch remote version."
    exit 1
}

if (!(Test-Path $versionFile)) {
    $downloadRequired = $true
} else {
    $localVersion = (Get-Content $versionFile -Raw).Trim()

    if ([int64]$remoteVersion -gt [int64]$localVersion) {
        $downloadRequired = $true
    }
}

# --- Download if needed ---
if ($downloadRequired) {
    Write-Host "Downloading new version..."

    Download-File $zipUrl $zipFile
    Download-File $versionUrl $versionFile

    # Clean folder except zip + version
    Get-ChildItem $workingFolder -Exclude "*.zip","*.txt" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    # Extract
    Expand-Archive -Path $zipFile -DestinationPath $workingFolder -Force
}
else {
    Write-Host "Latest version already installed."
}

# --- Validate EXE exists ---
if (!(Test-Path $exePath)) {
    Write-Error "Service executable not found after extraction."
    exit 1
}

# --- Service management ---
$serviceExists = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($serviceExists) {
    Write-Host "Service exists. Restarting..."

    & sc.exe stop $serviceName | Out-Null
    Start-Sleep -Seconds 2

    & sc.exe start $serviceName | Out-Null
}
else {
    Write-Host "Creating service..."

    $binPath = "`"$exePath`" $Port"

    & sc.exe create $serviceName binPath= $binPath start= auto | Out-Null
    Start-Sleep -Seconds 2

    & sc.exe start $serviceName | Out-Null
}

Write-Host "Done."