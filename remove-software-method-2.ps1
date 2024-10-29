
<#
......................................................................................................................................
How the Script Works
    The script reads the list of remote hosts from a text file named remote_hosts.txt.
    The script loops through each remote host and establishes a remote PowerShell session using the New-PSSession cmdlet.
    The script checks if the software is installed on the remote host using the Get-ItemProperty cmdlet.
    If the software is installed, the script runs the uninstall command using the Start-Process cmdlet.
    The script removes any remaining files and folders associated with the software using the Remove-Item cmdlet.
    The script writes to the log file at each stage of the removal process using the Add-Content cmdlet.

Log File Format
The log file will have the following format:
    Connecting to remote_host1... 2023-02-20 14:30:00
    Software removed successfully from remote_host1 2023-02-20 14:30:05
    Remaining files and folders removed from remote_host1 2023-02-20 14:30:10
    Connecting to remote_host2... 2023-02-20 14:30:15
    Software removed successfully from remote_host2 2023-02-20 14:30:20
    Remaining files and folders removed from remote_host2 2023-02-20 14:30:25

Note
    This script assumes that you have the necessary permissions to connect to the remote hosts and remove the software.
    This script uses the msiexec command to uninstall the software, which is the recommended method for uninstalling MSI-based software.
    This script removes any remaining files and folders associated with the software to ensure a clean uninstall.
......................................................................................................................................
#>

# Define the software to remove
$softwareName = "Cisco AnyConnect Secure Mobility Client"

# Define the uninstall command
$uninstallCommand = "msiexec /x {C6F5B931-9B6A-4E4C-BE7C-5F2A847F4C55} /quiet"

# Define the path to the uninstaller
$uninstallerPath = "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\Uninstall.exe"

# Define the log file path
$logFilePath = "C:\Logs\remove-cisco-anyconnect.log"

# Create the log file if it doesn't exist
if (!(Test-Path -Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File
}

# Get the list of remote hosts from the text file
$remoteHosts = Get-Content -Path "C:\remote_hosts.txt"

# Loop through each remote host
foreach ($remoteHost in $remoteHosts) {
    Write-Host "Connecting to $remoteHost..." -ForegroundColor Green
    Add-Content -Path $logFilePath -Value "Connecting to $remoteHost... $(Get-Date)"

    # Establish a remote PowerShell session
    $session = New-PSSession -ComputerName $remoteHost

    <#
    # Establish a remote PowerShell session with elevated admin level access
    $session = New-PSSession -ComputerName $remoteHost -Credential (Get-Credential) -Authentication CredSSP
    #>

    # Check if the software is installed
    $installed = Invoke-Command -Session $session -ScriptBlock {
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Name $softwareName -ErrorAction SilentlyContinue
    }

    if ($installed) {
        # Run the uninstall command
        Invoke-Command -Session $session -ScriptBlock {
            Start-Process -FilePath $uninstallerPath -ArgumentList "/quiet" -Wait -Verb RunAs
            Start-Process -FilePath "msiexec" -ArgumentList "/x {C6F5B931-9B6A-4E4C-BE7C-5F2A847F4C55} /quiet" -Wait -Verb RunAs
        }
        Write-Host "Software removed successfully from $remoteHost" -ForegroundColor Green
        Add-Content -Path $logFilePath -Value "Software removed successfully from $remoteHost $(Get-Date)"
    } else {
        Write-Host "Software not found on $remoteHost" -ForegroundColor Yellow
        Add-Content -Path $logFilePath -Value "Software not found on $remoteHost $(Get-Date)"
    }

    # Stop the Cisco AnyConnect services
    Invoke-Command -Session $session -ScriptBlock {
        Stop-Service -Name "Cisco AnyConnect Secure Mobility Agent" -Force
    }

    # Take ownership of the files and folders
    Invoke-Command -Session $session -ScriptBlock {
        TakeOwn /F "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client" /R
    }

    # Remove any remaining files and folders
    Invoke-Command -Session $session -ScriptBlock {
        Remove-Item -Path "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client" -Recurse -Force
        Remove-Item -Path "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client" -Recurse -Force
    }
    Write-Host "Remaining files and folders removed from $remoteHost" -ForegroundColor Green
    Add-Content -Path $logFilePath -Value "Remaining files and folders removed from $remoteHost $(Get-Date)"

    # Close the remote PowerShell session
    Remove-PSSession -Session $session
}

