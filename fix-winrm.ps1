# Once we get local access to the device:
<#
Check the Status of the service.

	Steps to take:	
		Step one: Check the WinRM service status and starts the service if it's not running.
		Step two: Check the Windows Firewall rules and creates the WinRM rule if it's not found.
		Step three: Check the WinRM configuration  increases the MaxEnvelopeSizekb value if it's too low.
		Step four: Try restarting the WinRM service
		Step five: The script enables PowerShell Remoting.
		Step Six: The script checks if WinRM is listening on port 5985 and adds the listener if it's not found.
#>
#Scripts address the steps:Full Script to Troubleshoot and Fix WinRM Issues Locally.
# Check the WinRM service status

Write-Host "Checking WinRM service status..."
$winrmService = Get-Service -Name WinRM
if ($winrmService.Status -ne "Running") {
    Write-Host "WinRM service is not running. Starting the service..."
    Start-Service -Name WinRM
}

# Check the Windows Firewall rules

Write-Host "Checking Windows Firewall rules..."
$winrmRule = Get-NetFirewallRule -Name "WinRM"
if (!$winrmRule) {
    Write-Host "WinRM firewall rule is not found. Creating the rule..."
    New-NetFirewallRule -Name "WinRM" -DisplayName "Windows Remote Management (WS-Management)" -Direction Inbound -Protocol TCP -LocalPort 5985
}

# Check the WinRM configuration

Write-Host "Checking WinRM configuration..."
$winrmConfig = winrm get winrm/config
if ($winrmConfig.MaxEnvelopeSizekb -lt 500) {
    Write-Host "WinRM MaxEnvelopeSizekb is too low. Increasing the value..."
    winrm set winrm/config @{MaxEnvelopeSizekb = 500}
}

# Try restarting the WinRM service

Write-Host "Restarting WinRM service..."
Restart-Service -Name WinRM -Force

# Enable PowerShell Remoting

Write-Host "Enabling PowerShell Remoting..."
Enable-PSRemoting -Force

# Check if WinRM is listening on port 5985

Write-Host "Checking if WinRM is listening on port 5985..."
$winrmPort = netstat -an | Where-Object { $_ -match "5985" }
if (!$winrmPort) {
    Write-Host "WinRM is not listening on port 5985. Adding the listener..."
    winrm create winrm/config/Listener?Address=*+Transport=HTTP @{Hostname = $env:COMPUTERNAME; Port = 5985}
}



