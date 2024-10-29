$computers = Get-Content -Path "C:\SDPU\Remote-hosts\remote_hosts_mcafee.txt"
$logFilePath = "C:\SDPU\Logs\McAfee_Uninstall_Log.csv"

foreach ($computer in $computers) {
    Write-Host "Checking $computer status..." -ForegroundColor Yellow
    
    # Check if remote PC is online
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Write-Host "$computer is online. Uninstalling McAfee..." -ForegroundColor Green
        
        try {
            $hiddenFile = Invoke-Command -ComputerName $computer -ScriptBlock {
                Get-Item -Path "C:\ProgramData\Package Cache\{989ee72e-6de9-4dc6-9d5f-f90469d93c7a}\dxlsetup-ma.exe" -Force
            }
            
            if ($hiddenFile) {
                Invoke-Command -ComputerName $computer -ScriptBlock {
                    Start-Process -FilePath "C:\ProgramData\Package Cache\{989ee72e-6de9-4dc6-9d5f-f90469d93c7a}\dxlsetup-ma.exe" -ArgumentList "/quiet /uninstall"
                }
                Write-Host "McAfee uninstalled successfully on $computer" -ForegroundColor Cyan 
                Add-Content -Path $logFilePath -Value "$computer,McAfee uninstalled successfully"
            } else {
                Write-Host "McAfee uninstaller not found on $computer" -ForegroundColor Grey
                Add-Content -Path $logFilePath -Value "$computer,McAfee uninstaller not found"
            }
        } catch {
            Write-Host "Error uninstalling McAfee on $computer $($Error[0].Message)" -ForegroundColor Red
            Add-Content -Path $logFilePath -Value "$computer,Error uninstalling McAfee: $($Error[0].Message)"
        }
    } else {
        Write-Host "$computer is offline. Skipping..." -ForegroundColor Red
        Add-Content -Path $logFilePath -Value "$computer,Offline"
    }
    
    Start-Sleep -s 5
}

Write-Host "Uninstallation complete. Log report saved to $logFilePath" -ForegroundColor Green