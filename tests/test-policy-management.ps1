# test-policy-management.ps1
# Unit tests for policy-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "policy-management.ps1") -Raw
    
    $expectedActions = @(
        'ApplyRecommended'
        'SetMinLength'
        'EnableComplexity'
        'SetPasswordAge'
        'SetPasswordHistory'
        'DisableReversible'
        'SetLockout'
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

function Test-DefaultParameters {
    Write-Host "`nTesting default parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "policy-management.ps1") -Raw
    
    $defaultParams = @(
        'MinLength = 14'
        'MaxPasswordAgeDays = 60'
        'MinPasswordAgeDays = 1'
        'PasswordHistoryCount = 24'
        'LockoutThreshold = 5'
        'LockoutDurationMinutes = 30'
        'LockoutWindowMinutes = 30'
    )
    
    $allFound = $true
    foreach ($param in $defaultParams) {
        if ($scriptContent -like "*$param*") {
            Write-Host "  ✓ Default parameter: $param" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Default parameter missing: $param" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredCommands {
    Write-Host "`nTesting required commands..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "policy-management.ps1") -Raw
    
    $requiredCmds = @(
        'net accounts'
        'secedit /export'
        'secedit /configure'
    )
    
    $allFound = $true
    foreach ($cmd in $requiredCmds) {
        if ($scriptContent -like "*$cmd*") {
            Write-Host "  ✓ Command found: $cmd" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Command missing: $cmd" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-PolicyValues {
    Write-Host "`nTesting policy value configurations..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "policy-management.ps1") -Raw
    
    $policyValues = @(
        'PasswordComplexity = 1'
        'ClearTextPassword = 0'
    )
    
    $allFound = $true
    foreach ($value in $policyValues) {
        if ($scriptContent -like "*$value*") {
            Write-Host "  ✓ Policy value: $value" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Policy value missing: $value" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: policy-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "policy-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-DefaultParameters)
$results += (Test-RequiredCommands)
$results += (Test-PolicyValues)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
