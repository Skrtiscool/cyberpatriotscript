# service-management.ps1
# Functions for managing Windows services

param(
    [ValidateSet("List", "Start", "Stop", "Disable", "SetAutomatic")]
    [string]$Action,
    
    [string]$ServiceName
)

function Get-ServicesList {
    Get-Service | Sort-Object Status, Name | Format-Table Status, Name, DisplayName -AutoSize
}

function Start-ServiceByName {
    param([string]$Name)
    
    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
        Start-Service -Name $Name
        Write-Host "Started service: $Name" -ForegroundColor Green
    } else {
        Write-Host "Service not found: $Name" -ForegroundColor Yellow
    }
}

function Stop-ServiceByName {
    param([string]$Name)
    
    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Name -Force
        Write-Host "Stopped service: $Name" -ForegroundColor Green
    } else {
        Write-Host "Service not found: $Name" -ForegroundColor Yellow
    }
}

function Disable-ServiceByName {
    param([string]$Name)
    
    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
        Set-Service -Name $Name -StartupType Disabled
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        Write-Host "Disabled service: $Name" -ForegroundColor Green
    } else {
        Write-Host "Service not found: $Name" -ForegroundColor Yellow
    }
}

function Set-ServiceAutomatic {
    param([string]$Name)
    
    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
        Set-Service -Name $Name -StartupType Automatic
        Write-Host "Set service to Automatic: $Name" -ForegroundColor Green
    } else {
        Write-Host "Service not found: $Name" -ForegroundColor Yellow
    }
}

# Execute based on action parameter
switch ($Action) {
    "List" { Get-ServicesList }
    "Start" { Start-ServiceByName -Name $ServiceName }
    "Stop" { Stop-ServiceByName -Name $ServiceName }
    "Disable" { Disable-ServiceByName -Name $ServiceName }
    "SetAutomatic" { Set-ServiceAutomatic -Name $ServiceName }
    default { Write-Error "Invalid action. Use: List, Start, Stop, Disable, SetAutomatic" }
}
