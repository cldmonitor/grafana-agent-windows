# Script to install Grafana agent for Windows

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


Write-Host "Setting up Grafana agent"


if ( -Not [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") ) {

    Write-Host "ERROR: The script needs to be run with Administrator privileges"

    exit
}

# Install Grafana agent in silent mode
Write-Host "Installing Grafana agent for Windows"

Start-Process -FilePath "C:\tmp\grafana-agent-installer.exe\grafana-agent-installer.exe" -ArgumentList "/S /v/qn" -Wait


# Replace Grafana username and API Key

$username = $args[0]

$password = $args[1]


(Get-Content -Path "C:\tmp\agent-config.yaml") | ForEach-Object { $_ -replace 'dummyuser', $username -replace 'dummypass', $password } | Set-Content -Path "C:\tmp\agent-config.yaml"
 
Write-Host "Updating Config File"


Move-Item "C:\tmp\agent-config.yaml" "C:\Program Files\Grafana Agent\agent-config.yaml" -Force


Write-Host "Wait for Grafana service to initialize"

# Wait for service to initialize after first install
Start-Sleep -s 5


# Restart Grafana agent to load new configuration
Write-Host "Restarting Grafana agent service"


Stop-Service "Grafana Agent"

Start-Service "Grafana Agent"


# Show Grafana agent service status
Get-Service "Grafana Agent"
 
 
