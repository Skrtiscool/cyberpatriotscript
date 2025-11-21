Write-Host "Applying recommended password and lockout policy now..."

# Recommended defaults
$min = 14; $max = 60; $minAge = 1; $history = 24; $lt = 5; $ld = 30; $lw = 30

# Apply account policies
cmd /c "net accounts /minpwlen:$min"
cmd /c "net accounts /maxpwage:$max"
cmd /c "net accounts /minpwage:$minAge"
cmd /c "net accounts /lockoutthreshold:$lt"
cmd /c "net accounts /lockoutduration:$ld"
cmd /c "net accounts /lockoutwindow:$lw"

# Local policy edits via secedit
$cfg = "$env:windir\Temp\secpol_toolbox.cfg"
secedit /export /cfg $cfg | Out-Null
$c = Get-Content $cfg
$c = $c -replace 'PasswordComplexity = \d+', 'PasswordComplexity = 1'
$c = $c -replace 'PasswordHistorySize = \d+', "PasswordHistorySize = $history"
$c = $c -replace 'ClearTextPassword = \d+', 'ClearTextPassword = 0'
$c | Set-Content $cfg
secedit /configure /db secedit.sdb /cfg $cfg /areas SECURITYPOLICY | Out-Null

Write-Host 'Applied recommended password & lockout settings'
Read-Host "Press Enter to continue"
# Return to main (replace with appropriate flow control)