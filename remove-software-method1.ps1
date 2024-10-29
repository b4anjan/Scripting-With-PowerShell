<# ..............

    This is a simple script to remove the software.


...................
# Define the software to remove
$softwareName = "Cisco AnyConnect Secure Mobility Client"

# Define the uninstall command
$uninstallCommand = "msiexec /x {C6F5B931-9B6A-4E4C-BE7C-5F2A847F4C55} /quiet"

# Define the path to the uninstaller
$uninstallerPath = "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\Uninstall.exe"

# Check if the software is installed
if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Name $softwareName -ErrorAction SilentlyContinue) {
    # Run the uninstall command
    Start-Process -FilePath $uninstallerPath -ArgumentList "/quiet" -Wait
    Start-Process -FilePath "msiexec" -ArgumentList "/x {C6F5B931-9B6A-4E4C-BE7C-5F2A847F4C55} /quiet" -Wait
    Write-Host "Software removed successfully"
} else {
    Write-Host "Software not found"
}

# Remove any remaining files and folders
Remove-Item -Path "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client" -Recurse -Force
Remove-Item -Path "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client" -Recurse -Force
#>
