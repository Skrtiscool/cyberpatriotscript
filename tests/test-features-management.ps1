# test-features-management.ps1
# Unit tests for features-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "features-management.ps1") -Raw
    
    $expectedActions = @(
        'DisableSMBv1'
        'DisableTelnet'
        'DisableFTP'
        'DisableIIS'
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

function Test-DismCommand {
    Write-Host "`nTesting dism command..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "features-management.ps1") -Raw
    
    $dismChecks = @(
        'dism'
        '/Disable-Feature'
        '/FeatureName'
        '/Online'
        '/NoRestart'
    )
    
    $allFound = $true
    foreach ($check in $dismChecks) {
        if ($scriptContent -like "*$check*") {
            Write-Host "  ✓ DISM element found: $check" -ForegroundColor Green
        } else {
            Write-Host "  ✗ DISM element missing: $check" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-FeatureNames {
    Write-Host "`nTesting feature name references..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "features-management.ps1") -Raw
    
    $features = @(
        'SMB1Protocol'
        'TelnetClient'
        'FTP'
        'IIS-WebServer'
    )
    
    $allFound = $true
    foreach ($feature in $features) {
        if ($scriptContent -like "*$feature*") {
            Write-Host "  ✓ Feature referenced: $feature" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Feature missing: $feature" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "features-management.ps1") -Raw
    
    $functions = @(
        'Disable-SMBv1'
        'Disable-Telnet'
        'Disable-FTP'
        'Disable-IIS'
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

function Test-ErrorHandling {
    Write-Host "`nTesting error handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "features-management.ps1") -Raw
    
    if ($scriptContent -like "*ErrorAction*" -or $scriptContent -like "*Try*" -or $scriptContent -like "*Catch*") {
        Write-Host "  ✓ Error handling present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Error handling missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: features-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "features-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-DismCommand)
$results += (Test-FeatureNames)
$results += (Test-RequiredFunctions)
$results += (Test-ErrorHandling)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
