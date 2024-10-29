# Define text file path containing PC information
$pcListPath = "C:\remote_hosts.txt"

# Define .exe file path on the remote hosts
$exeFilePath = "C$\SVRT\vlc-3.0.21-win32.exe"

# Read PC list from text file
$pcs = Get-Content -Path $pcListPath

# Create a log file to store the status updates
$logFilePath = "C:\Users\1632797539c.adw\Desktop\PatchInstallationLog.txt"

# Define the timeout period in seconds
$timeoutSeconds = 300 # 5 minutes

# Loop through PCs
foreach ($pc in $pcs) {
    Write-Host "Installing patch on $pc..."
    $destinationPath = "\\$pc\$exeFilePath"
    if (Test-Path -Path $destinationPath) {
        $sessionOption = New-PSSessionOption -OperationTimeout $timeoutSeconds
        Invoke-Command -ComputerName $pc -ScriptBlock {
            param ($exeFilePath)
            $installationResult = Start-Process -FilePath $exeFilePath -ArgumentList "/S" -Wait -PassThru
            if ($installationResult.ExitCode -eq 0) {
                Write-Host "Patch installation successful on $env:COMPUTERNAME"
                "Patch installation successful on $env:COMPUTERNAME" | Add-Content -Path $using:logFilePath
            } else {
                Write-Host "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)"
                "Patch installation failed on $env:COMPUTERNAME with exit code $($installationResult.ExitCode)" | Add-Content -Path $using:logFilePath
            }

            # Delete the .exe file after installation
            Remove-Item -Path "C:\Temp\$(Split-Path -Leaf $exeFilePath)" -Force

        } -ArgumentList $destinationPath -SessionOption $sessionOption
    } else {
        Write-Host "File not found on $pc"
        "File not found on $pc" | Add-Content -Path $logFilePath
    }
}