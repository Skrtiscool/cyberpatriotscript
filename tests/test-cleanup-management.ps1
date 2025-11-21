# test-cleanup-management.ps1
# Unit tests for cleanup-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    $expectedActions = @(
        'RemoveTempFiles'
        'ClearBrowserCaches'
        'RemoveAppxPackage'
        'ResetBrowserPolicies'
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

function Test-TempFileHandling {
    Write-Host "`nTesting temporary file handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    $tempElements = @(
        '$env:TEMP'
        '$env:WINDIR'
        'Temp'
        'Remove-Item'
    )
    
    $allFound = $true
    foreach ($element in $tempElements) {
        if ($scriptContent -like "*$element*") {
            Write-Host "  ✓ Temp element found: $element" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Temp element missing: $element" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-BrowserCacheReferences {
    Write-Host "`nTesting browser cache references..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    $browsers = @(
        'Chrome'
        'Edge'
        'Firefox'
        'Internet Explorer'
        'LocalAppData'
    )
    
    $allFound = $true
    foreach ($browser in $browsers) {
        if ($scriptContent -like "*$browser*") {
            Write-Host "  ✓ Browser reference found: $browser" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Browser reference missing: $browser" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    $functions = @(
        'Remove-TempFiles'
        'Clear-BrowserCaches'
        'Remove-AppxPackage'
        'Reset-BrowserPolicies'
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

function Test-AppxHandling {
    Write-Host "`nTesting AppX package handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    if ($scriptContent -like "*Get-AppxPackage*" -or $scriptContent -like "*Remove-AppxPackage*") {
        Write-Host "  ✓ AppX package logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ AppX package logic missing" -ForegroundColor Red
        return $false
    }
}

function Test-RegistryPolicyReset {
    Write-Host "`nTesting registry policy reset logic..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "cleanup-management.ps1") -Raw
    
    if ($scriptContent -like "*Remove-Item*HKCU*" -or $scriptContent -like "*registry*") {
        Write-Host "  ✓ Registry policy reset logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Registry policy reset logic missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: cleanup-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "cleanup-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-TempFileHandling)
$results += (Test-BrowserCacheReferences)
$results += (Test-RequiredFunctions)
$results += (Test-AppxHandling)
$results += (Test-RegistryPolicyReset)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
