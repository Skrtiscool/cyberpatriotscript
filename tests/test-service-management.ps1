# test-service-management.ps1
# Unit tests for service-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "service-management.ps1") -Raw
    
    $expectedActions = @(
        'List'
        'Start'
        'Stop'
        'Disable'
        'SetAutomatic'
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

function Test-ServiceCmdlets {
    Write-Host "`nTesting PowerShell service cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "service-management.ps1") -Raw
    
    $cmdlets = @(
        'Get-Service'
        'Start-Service'
        'Stop-Service'
        'Set-Service'
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

function Test-ServiceParameters {
    Write-Host "`nTesting service parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "service-management.ps1") -Raw
    
    $params = @(
        'StartupType'
        '-DisplayName'
        'Disabled'
        'Automatic'
    )
    
    $allFound = $true
    foreach ($param in $params) {
        if ($scriptContent -like "*$param*") {
            Write-Host "  ✓ Parameter found: $param" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Parameter missing: $param" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "service-management.ps1") -Raw
    
    $functions = @(
        'List-Services'
        'Start-ManagedService'
        'Stop-ManagedService'
        'Disable-ManagedService'
        'Set-ServiceAutomatic'
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

function Test-NetCommand {
    Write-Host "`nTesting fallback net command..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "service-management.ps1") -Raw
    
    if ($scriptContent -like "*net stop*" -or $scriptContent -like "*net start*") {
        Write-Host "  ✓ Fallback net command present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Fallback net command missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: service-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "service-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-ServiceCmdlets)
$results += (Test-ServiceParameters)
$results += (Test-RequiredFunctions)
$results += (Test-NetCommand)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
