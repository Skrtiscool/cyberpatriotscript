# test-updates-management.ps1
# Unit tests for updates-management.ps1

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$refactorPath = Join-Path $scriptPath "..\refactor"

function Test-FileExists {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Host "✓ File exists: $Path" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ File not found: $Path" -ForegroundColor Red
        return $false
    }
}

function Test-ValidActions {
    Write-Host "`nTesting valid actions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "updates-management.ps1") -Raw
    
    $expectedActions = @(
        'EnableUpdateService'
        'CheckUpdates'
        'InstallUpdates'
        'Reboot'
    )
    
    $allFound = $true
    foreach ($action in $expectedActions) {
        if ($scriptContent -like "*`"$action`"*" -or $scriptContent -like "*'$action'*") {
            Write-Host "  ✓ Action defined: $action" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Action missing: $action" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-WindowsUpdateCmdlets {
    Write-Host "`nTesting Windows Update cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "updates-management.ps1") -Raw
    
    $cmdlets = @(
        'Get-Service'
        'Start-Service'
    )
    
    $allFound = $true
    foreach ($cmdlet in $cmdlets) {
        if ($scriptContent -like "*$cmdlet*") {
            Write-Host "  ✓ Cmdlet used: $cmdlet" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Cmdlet missing: $cmdlet" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-UpdateServiceReferences {
    Write-Host "`nTesting Windows Update service references..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "updates-management.ps1") -Raw
    
    $services = @(
        'wuauserv'
        'Windows Update'
    )
    
    $allFound = $true
    foreach ($service in $services) {
        if ($scriptContent -like "*$service*") {
            Write-Host "  ✓ Service referenced: $service" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Service missing: $service" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "updates-management.ps1") -Raw
    
    $functions = @(
        'Enable-WindowsUpdateService'
        'Check-WindowsUpdates'
        'Install-WindowsUpdates'
        'Reboot-System'
    )
    
    $allFound = $true
    foreach ($func in $functions) {
        if ($scriptContent -like "*function $func*") {
            Write-Host "  ✓ Function defined: $func" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Function missing: $func" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RebootLogic {
    Write-Host "`nTesting system reboot logic..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "updates-management.ps1") -Raw
    
    if ($scriptContent -like "*Restart-Computer*" -or $scriptContent -like "*shutdown*" -or $scriptContent -like "*Reboot*") {
        Write-Host "  ✓ Reboot logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Reboot logic missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: updates-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "updates-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-WindowsUpdateCmdlets)
$results += (Test-UpdateServiceReferences)
$results += (Test-RequiredFunctions)
$results += (Test-RebootLogic)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
