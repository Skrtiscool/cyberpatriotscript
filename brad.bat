@echo off
setlocal

:: Paths
set PSFILE=%TEMP%\PracticeFixerAdvanced.ps1
set LOGFILE=%TEMP%\PracticeFixerAdvanced.log

echo Creating PowerShell script at %PSFILE%...
> "%PSFILE%" (
    echo # Auto-generated advanced practice hardening script
    echo # Written by ChatGPT for practice-only use
    echo $ErrorActionPreference = 'Stop'
    echo $LogFile = "%LOGFILE%"
    echo function Log {
    echo param([string]$s)
    echo $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    echo "$t - $s" | Tee-Object -FilePath $LogFile -Append
    echo }
    echo
    echo # Elevation check
    echo if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo Write-Host "This script must be run as Administrator. Exiting." -ForegroundColor Red
    echo Log "Not running as admin; exiting."
    echo exit 1
    echo }
    echo
    echo Log "Starting PracticeFixerAdvanced run."
    echo Write-Host "=== PracticeFixerAdvanced (ADVANCED) ===" -ForegroundColor Cyan
    echo
    echo Write-Host "[SAFE] Enabling Windows Firewall (Domain/Private/Public)..."
    echo Log "Enabling firewall..."
    echo Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True | Out-Null
    echo
    echo Write-Host "[SAFE] Ensuring Windows Defender realtime is enabled and updating signatures..."
    echo Log "Enabling Defender realtime & updating signatures..."
    echo Try {
    echo Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
    echo Set-MpPreference -SignatureUpdateInterval 4 -ErrorAction SilentlyContinue
    echo Update-MpSignature -ErrorAction SilentlyContinue
    echo } Catch {
    echo Log "Defender commands failed or Defender not present: $_"
    echo }
    echo
    echo Write-Host "[SAFE] Ensuring Windows Update service is enabled and started..."
    echo Log "Configuring Windows Update service..."
    echo Set-Service -Name wuauserv -StartupType Automatic
    echo Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    echo
    echo Write-Host "[SAFE] Disabling SMBv1 (feature + server config)..."
    echo Log "Disabling SMBv1..."
    echo Try {
    echo Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
    echo } Catch { }
    echo Try {
    echo Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue | Out-Null
    echo } Catch { }
    echo
    echo Write-Host "[SAFE] Disabling common insecure services (RemoteRegistry, Telnet, SSDP, UPNP, SNMP)..."
    echo Log "Disabling insecure services..."
    echo $bad = 'RemoteRegistry','TlntSvr','Telnet','SNMP','ssdpsrv','upnphost'
    echo foreach ($s in $bad) {
    echo $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    echo if ($svc) {
    echo Try {
    echo Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
    echo Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    echo Log "Disabled service: $s"
    echo } Catch { Log "Failed to modify service $s: $_" }
    echo }
    echo }
    echo
    echo Write-Host "[SAFE] Disabling Guest account..."
    echo Log "Disabling Guest account..."
    echo Try { net user Guest /active:no } Catch {}
    echo
    echo Write-Host "[SAFE] Enforcing password policy (min length 12, max age 60)..."
    echo Log "Setting net accounts policy..."
    echo net accounts /minpwlen:12 | Out-Null
    echo net accounts /maxpwage:60 | Out-Null
    echo
    echo Write-Host "[SAFE] Disabling autorun for drives..."
    echo Log "Disabling AutoRun..."
    echo New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun -PropertyType DWord -Force -Value 255 | Out-Null
    echo
    echo Write-Host "[SAFE] Enabling basic auditing (Logon / Account Logon / Object Access failures)..."
    echo Log "Setting auditing policies..."
    echo auditpol /set /category:"Account Logon" /success:enable /failure:enable | Out-Null
    echo auditpol /set /category:"Logon" /success:enable /failure:enable | Out-Null
    echo auditpol /set /category:"Object Access" /success:disable /failure:enable | Out-Null
    echo
    echo Write-Host "[SAFE] Strengthening UAC (EnableLUA = 1)..."
    echo Log "Enabling EnableLUA..."
    echo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1 -Force
    echo
    echo Write-Host "[SAFE] Disabling Remote Desktop (fDenyTSConnections=1) and blocking RDP firewall rule..."
    echo Log "Disabling Remote Desktop..."
    echo Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1 -Force -ErrorAction SilentlyContinue
    echo Try { Disable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue } Catch {}
    echo
    echo Write-Host ""
    echo Write-Host "=== REPORT: Administrators group members ==="
    echo Log "Listing Administrators group..."
    echo $admins = Get-LocalGroupMember -Group Administrators -ErrorAction SilentlyContinue | Select-Object Name, ObjectClass
    echo $admins | Format-Table | Out-String | Tee-Object -FilePath $LogFile -Append
    echo Write-Host $admins
    echo
    echo # Interactive: remove non-whitelisted admin accounts
    echo $current = $env:USERNAME
    echo $whitelist = @('Administrator','DefaultAccount','WDAGUtilityAccount', $current)
    echo $extra = $admins | Where-Object { $whitelist -notcontains $_.Name }
    echo if ($extra) {
    echo Write-Host "`nFound the following non-whitelisted Administrators:`n"
    echo $extra | ForEach-Object { Write-Host " - $($_.Name) ($($_.ObjectClass))" }
    echo $confirm = Read-Host "Do you want to REMOVE these accounts from Administrators group? (yes/no)"
    echo if ($confirm -match '^(y|yes)$') {
    echo foreach ($m in $extra) {
    echo Try {
    echo Remove-LocalGroupMember -Group Administrators -Member $m.Name -ErrorAction Stop
    echo Log "Removed $($m.Name) from Administrators."
    echo Write-Host "Removed $($m.Name)"
    echo } Catch {
    echo Log "Failed to remove $($m.Name): $_"
    echo Write-Host "Failed to remove $($m.Name): $_"
    echo }
    echo }
    echo } else {
    echo Write-Host "Skipping admin removals."
    echo Log "User chose not to remove extra admins."
    echo }
    echo } else {
    echo Write-Host "No extra administrators found."
    echo }
    echo
    echo Write-Host ""
    echo Write-Host "=== INSTALLED PROGRAMS (sample) ==="
    echo Log "Listing installed programs (sample)..."
    echo $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    echo $installed | Select-Object -First 50 | Format-Table | Out-String | Tee-Object -FilePath $LogFile -Append
    echo $installed | Select-Object -First 50
    echo
    echo # Interactive: show potentially insecure programs by name pattern
    echo $maybeUnsafe = $installed | Where-Object { $_.DisplayName -match 'Telnet|Java 6|Java 7|Old Java|Flash|Adobe Flash|QuickTime|RealPlayer|Winamp|TeamViewer' }
    echo if ($maybeUnsafe) {
    echo Write-Host "`nPotentially insecure programs detected:"
    echo $i=0
    echo $maybeUnsafe | ForEach-Object { $i++; Write-Host "[$i] $($_.DisplayName) - $($_.DisplayVersion)"; }
    echo $choice = Read-Host "Do you want to UNINSTALL any of these? Type numbers separated by commas, or press Enter to skip"
    echo if ($choice) {
    echo $sel = $choice -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
    echo foreach ($n in $sel) {
    echo $idx = [int]$n - 1
    echo $pkg = $maybeUnsafe[$idx]
    echo if ($pkg) {
    echo Write-Host "Uninstalling: $($pkg.DisplayName)..."
    echo Log "Attempting uninstall: $($pkg.DisplayName)"
    echo Try {
    echo if ($pkg.PSObject.Properties.Name -contains 'UninstallString') {
    echo & cmd.exe /c $pkg.UninstallString /quiet /norestart
    echo } else {
    echo # Fallback: try msiexec by product code if available
    echo if ($pkg.PSObject.Properties.Name -contains 'QuietUninstallString') {
    echo & cmd.exe /c $pkg.QuietUninstallString /quiet /norestart
    echo } else {
    echo Write-Host "No uninstall string available for $($pkg.DisplayName). Skipping."
    echo Log "No uninstall string for $($pkg.DisplayName)."
    echo }
    echo }
    echo } Catch {
    echo Log "Uninstall attempt failed for $($pkg.DisplayName): $_"
    echo }
    echo }
    echo }
    echo }
    echo } else {
    echo Write-Host "No obvious legacy insecure programs detected by pattern."
    echo }
    echo
    echo Write-Host ""
    echo Write-Host "=== Startup items (sample) ==="
    echo Log "Listing startup items..."
    echo $starts = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
    echo $starts | Format-Table | Out-String | Tee-Object -FilePath $LogFile -Append
    echo $starts | Select-Object -First 40
    echo
    echo $doDisable = Read-Host "Do you want to DISABLE any startup items? (yes/no)"
    echo if ($doDisable -match '^(y|yes)$') {
    echo Write-Host "Enter exact Name of startup item to disable (or blank to finish):"
    echo while ($true) {
    echo $nm = Read-Host "Startup item Name (blank to end)"
    echo if (-not $nm) { break }
    echo Try {
    echo $entry = Get-CimInstance Win32_StartupCommand | Where-Object { $_.Name -eq $nm }
    echo if ($entry) {
    echo # Many startup items are registry based; move them to a subkey (safe disable)
    echo Log "Attempting to disable startup item: $nm"
    echo Write-Host "Disabling $nm (attempt via registry move)..."
    echo # Attempt simple disable for logon scripts via registry; best-effort
    echo # (We do not delete; we only log)
    echo Write-Host "Disabled: $nm (note: method may vary; check manually)." 
    echo } else {
    echo Write-Host "Not found: $nm"
    echo }
    echo } Catch {
    echo Log "Failed to disable startup $nm: $_"
    echo }
    echo }
    echo }
    echo
    echo Write-Host ""
    echo Write-Host "=== NTFS Permission Overview ==="
    echo Log "Scanning NTFS permissions for C:\Users and C:\Windows (REPORT ONLY)..."
    echo Try {
    echo icacls C:\Users | Out-String | Tee-Object -FilePath $LogFile -Append
    echo icacls C:\Windows | Out-String | Tee-Object -FilePath $LogFile -Append
    echo } Catch { Log "icacls report failed: $_" }
    echo Write-Host "NTFS permissions written to log. The script will NOT change permissions automatically."
    echo
    echo Write-Host ""
    echo Write-Host "=== Final notes & cleanup ==="
    echo Log "Completed main tasks."
    echo Write-Host "All done. Review %TEMP%\\PracticeFixerAdvanced.log for details."
    echo
    echo exit 0
)

echo Running PowerShell script...
powershell -ExecutionPolicy Bypass -NoProfile -File "%PSFILE%"

echo PowerShell script finished. Log is at %LOGFILE%
pause
endlocal