<#===================================================================================================================================================================================================================================================================================================================================================
.SYNOPSIS
	This script performs the installation or uninstallation of Adobe Acrobat.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of Adobe Acrobat.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-AdobeAcrobat.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-AdobeAcrobat.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-AdobeAcrobat.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
#>#================================================================================================================

[CmdletBinding()]
# Define parameters===============================
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('Install','Uninstall')]
    [string]$DeploymentType = 'Install',
    [Parameter(Mandatory=$false)]
    [ValidateSet('Interactive','Silent','NonInteractive')]
    [string]$DeployMode = 'Interactive',
    [Parameter(Mandatory=$false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory=$false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory=$false)]
    [switch]$DisableLogging = $false
)

# Define log file path============================
$logFilePath = "C:\SDPU\Deploy-Adobe.log"

# Create log file if it doesn't exist
if (!(Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File
}

# Define application variables====================
$appVendor = 'Google LLC'
$appName = 'Google Chrome'
$appVersion = '130.0.6723.69/70'
$appArch = 'x64'
$appLang = 'EN'
$appRevision = '130.0.6723.70'

# Define installation paths====================
$installPath = 'C:\SDPU\ChromeSetup.exe'
$uninstallPath = 'C:\Program Files\Google\Chrome\Application'

# Define functions=============================
function Install-GoogleChrome {
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running Install-GoogleChrome function."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/update $installPath /quiet /norestart" -Wait
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Completed Install-GoogleChrome function."
}

function Uninstall-GoogleChrome {
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running Uninstall-GoogleChrome function."
    $uninstaller = Get-ChildItem $uninstallPath\uninstall.exe | Where-Object { $_.name -like "uninstall.exe" }
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Uninstaller is $uninstaller."
    Start-Process -FilePath "$uninstallPath\$uninstaller" -ArgumentList "/S" -Wait
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Completed Uninstall-GoogleChrome function."
}

#================
# Main script
#================

try {
    if ($DeploymentType -eq 'Install') {
        Install-GoogleChrome
    } elseif ($DeploymentType -eq 'Uninstall') {
        Uninstall-GoogleChrome
    }

    # Wait for 10 seconds before deleting installation files
    Write-Host "Waiting 10 seconds before cleaning up..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    
    # Return success
    Write-Host "Installation/Uninstallation successful!" -ForegroundColor Green
    $installationSuccessful = $true

    # Delete installation files
    #Write-Host "Deleting installation files..." -ForegroundColor Magenta
    #Remove-Item -Path "C:\SDPU\*" -Recurse -Force
    #Write-Host "Cleanup complete!" -ForegroundColor Green

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: $($_.Exception.Message)"
    $installationSuccessful = $false
    #Exit 69000
}

# Return result
return $installationSuccessful

#====== Main script ENDS ==========================================================================================
#      ==================

