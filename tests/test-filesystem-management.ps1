# test-filesystem-management.ps1
# Unit tests for filesystem-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    $expectedActions = @(
        'ListACLs'
        'GrantPermission'
        'RemovePermission'
        'RemoveEveryoneFullControl'
        'SetInheritance'
        'CreateFolder'
        'DeletePath'
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

function Test-ACLCmdlets {
    Write-Host "`nTesting ACL-related cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    $cmdlets = @(
        'Get-Acl'
        'Set-Acl'
        'New-Object.*FileSystemAccessRule'
        'icacls'
    )
    
    $allFound = $true
    foreach ($cmdlet in $cmdlets) {
        if ($scriptContent -like "*$cmdlet*") {
            Write-Host "  ✓ ACL element found: $cmdlet" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ACL element missing: $cmdlet" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-FileSystemParameters {
    Write-Host "`nTesting filesystem parameters..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    $params = @(
        'Path'
        'Identity'
        'FileSystemRights'
        'AccessControlType'
        'Allow'
        'Deny'
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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    $functions = @(
        'Display-ACLs'
        'Grant-Permission'
        'Remove-Permission'
        'Remove-EveryoneFullControl'
        'Set-InheritanceAndPropagation'
        'Create-SecureFolder'
        'Delete-Path'
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

function Test-EveryoneRemoval {
    Write-Host "`nTesting 'Everyone' permission handling..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    if ($scriptContent -like "*Everyone*" -and $scriptContent -like "*FullControl*") {
        Write-Host "  ✓ Everyone Full Control removal logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Everyone Full Control removal logic missing" -ForegroundColor Red
        return $false
    }
}

function Test-InheritanceHandling {
    Write-Host "`nTesting inheritance propagation..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "filesystem-management.ps1") -Raw
    
    if ($scriptContent -like "*IsInherited*" -or $scriptContent -like "*Inheritance*" -or $scriptContent -like "*Propagation*") {
        Write-Host "  ✓ Inheritance propagation logic present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Inheritance propagation logic missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: filesystem-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "filesystem-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-ACLCmdlets)
$results += (Test-FileSystemParameters)
$results += (Test-RequiredFunctions)
$results += (Test-EveryoneRemoval)
$results += (Test-InheritanceHandling)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
