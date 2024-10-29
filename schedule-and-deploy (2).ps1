# Define text file path containing PC information
$pcListPath = "C:\remote_hosts_adobe.txt"

# Read PC list from text file
$pcs = Get-Content -Path $pcListPath

# Define the path to the Deploy-Application.ps1 file
$remoteFilePath = "C:\SVRT\deploy-adobe.ps1"

# Define the timeout period in seconds
$timeoutSeconds = 300 # 10 minutes

# Loop through PCs
foreach ($pc in $pcs) {
    Write-Host "Running on $pc..." -Forgroundcolor Yellow

    If (Test-Connection -ComputerName $pc -Quiet){
        # Check and configure services
        $WINRM = Get-Service -ComputerName $pc winrm
        $WINMGMT = Get-Service -ComputerName $pc Winmgmt
        $RREG = Get-Service -ComputerName $pc RemoteRegistry

        If (($WINRM.Status -ne 'Running') -or ($WINRM.StartType -ne 'Automatic')){
            Set-Service winrm -ComputerName $pc -StartupType Automatic -Status Running -PassThru | Out-Null
            Write-Host $WINRM.DisplayName "is now running and automatic" -ForegroundColor Blue
        }
    
        If (($WINMGMT.Status -ne 'Running') -or ($WINMGMT.StartType -ne 'Automatic')){
            Set-Service Winmgmt -ComputerName $pc -StartupType Automatic -Status Running -PassThru | Out-Null
            Write-Host $WINMGMT.DisplayName "is now running and automatic" -ForegroundColor Cyan    
        }

        If (($RREG.Status -ne 'Running') -or ($RREG.StartType -ne 'Automatic')){
            Set-Service RemoteRegistry -ComputerName $pc -StartupType Automatic -Status Running -PassThru | Out-Null
            Write-Host $RREG.DisplayName "is now running and automatic" -ForegroundColor Magenta 
        }

        # Create the scheduled task
        $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-File C:\SVRT\deploy-adobe.ps1"
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Deploy Application" -User "System" -RunLevel Highest -Force
        Start-ScheduledTask -TaskName "Deploy Application"

        Write-Host "Waiting for 10 minutes..." -Foregroundcolor Yellow
        $timer = [Diagnostics.Stopwatch]::StartNew()
        while ($timer.Elapsed.TotalSeconds -lt $timeoutSeconds) {
            Start-Sleep -Seconds 10
        }
        Unregister-ScheduledTask -TaskName "Deploy Application" -Confirm:$False
        
        # Delete the .exe file after installation
        Remove-Item -Path "\\$pc\C$\SVRT\Acrobat-DCx64Upd-2400320112-Pro.msp" -Force

       # Delete all files inside the C:\SVRT folder
        #Remove-Item -Path "\\$pc\C$\SVRT\*" -Recurse -Force
    }
    Else {
        Write-Host "Something went wrong connecting to $pc! Computer may be offline!" -ForegroundColor Red
        echo "$pc" >> "$HOME\Desktop\MissingPatchInstallation.txt"
    }
}