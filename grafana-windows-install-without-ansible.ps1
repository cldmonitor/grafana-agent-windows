# Script to install Grafana agent for Windows

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


Write-Host "Setting up Grafana agent"


if ( -Not [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") ) {

    Write-Host "ERROR: The script needs to be run with Administrator privileges"

    exit
}

# Download and Install Grafana Agent

Write-Host "Downloading Grafana agent Windows Installer"

$DOWLOAD_URL = "https://github.com/grafana/agent/releases/latest/download/grafana-agent-installer.exe.zip"
$OUTPUT_ZIP_FILE = ".\grafana-agent-installer.exe.zip"
$OUTPUT_FILE = ".\grafana-agent-installer.exe"

Invoke-WebRequest -Uri $DOWLOAD_URL -OutFile $OUTPUT_ZIP_FILE
Expand-Archive -LiteralPath $OUTPUT_ZIP_FILE -DestinationPath $OUTPUT_FILE -Force

# Install Grafana agent in silent mode
Write-Host "Installing Grafana agent for Windows"

Start-Process -FilePath ".\grafana-agent-installer.exe\grafana-agent-installer.exe" -ArgumentList "/S /v/qn" -Wait


# Download Dummy Config File

Write-Host "Downloading Dummy Config File"


Invoke-WebRequest -Uri "https://github.com/cldmonitor/grafana-agent-windows/releases/download/latest/agent-config.yaml" -OutFile ".\agent-config.yaml"

# Replace Grafana username and API Key

$username = $args[0]

$password = $args[1]


(Get-Content -Path ".\agent-config.yaml") | ForEach-Object { $_ -replace 'dummyuser', $username -replace 'dummypass', $password } | Set-Content -Path ".\agent-config.yaml"
 
Write-Host "Updating Config File"


Move-Item ".\agent-config.yaml" "C:\Program Files\Grafana Agent\agent-config.yaml" -Force


Write-Host "Wait for Grafana service to initialize"

# Wait for service to initialize after first install
Start-Sleep -s 5


# Restart Grafana agent to load new configuration
Write-Host "Restarting Grafana agent service"


Stop-Service "Grafana Agent"

Start-Service "Grafana Agent"


# Show Grafana agent service status
Get-Service "Grafana Agent"
 
 
