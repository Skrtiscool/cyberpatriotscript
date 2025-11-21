# test-firewall-management.ps1
# Unit tests for firewall-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "firewall-management.ps1") -Raw
    
    $expectedActions = @(
        'Enable'
        'ListInbound'
        'CreateRule'
        'DeleteRule'
        'BlockAll'
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

function Test-FirewallCmdlets {
    Write-Host "`nTesting firewall cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "firewall-management.ps1") -Raw
    
    $cmdlets = @(
        'Set-NetFirewallProfile'
        'Get-NetFirewallRule'
        'New-NetFirewallRule'
        'Remove-NetFirewallRule'
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

function Test-FirewallProfiles {
    Write-Host "`nTesting firewall profile parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "firewall-management.ps1") -Raw
    
    $profiles = @(
        'Domain'
        'Private'
        'Public'
        'Enabled'
        'DefaultInboundAction'
    )
    
    $allFound = $true
    foreach ($profile in $profiles) {
        if ($scriptContent -like "*$profile*") {
            Write-Host "  ✓ Profile element found: $profile" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Profile element missing: $profile" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "firewall-management.ps1") -Raw
    
    $functions = @(
        'Enable-Firewall'
        'List-FirewallInbound'
        'Create-FirewallRule'
        'Delete-FirewallRule'
        'Block-AllInbound'
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

function Test-RuleParameters {
    Write-Host "`nTesting rule parameter handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "firewall-management.ps1") -Raw
    
    $params = @(
        'DisplayName'
        'Direction'
        'Protocol'
        'Action'
        'LocalPort'
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

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: firewall-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "firewall-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-FirewallCmdlets)
$results += (Test-FirewallProfiles)
$results += (Test-RequiredFunctions)
$results += (Test-RuleParameters)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
