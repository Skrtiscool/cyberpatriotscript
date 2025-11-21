# test-user-management.ps1
# Unit tests for user-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "user-management.ps1") -Raw
    
    $expectedActions = @(
        'List'
        'Create'
        'Delete'
        'Disable'
        'SetPassword'
        'ForcePasswordChange'
        'DisableBuiltIn'
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

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "user-management.ps1") -Raw
    
    $requiredFunctions = @(
        'Get-LocalUsersList'
        'New-LocalUserAccount'
        'Remove-LocalUserAccount'
        'Disable-LocalUserAccount'
        'Set-LocalUserPassword'
        'Force-PasswordChangeAtLogon'
        'Disable-BuiltInAccounts'
    )
    
    $allFound = $true
    foreach ($func in $requiredFunctions) {
        if ($scriptContent -like "*function $func*") {
            Write-Host "  ✓ Function defined: $func" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Function missing: $func" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-ParamValidation {
    Write-Host "`nTesting parameter validation..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "user-management.ps1") -Raw
    
    if ($scriptContent -like "*ValidateSet*") {
        Write-Host "  ✓ ValidateSet parameter validation found" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ ValidateSet parameter validation missing" -ForegroundColor Red
        return $false
    }
}

function Test-ErrorHandling {
    Write-Host "`nTesting error handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "user-management.ps1") -Raw
    
    $errorHandling = @(
        'ErrorAction'
        'try'
        'catch'
    )
    
    $found = 0
    foreach ($handler in $errorHandling) {
        if ($scriptContent -like "*$handler*") {
            Write-Host "  ✓ Error handling found: $handler" -ForegroundColor Green
            $found++
        }
    }
    
    return ($found -gt 0)
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: user-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "user-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-RequiredFunctions)
$results += (Test-ParamValidation)
$results += (Test-ErrorHandling)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
