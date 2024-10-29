<#===================================================================================================================
------This Script copies the file to the destination and generates the report----------
===================================================================================================================#>


# Get the list of remote hosts from the text file
$remoteHosts = Get-Content -Path "C:\remote_hosts.txt"

# Define the package file and destination
# Make sure to provide directory path not the file's path
$packageFile = "C:\Users\1632797539c.adw\Desktop\vlc"
$destination = "C$\SVRT"

# Create an array to store the results
$results = @()

# Initialize the count variable
$Count = 0

# Get the total number of computers
$CompAmt = $remoteHosts.Count

Clear-Host

# Loop through each remote host
foreach ($remoteHost in $remoteHosts) {
    $Count++
    Write-Host "Running on $remoteHost ($Count of $CompAmt)" -ForegroundColor Gray

    # Check if the remote host is online
    if (!(Test-Connection -ComputerName $remoteHost -Quiet)) {
        # Remote host is offline, write a message to the host
        Write-Host "Remote host $remoteHost is offline, skipping..." -ForegroundColor Red
        # Remote host is offline, add a result to the array
        $results += [PSCustomObject]@{
            ComputerName = $remoteHost
            FileExists   = $false
            Copied       = $false
            Online       = $false
        }
        continue
    }

    # Remote host is online, check if the destination folder exists
    if (!(Test-Path -Path "\\$remoteHost\$destination")) {
        # Destination folder does not exist, create it
        New-Item -Path "\\$remoteHost\$destination" -ItemType Directory -Force
        Write-Host "Destination folder created on $remoteHost" -ForegroundColor Green
    }

    # Copy the file to the destination, overwriting the existing file if it exists
    Robocopy "$packageFile" "\\$remoteHost\$destination" /IS /S /E /MIR /NP /R:1 /MOV

    # Check if the file was copied successfully
    $filePath = "$destination\Deploy-VLCMediaPlayer.ps1"
    if (Test-Path -Path "\\$remoteHost\$filePath") {
        # File was copied, write a success message to the host
        Write-Host "File copied to $remoteHost" -ForegroundColor Green
        # File was copied, add a success result to the array
        $results += [PSCustomObject]@{
            ComputerName = $remoteHost
            FileExists   = $true
            Copied       = $true
            Online       = $true
        }
    } else {
        # File was not copied, write a failure message to the host
        Write-Host "File not copied to $remoteHost" -ForegroundColor Red
        # File was not copied, add a failure result to the array
        $results += [PSCustomObject]@{
            ComputerName = $remoteHost
            FileExists   = $false
            Copied       = $false
            Online       = $true
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\Users\1632797539c.adw\Desktop\vlc_copy_results.csv" -NoTypeInformation

# Write a completion message to the host
Write-Host "Script completed. Results exported to C:\Users\1632797539c.adw\Desktop\vlc_copy_results.csv" -ForegroundColor Yellow