# test-network-management.ps1
# Unit tests for network-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "network-management.ps1") -Raw
    
    $expectedActions = @(
        'ListAdapters'
        'SetStaticIP'
        'SetDNS'
        'EnableDHCP'
        'DisableIPv6'
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

function Test-NetworkCmdlets {
    Write-Host "`nTesting network cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "network-management.ps1") -Raw
    
    $cmdlets = @(
        'Get-NetAdapter'
        'New-NetIPAddress'
        'Set-DnsClientServerAddress'
        'Set-NetIPInterface'
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

function Test-NetworkParameters {
    Write-Host "`nTesting network configuration parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "network-management.ps1") -Raw
    
    $params = @(
        'InterfaceAlias'
        'IPAddress'
        'PrefixLength'
        'DefaultGateway'
        'ServerAddresses'
        'AddressFamily'
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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "network-management.ps1") -Raw
    
    $functions = @(
        'List-NetworkAdapters'
        'Set-StaticIPAddress'
        'Configure-DNS'
        'Enable-DHCP'
        'Disable-IPv6'
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

function Test-IPv6Disabling {
    Write-Host "`nTesting IPv6 disabling mechanism..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "network-management.ps1") -Raw
    
    if ($scriptContent -like "*IPv6*" -and ($scriptContent -like "*Disabled*" -or $scriptContent -like "*-1*")) {
        Write-Host "  ✓ IPv6 disabling logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ IPv6 disabling logic missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: network-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "network-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-NetworkCmdlets)
$results += (Test-NetworkParameters)
$results += (Test-RequiredFunctions)
$results += (Test-IPv6Disabling)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
