# Apply-RecommendedPasswordPolicy.ps1
# Applies recommended password and account lockout security policies
# Requires: Administrator privileges, secedit.exe, gpupdate

# Desired policy values
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

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$origCfg  = Join-Path $env:TEMP "secpol_orig_$ts.cfg"
$backupCfg = Join-Path $env:TEMP "secpol_backup_$ts.cfg"
$newCfg   = Join-Path $env:TEMP "secpol_new_$ts.cfg"
$checkCfg = Join-Path $env:TEMP "secpol_check_$ts.cfg"
$dbFile   = Join-Path $env:TEMP "secedit_$ts.sdb"

Write-Host "Exporting current local policy to $origCfg ..."
secedit /export /cfg "$origCfg" 2>$null
if (-not (Test-Path $origCfg)) {
    Write-Error "secedit export failed. Ensure this is run elevated and secedit.exe is present."
    exit 1
}

Copy-Item -Path $origCfg -Destination $backupCfg -Force

[byte[]]$b = [IO.File]::ReadAllBytes($origCfg)
$encoding = if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { [Text.UnicodeEncoding]::new() } `
            elseif ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { [Text.UTF8Encoding]::new() } `
            else { [Text.Encoding]::Default }
$text = $encoding.GetString($b)
$text = $text -replace "(`r`n|`n|`r)", "`r`n"
$lines = $text -split "`r`n", [System.StringSplitOptions]::None

function Get-SectionRange([string[]]$lines, [string]$section) {
    $start = -1
    for ($i=0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^\s*\[\s*{0}\s*\]\s*$" -f [regex]::Escape($section)) {
            $start = $i
            break
        }
    }
    if ($start -eq -1) {
        $lines += ""
        $lines += "[$section]"
        $start = $lines.Length - 1
    }
    $end = $lines.Length
    for ($i = $start + 1; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^\s*\[.*\]\s*$") {
            $end = $i
            break
        }
    }
    return @{ Start = $start; End = $end; Lines = $lines }
}

function Set-KeyValueInSection([ref]$linesRef, [string]$section, [string]$key, [string]$value) {
    $lines = $linesRef.Value
    $range = Get-SectionRange $lines $section
    $start = $range.Start
    $end = $range.End
    $found = $false
    for ($i = $start + 1; $i -lt $end; $i++) {
        if ($lines[$i] -match "^\s*{0}\s*=" -f [regex]::Escape($key)) {
            $lines[$i] = "$key = $value"
            $found = $true
            break
        }
    }
    if (-not $found) {
        if ($end -ge $lines.Length) {
            $lines += "$key = $value"
        } else {
            $head = $lines[0..($end-1)]
            $tail = $lines[$end..($lines.Length-1)]
            $lines = $head + ("$key = $value") + $tail
        }
    }
    $linesRef.Value = $lines
}

$sectionName = "System Access"
$linesRef = [ref] $lines

foreach ($k in $policy.Keys) {
    Set-KeyValueInSection -linesRef $linesRef -section $sectionName -key $k -value $policy[$k].ToString()
}

$linesRef.Value | Out-File -FilePath $newCfg -Encoding ASCII -Force

Write-Host "Applying $newCfg with secedit (this may take a moment)..."
$arg = "/configure /db `"$dbFile`" /cfg `"$newCfg`" /areas SECURITYPOLICY"
Start-Process -FilePath secedit -ArgumentList $arg -Wait -NoNewWindow

Write-Host "Running gpupdate /force to refresh policies..."
Start-Process -FilePath gpupdate -ArgumentList "/force" -Wait -NoNewWindow

Write-Host "`n=== net accounts ==="
net accounts

Write-Host "`nExporting effective policy to $checkCfg for verification..."
secedit /export /cfg "$checkCfg" 2>$null
if (Test-Path $checkCfg) {
    Write-Host "`nRelevant lines from exported policy ($checkCfg):"
    Select-String -Path $checkCfg -Pattern "MinimumPasswordLength|PasswordComplexity|PasswordHistorySize|ClearTextPassword|MaximumPasswordAge|MinimumPasswordAge|LockoutBadCount|ResetLockoutCount|LockoutDuration" -SimpleMatch | ForEach-Object { $_.Line.Trim() }
    Write-Host "`nBackup of original export is at: $backupCfg"
    Write-Host "New assigned INF is at: $newCfg"
} else {
    Write-Warning "Could not export verification file $checkCfg. Check permissions."
}
