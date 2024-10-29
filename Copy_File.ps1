<#=====================================================================================
-----This script copies the file to the destination.
=====================================================================================#>

$Script:Computers = Get-Content "C:\remote_hosts.txt"

$CompAmt = Get-Content "C:\remote_hosts.txt" | Measure-Object -Line

#Provide directory address, not the file's address.
$packageFile = "C:\Users\1632797539c.adw\Desktop\Updates - cs30958\VLC_update\VLC"  
 
#Provide directory address, not the file's address.
$package = "\\$Computer\C$\SVRT" 
   
$Script:CompAmt = $CompAmt.Lines
$Count = 0

Clear-Host

ForEach ($Computer in $Computers) {
    $Count++
    Write-Host "Running on $Computer ($Count of $CompAmt)" -ForegroundColor Gray

Robocopy "$packageFile" "\\$Computer\C$\SVRT" /IS /S /E /MIR /NP /R:1
}

<#====================================================================================
-----This script checks and generates the report log file of whether the file 
-----exists on destination or not once the copying is completed.
=====================================================================================#>

# Get the list of remote hosts from the text file
$remoteHosts = Get-Content -Path "C:\remote_hosts.txt"

# Define the file path to check
$filePath = "C$\SVRT\vlc-3.0.21-win32.exe"

# Create an array to store the results
$results = @()

# Loop through each remote host
foreach ($remoteHost in $remoteHosts) {
    # Check if the file exists
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
$results | Export-Csv -Path "C:\Users\1632797539c.adw\Desktop\vlc_installation_results.csv" -NoTypeInformation