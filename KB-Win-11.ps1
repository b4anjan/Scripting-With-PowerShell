
<#
################ This script will #################################

- install the update,
- check if the installation was successful, and display a success or error message on screen in green or red
- send a warning message to the remote host, 
- wait for 5 minutes or any minutes you set, and then restart the remote host.

- Note: Make sure to replace the $updatePackagePath, $reportFilePath, and $remoteHostName variables with the actual values for your environment.
#>


# Define the update package path
$updatePackagePath = "C:\Users\1632797539c.adw\Desktop\Scripts\KB-Win 11 update\windows11.0-kb5043145-x64_ddcc749d840fbc38cdf0ccb34310017acad1d986.msu"

# Define the remote host name
$remoteHostName = "C:\Users\1632797539c.adw\Desktop\Scripts\KB-Win 11 update\remote_host.txt"

# Define the warning message
$warningMessage = "Your system will restart in 5 minutes to complete the update installation. Please save any unsaved work."

# Install the update
$updateInstallation = Start-Process -FilePath "wusa.exe" -ArgumentList "$updatePackagePath /quiet /norestart" -Wait -PassThru

# Check if the update installation was successful
if ($updateInstallation.ExitCode -eq 0) {
    
    # Display success message in green
    Write-Host "Update KB-Win-11 installed successfully." -ForegroundColor Green
} else {
    
    # Display error message in red
    Write-Host "Update KB-Win-11 installation failed with exit code $($updateInstallation.ExitCode)." -ForegroundColor Red
    
    # Get the error message from the event log
    $errorMessage = Get-WinEvent -FilterHashtable @{LogName = "System"; ID = 20} -MaxEvents 1 | Select-Object -ExpandProperty Message
    Write-Host "Error message: $errorMessage" -ForegroundColor Red
}

# Send the warning message to the remote host
Invoke-Command -ComputerName $remoteHostName -ScriptBlock {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($using:warningMessage, "Update Installation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
}

# Wait for 1 minutes
Start-Sleep -Seconds 60

# Restart the remote host
Invoke-Command -ComputerName $remoteHostName -ScriptBlock {
    Restart-Computer -Force
}