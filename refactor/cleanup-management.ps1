# cleanup-management.ps1
# Functions for system cleanup and browser management

param(
    [ValidateSet("RemoveTempFiles", "ClearBrowserCaches", "RemoveAppxPackage", "ResetBrowserPolicies")]
    [string]$Action,
    
    [string]$PackageName
)

function Remove-TemporaryFiles {
    Write-Host "Removing temporary files..." -ForegroundColor Cyan
    
    Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "Starting Windows component cleanup..." -ForegroundColor Cyan
    Dism /Online /Cleanup-Image /StartComponentCleanup /Quiet 2>$null
    
    Write-Host "Temporary files and components cleaned up" -ForegroundColor Green
}

function Clear-BrowserCaches {
    Write-Host "Clearing browser caches..." -ForegroundColor Cyan
    
    # Clear Edge cache
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Clear Chrome cache
    Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Reset IE to defaults
    RunDll32.exe InetCpl.cpl, ResetIEtoDefaults 2>$null
    
    Write-Host "Browser caches cleared" -ForegroundColor Green
}

function Remove-AppxPackageByName {
    param([string]$Name)
    
    Write-Host "Removing Appx package: $Name..." -ForegroundColor Cyan
    
    Get-AppxPackage -Name $Name -ErrorAction SilentlyContinue | Remove-AppxPackage
    Get-AppxPackage -AllUsers -Name $Name -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers
    
    Write-Host "Requested removal for package: $Name" -ForegroundColor Green
}

function Reset-BrowserPolicies {
    Write-Host "Resetting browser policies and settings..." -ForegroundColor Cyan
    
    # Remove Edge policies
    Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -Force -ErrorAction SilentlyContinue
    
    # Reset IE to defaults
    RunDll32.exe InetCpl.cpl, ResetIEtoDefaults 2>$null
    
    Write-Host "Browser policies cleared and IE reset" -ForegroundColor Green
}

# Execute based on action parameter
switch ($Action) {
    "RemoveTempFiles" { Remove-TemporaryFiles }
    "ClearBrowserCaches" { Clear-BrowserCaches }
    "RemoveAppxPackage" { Remove-AppxPackageByName -Name $PackageName }
    "ResetBrowserPolicies" { Reset-BrowserPolicies }
    default { Write-Error "Invalid action. Use: RemoveTempFiles, ClearBrowserCaches, RemoveAppxPackage, ResetBrowserPolicies" }
}
