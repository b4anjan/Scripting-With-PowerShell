
<#
################ This script will #################################

- install the update,
- check if the installation was successful, and display a success or error message on screen in green or red
- send a warning message to the remote host, 
- wait for 5 minutes, and then restart the remote host.

- Note: Make sure to replace the $updatePackagePath, $reportFilePath, and $remoteHostName variables with the actual values for your environment.
#>


# Define the update package path
$updatePackagePath = "C:\Path\To\Update\Package\KB5041585.msu"

# Define the report file path
$reportFilePath = "C:\Path\To\Report\KB5041585_Report.txt"

# Define the remote host name
$remoteHostName = "RemoteHostName"

# Define the warning message
$warningMessage = "Your system will restart in 5 minutes to complete the update installation. Please save any unsaved work."

# Install the update
$updateInstallation = Start-Process -FilePath "wusa.exe" -ArgumentList "$updatePackagePath /quiet /norestart" -Wait -PassThru

# Check if the update installation was successful
if ($updateInstallation.ExitCode -eq 0) {
    
    # Display success message in green
    Write-Host "Update KB5041585 installed successfully." -ForegroundColor Green
} else {
    
    # Display error message in red
    Write-Host "Update KB5041585 installation failed with exit code $($updateInstallation.ExitCode)." -ForegroundColor Red
    
    # Get the error message from the event log
    $errorMessage = Get-WinEvent -FilterHashtable @{LogName = "System"; ID = 20} -MaxEvents 1 | Select-Object -ExpandProperty Message
    Write-Host "Error message: $errorMessage" -ForegroundColor Red
}

# Send the warning message to the remote host
Invoke-Command -ComputerName $remoteHostName -ScriptBlock {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($using:warningMessage, "Update Installation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
}

# Wait for 5 minutes
Start-Sleep -Seconds 300

# Restart the remote host
Invoke-Command -ComputerName $remoteHostName -ScriptBlock {
    Restart-Computer -Force
}