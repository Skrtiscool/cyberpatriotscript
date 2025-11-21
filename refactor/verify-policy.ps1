# verify-policy.ps1
# Verifies current password and lockout policy settings
# Displays relevant security policy entries from secedit export

$policyPattern = "MinimumPasswordLength|PasswordComplexity|PasswordHistorySize|ClearTextPassword|MaximumPasswordAge|MinimumPasswordAge|LockoutBadCount|ResetLockoutCount|LockoutDuration"
$cfgPath = "$env:windir\Temp\secpol_verify.cfg"

Write-Host "=== net accounts ===" -ForegroundColor Cyan
net accounts

Write-Host "`nExporting current policy to $cfgPath ..."
secedit /export /cfg $cfgPath 2>$null

if (Test-Path $cfgPath) {
    Write-Host "`nRelevant lines from exported policy ($cfgPath):" -ForegroundColor Cyan
    Select-String -Path $cfgPath -Pattern $policyPattern -SimpleMatch | ForEach-Object { 
        Write-Host $_.Line.Trim() 
    }
} else {
    Write-Error "Failed to export policy for verification. Ensure elevated privileges."
}
