# policy-management.ps1
# Functions for password and account lockout policy management

param(
    [ValidateSet("ApplyRecommended", "SetMinLength", "EnableComplexity", "SetPasswordAge", "SetPasswordHistory", "DisableReversible", "SetLockout")]
    [string]$Action,
    
    [int]$MinLength = 14,
    [int]$MaxPasswordAgeDays = 60,
    [int]$MinPasswordAgeDays = 1,
    [int]$PasswordHistoryCount = 24,
    [int]$LockoutThreshold = 5,
    [int]$LockoutDurationMinutes = 30,
    [int]$LockoutWindowMinutes = 30
)

$cfgPath = "$env:windir\Temp\secpol.cfg"

function Apply-RecommendedPolicy {
    Write-Host "Applying recommended password and lockout policies..." -ForegroundColor Cyan
    
    # Using net accounts for basic settings
    net accounts /minpwlen:14
    net accounts /maxpwage:60
    net accounts /minpwage:1
    net accounts /lockoutthreshold:5
    net accounts /lockoutduration:30
    net accounts /lockoutwindow:30
    
    # Using secedit for advanced settings
    secedit /export /cfg $cfgPath 2>$null
    
    if (Test-Path $cfgPath) {
        $content = Get-Content $cfgPath
        $content = $content -replace 'PasswordComplexity = \d+', 'PasswordComplexity = 1'
        $content = $content -replace 'PasswordHistorySize = \d+', 'PasswordHistorySize = 24'
        $content = $content -replace 'ClearTextPassword = \d+', 'ClearTextPassword = 0'
        $content | Set-Content $cfgPath
        
        secedit /configure /db secedit.sdb /cfg $cfgPath /areas SECURITYPOLICY 2>$null
        Write-Host "Recommended policies applied successfully" -ForegroundColor Green
    } else {
        Write-Error "Failed to export security policy"
    }
}

function Set-MinimumPasswordLength {
    param([int]$Length)
    
    Write-Host "Setting minimum password length to $Length characters..." -ForegroundColor Cyan
    net accounts /minpwlen:$Length
    Write-Host "Minimum password length set to $Length" -ForegroundColor Green
}

function Enable-PasswordComplexity {
    Write-Host "Enabling password complexity requirement..." -ForegroundColor Cyan
    
    secedit /export /cfg $cfgPath 2>$null
    if (Test-Path $cfgPath) {
        $content = Get-Content $cfgPath
        $content = $content -replace 'PasswordComplexity = \d+', 'PasswordComplexity = 1'
        $content | Set-Content $cfgPath
        
        secedit /configure /db secedit.sdb /cfg $cfgPath /areas SECURITYPOLICY 2>$null
        Write-Host "Password complexity enabled" -ForegroundColor Green
    } else {
        Write-Error "Failed to export security policy"
    }
}

function Set-PasswordAge {
    param(
        [int]$MaxDays,
        [int]$MinDays
    )
    
    Write-Host "Setting password age (Max: $MaxDays days, Min: $MinDays days)..." -ForegroundColor Cyan
    net accounts /maxpwage:$MaxDays
    net accounts /minpwage:$MinDays
    Write-Host "Password age configured" -ForegroundColor Green
}

function Set-PasswordHistory {
    param([int]$HistoryCount)
    
    Write-Host "Setting password history to $HistoryCount previous passwords..." -ForegroundColor Cyan
    
    secedit /export /cfg $cfgPath 2>$null
    if (Test-Path $cfgPath) {
        $content = Get-Content $cfgPath
        $content = $content -replace 'PasswordHistorySize = \d+', "PasswordHistorySize = $HistoryCount"
        $content | Set-Content $cfgPath
        
        secedit /configure /db secedit.sdb /cfg $cfgPath /areas SECURITYPOLICY 2>$null
        Write-Host "Password history set to $HistoryCount" -ForegroundColor Green
    } else {
        Write-Error "Failed to export security policy"
    }
}

function Disable-ReversibleEncryption {
    Write-Host "Disabling reversible password encryption..." -ForegroundColor Cyan
    
    secedit /export /cfg $cfgPath 2>$null
    if (Test-Path $cfgPath) {
        $content = Get-Content $cfgPath
        $content = $content -replace 'ClearTextPassword = \d+', 'ClearTextPassword = 0'
        $content | Set-Content $cfgPath
        
        secedit /configure /db secedit.sdb /cfg $cfgPath /areas SECURITYPOLICY 2>$null
        Write-Host "Reversible encryption disabled" -ForegroundColor Green
    } else {
        Write-Error "Failed to export security policy"
    }
}

function Set-AccountLockout {
    param(
        [int]$Threshold,
        [int]$DurationMinutes,
        [int]$WindowMinutes
    )
    
    Write-Host "Setting account lockout (Threshold: $Threshold, Duration: $DurationMinutes min, Window: $WindowMinutes min)..." -ForegroundColor Cyan
    net accounts /lockoutthreshold:$Threshold
    net accounts /lockoutduration:$DurationMinutes
    net accounts /lockoutwindow:$WindowMinutes
    Write-Host "Account lockout configured" -ForegroundColor Green
}

# Execute based on action parameter
switch ($Action) {
    "ApplyRecommended" { Apply-RecommendedPolicy }
    "SetMinLength" { Set-MinimumPasswordLength -Length $MinLength }
    "EnableComplexity" { Enable-PasswordComplexity }
    "SetPasswordAge" { Set-PasswordAge -MaxDays $MaxPasswordAgeDays -MinDays $MinPasswordAgeDays }
    "SetPasswordHistory" { Set-PasswordHistory -HistoryCount $PasswordHistoryCount }
    "DisableReversible" { Disable-ReversibleEncryption }
    "SetLockout" { Set-AccountLockout -Threshold $LockoutThreshold -DurationMinutes $LockoutDurationMinutes -WindowMinutes $LockoutWindowMinutes }
    default { Write-Error "Invalid action specified" }
}
