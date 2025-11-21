# run-all-tests.ps1
# Master test runner for all refactored PowerShell modules

param(
    [switch]$Verbose,
    [switch]$StopOnError
)

$ErrorActionPreference = if ($StopOnError) { "Stop" } else { "Continue" }
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        CYBERPATRIOT REFACTORED MODULE TEST SUITE           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# List of all test files
$testFiles = @(
    "test-apply-policy.ps1",
    "test-verify-policy.ps1",
    "test-audit-management.ps1",
    "test-user-management.ps1",
    "test-group-management.ps1",
    "test-policy-management.ps1",
    "test-service-management.ps1",
    "test-features-management.ps1",
    "test-firewall-management.ps1",
    "test-network-management.ps1",
    "test-filesystem-management.ps1",
    "test-startup-management.ps1",
    "test-updates-management.ps1",
    "test-cleanup-management.ps1"
)

$totalResults = @()
$passedTests = 0
$failedTests = 0

# Run each test
foreach ($testFile in $testFiles) {
    $testPath = Join-Path $scriptPath $testFile
    
    if (Test-Path $testPath) {
        Write-Host "Running: $testFile" -ForegroundColor Cyan
        Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Cyan
        
        try {
            & $testPath -Verbose:$Verbose
            $passedTests++
        } catch {
            Write-Host "✗ Error running $testFile`: $_" -ForegroundColor Red
            $failedTests++
        }
        
        Write-Host ""
    } else {
        Write-Host "✗ Test file not found: $testPath" -ForegroundColor Red
        $failedTests++
    }
}

# Summary report
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                     TEST SUITE SUMMARY                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Test Files Run: $($passedTests + $failedTests)" -ForegroundColor White
Write-Host "Successful: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "✓ All tests completed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠ Some tests encountered errors. Review output above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test Modules Covered:" -ForegroundColor Cyan
Write-Host "  ✓ Core Security (6 modules)" -ForegroundColor Green
Write-Host "    - Apply Policy, Verify Policy, Audit Management" -ForegroundColor White
Write-Host "    - User Management, Group Management, Policy Management" -ForegroundColor White
Write-Host "  ✓ System Administration (8 modules)" -ForegroundColor Green
Write-Host "    - Service Management, Features Management" -ForegroundColor White
Write-Host "    - Firewall Management, Network Management" -ForegroundColor White
Write-Host "    - Filesystem Management, Startup Management" -ForegroundColor White
Write-Host "    - Updates Management, Cleanup Management" -ForegroundColor White
Write-Host ""
