# test-audit-management.ps1
# Unit tests for audit-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "audit-management.ps1") -Raw
    
    $expectedActions = @(
        'EnableCommon'
        'ShowStatus'
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

function Test-AuditCategories {
    Write-Host "`nTesting audit categories..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "audit-management.ps1") -Raw
    
    $categories = @(
        'Logon'
        'Account Logon'
        'User Account Management'
        'Privilege Use'
        'Process Creation'
        'System'
    )
    
    $allFound = $true
    foreach ($category in $categories) {
        if ($scriptContent -like "*$category*") {
            Write-Host "  ✓ Category found: $category" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Category missing: $category" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-AuditpolCommand {
    Write-Host "`nTesting auditpol command..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "audit-management.ps1") -Raw
    
    $auditpolChecks = @(
        'auditpol /set'
        '/subcategory'
        '/success:enable'
        '/failure:enable'
    )
    
    $allFound = $true
    foreach ($check in $auditpolChecks) {
        if ($scriptContent -like "*$check*") {
            Write-Host "  ✓ Found: $check" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Missing: $check" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "audit-management.ps1") -Raw
    
    $functions = @(
        'Enable-CommonAuditCategories'
        'Show-AuditStatus'
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

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: audit-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "audit-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-AuditCategories)
$results += (Test-AuditpolCommand)
$results += (Test-RequiredFunctions)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
