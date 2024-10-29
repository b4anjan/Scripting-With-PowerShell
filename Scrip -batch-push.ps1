

<#====================================================================================================================================================
This is Batch Patching Script which uses ".exe" file. This script also writes the log report. This script uses "-Timeout" parameter of max 300 sec 
for any PC to install the update, after that the update process will fail and move to next PC
#>
#=====================================================================================================================================================

# Define text file path containing PC information
$pcListPath = "C:\PCs.txt"

# Define .exe file path
$exeFilePath = "C:\path\to\npp.8.6.7.Installer.x64.exe"

# Read PC list from text file
$pcs = Get-Content -Path $pcListPath

# Create a log file to store the status updates
$logFilePath = "C:\PatchInstallationLog.txt"

# Define the timeout period in seconds
$timeoutSeconds = 300 # 5 minutes

# Loop through PCs
foreach ($pc in $pcs) {
    Write-Host "Installing patch on $pc..."
    Copy-Item -Path $exeFilePath -Destination "\\$pc\C$\Temp"
    Invoke-Command -ComputerName $pc -ScriptBlock {
        param ($exeFilePath)
        $installationResult = Start-Process -FilePath "C:\Temp\$(Split-Path -Leaf $exeFilePath)" -ArgumentList "/S" -Wait -PassThru
        if ($installationResult.ExitCode -eq 0) {
            Write-Host "Patch installation successful on $env:COMPUTERNAME"
            "Patch installation successful on $env:COMPUTERNAME" | Add-Content -Path $logFilePath
        } else {
            Write-Host "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)"
            "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)" | Add-Content -Path $logFilePath
        }
        # Delete the .exe file after installation
        Remove-Item -Path "C:\Temp\$(Split-Path -Leaf $exeFilePath)" -Force
    } -ArgumentList $exeFilePath -Timeout $timeoutSeconds
} 

#Script Two===========================================================================================================================================

<#This is Batch Patching Script which uses ".msi" file. This script also writes the log report. This script uses "-Timeout" parameter of max 300 sec 
for any PC to install the update, after that the update process will fail and move to next PC#>


# Define text file path containing PC information
$pcListPath = "C:\Users\1632797539c.adw\Desktop\Hosts\NesusAgent.txt"

# Define .exe file path
$msiFilePath = "C:\Users\1632797539c.adw\Desktop\Instalation_File\NessusAgent-10.7.3-x64.msi"

# Read PC list from text file
$pcs = Get-Content -Path $pcListPath

# Create a log file to store the status updates
$logFilePath = "C:\Users\1632797539c.adw\Desktop\Log_Report\NesusPatchInstallationLog.txt"

# Define the timeout period in seconds
$timeoutSeconds = 300 # 5 minutes

# Create a session option with the specified timeout
$sessionOption = New-PSSessionOption -OperationTimeout $timeoutSeconds

# Loop through PCs
foreach ($pc in $pcs) {
    Write-Host "Installing patch on $pc..."
    try {
        Copy-Item -Path $msiFilePath -Destination "\\$pc\C$\SVRT" -Force -ErrorAction Stop
        Invoke-Command -ComputerName $pc -ScriptBlock {
            param ($msiFilePath, $logFilePath)
            $installationResult = Start-Process -FilePath "msiexec" -ArgumentList "/i", "C:\SVRT\$(Split-Path -Leaf $msiFilePath)", "/qn" -Wait -PassThru
            if ($installationResult.ExitCode -eq 0) {
                Write-Host "Patch installation successful on $env:COMPUTERNAME"
                "Patch installation successful on $env:COMPUTERNAME" | Add-Content -Path $using:logFilePath
            } else {
                Write-Host "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)"
                "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)" | Add-Content -Path $using:logFilePath
            }
        } -ArgumentList $msiFilePath, $logFilePath -SessionOption $sessionOption -ErrorAction Stop
        
        # Delete the .exe file after installation
        Remove-Item -Path "\\$pc\C$\SVRT\$(Split-Path -Leaf $msiFilePath)" -Force -ErrorAction Stop
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error occurred on $pc : $errorMessage"
        "Error occurred on $pc : $errorMessage" | Add-Content -Path $logFilePath
    }
}
