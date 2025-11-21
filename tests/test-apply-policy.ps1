# test-apply-policy.ps1
# Unit tests for apply-policy.ps1

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

function Test-ValidPolicyHashtable {
    Write-Host "`nTesting policy hashtable..." -ForegroundColor Cyan
    
    $expectedKeys = @(
        'MinimumPasswordLength'
        'PasswordComplexity'
        'PasswordHistorySize'
        'ClearTextPassword'
        'MaximumPasswordAge'
        'MinimumPasswordAge'
        'LockoutBadCount'
        'ResetLockoutCount'
        'LockoutDuration'
    )
    
    $policy = @{
        MinimumPasswordLength = 14
        PasswordComplexity    = 1
        PasswordHistorySize   = 24
        ClearTextPassword     = 0
        MaximumPasswordAge    = 60
        MinimumPasswordAge    = 1
        LockoutBadCount       = 5
        ResetLockoutCount     = 30
        LockoutDuration       = 30
    }
    
    $allFound = $true
    foreach ($key in $expectedKeys) {
        if ($policy.ContainsKey($key)) {
            Write-Host "  ✓ Key found: $key = $($policy[$key])" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Key missing: $key" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-ScriptParametersValid {
    Write-Host "`nTesting script parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "apply-policy.ps1") -Raw
    
    $requiredElements = @(
        'secedit /export'
        'Get-SectionRange'
        'Set-KeyValueInSection'
        'secedit /configure'
        'gpupdate /force'
    )
    
    $allFound = $true
    foreach ($element in $requiredElements) {
        if ($scriptContent -like "*$element*") {
            Write-Host "  ✓ Found: $element" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Missing: $element" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-EncodingDetection {
    Write-Host "`nTesting encoding detection logic..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "apply-policy.ps1") -Raw
    
    $encodingChecks = @(
        'UTF8Encoding'
        'UnicodeEncoding'
        'Text.Encoding'
    )
    
    $allFound = $true
    foreach ($check in $encodingChecks) {
        if ($scriptContent -like "*$check*") {
            Write-Host "  ✓ Found: $check" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Missing: $check" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: apply-policy.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "apply-policy.ps1"))
$results += (Test-ValidPolicyHashtable)
$results += (Test-ScriptParametersValid)
$results += (Test-EncodingDetection)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
