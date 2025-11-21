# updates-management.ps1
# Functions for managing Windows updates and system reboots

param(
    [ValidateSet("EnableUpdateService", "CheckUpdates", "InstallUpdates", "Reboot")]
    [string]$Action,
    
    [int]$RebootDelaySeconds = 5
)

function Enable-WindowsUpdateService {
    Write-Host "Enabling Windows Update service..." -ForegroundColor Cyan
    
    Set-Service -Name wuauserv -StartupType Automatic
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Host "Windows Update service set to Automatic and started" -ForegroundColor Green
}

function Check-WindowsUpdates {
    Write-Host "Checking for Windows updates..." -ForegroundColor Cyan
    
    wuauclt /detectnow 2>$null
    
    if (Get-Command UsoClient -ErrorAction SilentlyContinue) {
        UsoClient StartScan
        Write-Host "Update scan initiated (UsoClient)" -ForegroundColor Green
    } else {
        Write-Host "Update scan initiated (wuauclt)" -ForegroundColor Green
    }
}

function Install-WindowsUpdates {
    Write-Host "Attempting to install available updates..." -ForegroundColor Cyan
    
    if (Get-Module -ListAvailable PSWindowsUpdate) {
        Write-Host "Installing updates via PSWindowsUpdate module..." -ForegroundColor Cyan
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -Install -AcceptAll -AutoReboot
        Write-Host "Updates installed via PSWindowsUpdate" -ForegroundColor Green
    } else {
        Write-Host "Initiating update installation via wuauclt..." -ForegroundColor Cyan
        wuauclt /detectnow /updatenow 2>$null
        Write-Host "Update installation initiated" -ForegroundColor Yellow
    }
}

function Reboot-System {
    param([int]$DelaySeconds)
    
    Write-Host "System will reboot in $DelaySeconds seconds..." -ForegroundColor Yellow
    shutdown /r /t $DelaySeconds
}

# Execute based on action parameter
switch ($Action) {
    "EnableUpdateService" { Enable-WindowsUpdateService }
    "CheckUpdates" { Check-WindowsUpdates }
    "InstallUpdates" { Install-WindowsUpdates }
    "Reboot" { Reboot-System -DelaySeconds $RebootDelaySeconds }
    default { Write-Error "Invalid action. Use: EnableUpdateService, CheckUpdates, InstallUpdates, Reboot" }
}
