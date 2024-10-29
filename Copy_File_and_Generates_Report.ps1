
<#===================================================================================================================
------This Script copies the file to the destination and generates the report----------
===================================================================================================================#>


# Get the list of remote hosts from the text file
$remoteHosts = Get-Content -Path "C:\remote_hosts.txt"

# Define the package file and destination
$packageFile = "C:\Users\1632797539c.adw\Desktop\Deploy-VLCMediaPlayer.ps1"
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

    # Copy the file to the destination
    Robocopy "$packageFile" "\\$remoteHost\$destination" /IS /S /E /MIR /NP /R:1

    # Check if the file exists
    $filePath = "$destination\vlc-3.0.21-win32.exe"
    if (Test-Path -Path "\\$remoteHost\$filePath") {
        # File exists, write a success message to the host
        Write-Host "File exists on $remoteHost" -ForegroundColor Green
        # File exists, add a success result to the array
        $results += [PSCustomObject]@{
            ComputerName = $remoteHost
            FileExists   = $true
        }
    } else {
        # File does not exist, write a failure message to the host
        Write-Host "File does not exist on $remoteHost" -ForegroundColor Red
        # File does not exist, add a failure result to the array
        $results += [PSCustomObject]@{
            ComputerName = $remoteHost
            FileExists   = $false
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\Users\1632797539c.adw\Desktop\vlc_copy_results.csv" -NoTypeInformation

# Write a completion message to the host
Write-Host "Script completed. Results exported to C:\Users\1632797539c.adw\Desktop\vlc_copy_results.csv" -ForegroundColor Yellow