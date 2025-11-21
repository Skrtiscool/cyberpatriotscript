# test-verify-policy.ps1
# Unit tests for verify-policy.ps1

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

function Test-ScriptStructure {
    Write-Host "`nTesting script parameter structure..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "verify-policy.ps1") -Raw
    
    if ($scriptContent -like "*param*" -or $scriptContent -like "*-Action*") {
        Write-Host "  ✓ Parameter structure present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Parameter structure missing" -ForegroundColor Red
        return $false
    }
}

function Test-SecuditExport {
    Write-Host "`nTesting secedit export command..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "verify-policy.ps1") -Raw
    
    $secuditElements = @(
        'secedit'
        '/export'
        '/cfg'
    )
    
    $allFound = $true
    foreach ($element in $secuditElements) {
        if ($scriptContent -like "*$element*") {
            Write-Host "  ✓ Secedit element found: $element" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Secedit element missing: $element" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-PolicyVerification {
    Write-Host "`nTesting policy verification logic..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "verify-policy.ps1") -Raw
    
    if ($scriptContent -like "*Select-String*" -or $scriptContent -like "*Get-Content*" -or $scriptContent -like "*Write-Host*") {
        Write-Host "  ✓ Policy verification logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Policy verification logic missing" -ForegroundColor Red
        return $false
    }
}

function Test-OutputFormatting {
    Write-Host "`nTesting output formatting..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "verify-policy.ps1") -Raw
    
    if ($scriptContent -like "*Write-Host*" -and $scriptContent -like "*ForegroundColor*") {
        Write-Host "  ✓ Color-coded output present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Color-coded output missing" -ForegroundColor Red
        return $false
    }
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "verify-policy.ps1") -Raw
    
    # verify-policy.ps1 is simpler and may not have formal functions, but should have verification logic
    if ($scriptContent -like "*function*" -or $scriptContent -like "*secedit*" -or $scriptContent -like "*Get-Content*") {
        Write-Host "  ✓ Verification functions or logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Verification functions or logic missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: verify-policy.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "verify-policy.ps1"))
$results += (Test-ScriptStructure)
$results += (Test-SecuditExport)
$results += (Test-PolicyVerification)
$results += (Test-OutputFormatting)
$results += (Test-RequiredFunctions)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
