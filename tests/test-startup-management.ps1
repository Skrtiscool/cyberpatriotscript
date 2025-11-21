# test-startup-management.ps1
# Unit tests for startup-management.ps1

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
    
    $scriptContent = Get-Content (Join-Path $refactorPath "startup-management.ps1") -Raw
    
    $expectedActions = @(
        'ListTasks'
        'DisableTask'
        'DeleteTask'
        'ClearStartupFolders'
        'ListRunKeys'
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

function Test-ScheduledTaskCmdlets {
    Write-Host "`nTesting scheduled task cmdlets..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "startup-management.ps1") -Raw
    
    $cmdlets = @(
        'Get-ScheduledTask'
        'Disable-ScheduledTask'
        'Unregister-ScheduledTask'
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

function Test-RegistryPaths {
    Write-Host "`nTesting registry path references..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "startup-management.ps1") -Raw
    
    $paths = @(
        'HKCU.*Run'
        'HKLM.*Run'
        'Startup'
    )
    
    $allFound = $true
    foreach ($path in $paths) {
        if ($scriptContent -like "*$path*") {
            Write-Host "  ✓ Registry path referenced: $path" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Registry path missing: $path" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    return $allFound
}

function Test-RequiredFunctions {
    Write-Host "`nTesting function definitions..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "startup-management.ps1") -Raw
    
    $functions = @(
        'List-ScheduledTasks'
        'Disable-ScheduledStartupTask'
        'Delete-ScheduledStartupTask'
        'Clear-StartupFolders'
        'List-RunRegistryKeys'
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

function Test-StartupFolders {
    Write-Host "`nTesting startup folder references..." -ForegroundColor Cyan
    
    $scriptContent = Get-Content (Join-Path $refactorPath "startup-management.ps1") -Raw
    
    if ($scriptContent -like "*AppData*Startup*" -or $scriptContent -like "*ProgramData*Startup*" -or $scriptContent -like "*All Users*") {
        Write-Host "  ✓ Startup folder paths present" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Startup folder paths missing" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing: startup-management.ps1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$results = @()
$results += (Test-FileExists (Join-Path $refactorPath "startup-management.ps1"))
$results += (Test-ValidActions)
$results += (Test-ScheduledTaskCmdlets)
$results += (Test-RegistryPaths)
$results += (Test-RequiredFunctions)
$results += (Test-StartupFolders)

Write-Host "`n======================================" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_ -eq $true }).Count
$total = $results.Count
Write-Host "Results: $passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan
