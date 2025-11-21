@echo off
rem -----------------------------------------------------------------------------
rem CP Audit Toolbox - Interactive checklist runner (read-only checks)
rem Generated: %DATE% %TIME%
rem Path: C:\Users\skrti\Downloads\toolbox.bat
rem Usage: Run as Administrator for full results. Choose a numbered action from the menu.
rem -----------------------------------------------------------------------------

setlocal enabledelayedexpansion

:: Get safe timestamp from PowerShell
for /f "delims=" %%T in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"') do set TS=%%T
set HOST=%COMPUTERNAME%
set REPORT_ROOT=C:\CP_Audit_Report
set REPORT_DIR=%REPORT_ROOT%\%HOST%_%TS%

if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%"

echo.
echo ==============================================================
echo CP Audit Toolbox
echo Host: %HOST%
echo Report folder: %REPORT_DIR%
echo Timestamp: %TS%
echo ==============================================================
echo.

:menu
cls
echo --------------------------------------------------------------
echo Please choose an action by number and press Enter:
echo --------------------------------------------------------------
echo 00) Preflight - collect environment metadata (meta-000)
echo 01) Installed Security Updates (patch-001)
echo 02) System File Integrity (SFC & DISM) (integrity-002)
echo 03) Local Accounts Enumeration (acct-003)
echo 04) Local Administrators group membership (acct-004)
echo 05) Password & Account Policies (acct-005)
echo 06) Export Local Security/Group Policy snapshot (gpo-006)
echo 07) Services inventory & risky services (svc-007)
echo 08) Firewall profiles & inbound rules (net-008)
echo 09) RDP & NLA settings (net-009)
echo 10) Network Shares & SMB permissions (share-010)
echo 11) NTFS permission scan (perm-011)
echo 12) Audit Policies & log sizes (audit-012)
echo 13) Scheduled Tasks & autoruns (task-013)
echo 14) Installed Software Inventory (sw-014)
echo 15) Antivirus / EDR status (ep-015)
echo 16) Legacy network protocols (SMB1/LLMNR/NetBIOS) (net-016)
echo 17) TLS / Schannel registry check (tls-017)
echo 18) IIS / Web Server basics (iis-018)
echo 19) DNS/DHCP role checks (net-019)
echo 20) Time sync / NTP (net-020)
echo 21) Certificates & expiry (cert-021)
echo 22) Disk & File Integrity Monitoring (fim-022)
echo 23) Event Forwarding & subscriptions (log-023)
echo 24) Scheduled Backups & system state (backup-024)
echo 25) SMB open sessions & handles (share-025)
echo 26) Service accounts & weak credentials (svccreds-026)
echo 27) SMB/LDAP signing checks (auth-027)
echo 28) Listening ports & owning processes (net-028)
echo 29) Unsigned drivers & recent drivers (driver-029)
echo 30) Defender ASR / Exploit Guard (def-030)
echo 31) UAC & Execution Policy (sec-031)
echo 32) Web root executable scan (web-032)
echo 33) Performance baseline (perf-033)
echo 34) Baseline / CIS quick export (baseline-034)
echo 35) Generate consolidated audit report (report-035)
echo 99) Run ALL Critical checks
echo 00) Exit
echo --------------------------------------------------------------

set /p choice=Enter number: 

if "%choice%"=="00" goto exit
if "%choice%"=="0" goto exit
if "%choice%"=="00)" goto exit
if "%choice%"=="01" goto patch001
if "%choice%"=="1" goto patch001
if "%choice%"=="02" goto integrity002
if "%choice%"=="2" goto integrity002
if "%choice%"=="03" goto acct003
if "%choice%"=="3" goto acct003
if "%choice%"=="04" goto acct004
if "%choice%"=="4" goto acct004
if "%choice%"=="05" goto acct005
if "%choice%"=="5" goto acct005
if "%choice%"=="06" goto gpo006
if "%choice%"=="6" goto gpo006
if "%choice%"=="07" goto svc007
if "%choice%"=="7" goto svc007
if "%choice%"=="08" goto net008
if "%choice%"=="8" goto net008
if "%choice%"=="09" goto net009
if "%choice%"=="9" goto net009
if "%choice%"=="10" goto share010
if "%choice%"=="11" goto perm011
if "%choice%"=="12" goto audit012
if "%choice%"=="13" goto task013
if "%choice%"=="14" goto sw014
if "%choice%"=="15" goto ep015
if "%choice%"=="16" goto net016
if "%choice%"=="17" goto tls017
if "%choice%"=="18" goto iis018
if "%choice%"=="19" goto net019
if "%choice%"=="20" goto net020
if "%choice%"=="21" goto cert021
if "%choice%"=="22" goto fim022
if "%choice%"=="23" goto log023
if "%choice%"=="24" goto backup024
if "%choice%"=="25" goto share025
if "%choice%"=="26" goto svccreds026
if "%choice%"=="27" goto auth027
if "%choice%"=="28" goto net028
if "%choice%"=="29" goto driver029
if "%choice%"=="30" goto def030
if "%choice%"=="31" goto sec031
if "%choice%"=="32" goto web032
if "%choice%"=="33" goto perf033
if "%choice%"=="34" goto baseline034
if "%choice%"=="35" goto report035
if "%choice%"=="99" goto run_critical

echo Invalid choice. Press any key to return to menu...
pause >nul
goto menu

:exit
echo Exiting... Report folder: %REPORT_DIR%
endlocal
goto :eof

:: ----------------------- ACTIONS -----------------------

:preflight
echo Running preflight (meta-000)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $meta = [PSCustomObject]@{ ComputerName = $env:COMPUTERNAME; OS = (Get-CimInstance Win32_OperatingSystem).Caption; OSVersion = (Get-CimInstance Win32_OperatingSystem).Version; IsDomainJoined = (try {[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | Out-Null; $true} catch {$false}); IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }; $meta | Format-List | Out-File -FilePath '%REPORT_DIR%\meta-000.txt' -Width 4096 } catch { 'meta check failed' | Out-File -FilePath '%REPORT_DIR%\meta-000_error.txt' }"
echo Saved: %REPORT_DIR%\meta-000.txt
pause
goto menu

:patch001
echo Installed Security Updates (patch-001)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { wmic qfe list /format:table | Out-File -FilePath '%REPORT_DIR%\\patch-001_wmic_qfe.txt' -Width 4096 } catch { Get-HotFix | Sort-Object InstalledOn -Descending | Out-File -FilePath '%REPORT_DIR%\\patch-001_hotfix.txt' -Width 4096 }"
echo Saved: %REPORT_DIR%\patch-001_*.txt
pause
goto menu

:integrity002
echo System File Integrity (SFC & DISM) (integrity-002)...
echo Running sfc /scannow /verifyonly (read-only)
sfc /scannow /verifyonly > "%REPORT_DIR%\integrity-002_sfc_verifyonly.txt" 2>&1
echo Running DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /CheckHealth > "%REPORT_DIR%\integrity-002_dism_check.txt" 2>&1
echo Saved SFC/DISM outputs.
pause
goto menu

:acct003
echo Local Accounts Enumeration (acct-003)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) { Get-LocalUser | Select-Object Name,Enabled,PasswordExpired,PasswordChangeableDate,LastLogon | Out-File -FilePath '%REPORT_DIR%\\acct-003_localusers.txt' -Width 4096 } else { 'Get-LocalUser not available on this host. Use net user fallback.' | Out-File -FilePath '%REPORT_DIR%\\acct-003_localusers.txt'; net user | Out-File -FilePath '%REPORT_DIR%\\acct-003_netuser.txt' }"
echo CMD fallback: net user
net user > "%REPORT_DIR%\acct-003_netuser.txt" 2>&1
echo Saved account listings.
pause
goto menu

:acct004
echo Local Administrators group membership (acct-004)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) { Get-LocalGroupMember -Name Administrators | Select-Object Name,ObjectClass | Out-File -FilePath '%REPORT_DIR%\\acct-004_admins.txt' -Width 4096; if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) { Get-LocalGroupMember -Name 'Remote Desktop Users' | Select-Object Name | Out-File -FilePath '%REPORT_DIR%\\acct-004_rdpusers.txt' -Width 4096 } } else { 'Get-LocalGroupMember not available; falling back to net localgroup' | Out-File -FilePath '%REPORT_DIR%\\acct-004_admins.txt'; net localgroup Administrators > '%REPORT_DIR%\\acct-004_admins.txt' }"
echo Saved Administrators and RDP users.
pause
goto menu

:acct005
echo Password & Account Policies (acct-005)...
echo net accounts output saved.
net accounts > "%REPORT_DIR%\acct-005_net_accounts.txt" 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "secedit /export /cfg C:\\temp\\secpol.cfg; if (Test-Path 'C:\\temp\\secpol.cfg') { Get-Content C:\\temp\\secpol.cfg | Out-File -FilePath '%REPORT_DIR%\\acct-005_secpol.cfg' -Width 4096 } else { 'secedit export not available' | Out-File -FilePath '%REPORT_DIR%\\acct-005_secpol_error.txt' }"
echo If domain: Get-ADDefaultDomainPasswordPolicy requires RSAT/AD module; skipping domain call by default.
pause
goto menu

:gpo006
echo Export Local Security/Group Policy snapshot (gpo-006)...
secedit /export /cfg "%REPORT_DIR%\gpo-006_secpol_export.cfg" > "%REPORT_DIR%\gpo-006_secedit_log.txt" 2>&1
gpresult /H "%REPORT_DIR%\gpo-006_gpresult.html" > "%REPORT_DIR%\gpo-006_gpresult_log.txt" 2>&1
echo Saved secedit and gpresult outputs.
pause
goto menu

:svc007
echo Services inventory & risky services (svc-007)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Service | Select-Object Name,DisplayName,Status,StartType | Sort-Object StartType | Out-File -FilePath '%REPORT_DIR%\\svc-007_services.txt' -Width 4096; Get-Service -Name RemoteRegistry,Telnet -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\svc-007_specific.txt' -Width 4096; if (Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue) { Get-SmbServerConfiguration | Select EnableSMB1Protocol,EnableSMB2Protocol | Out-File -FilePath '%REPORT_DIR%\\svc-007_smbconfig.txt' -Width 4096 } else { 'Get-SmbServerConfiguration not available on this system' | Out-File -FilePath '%REPORT_DIR%\\svc-007_smbconfig.txt' }"
pause
goto menu

:net008
echo Firewall profile & rule audit (net-008)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue) { Get-NetFirewallProfile | Select Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Out-File -FilePath '%REPORT_DIR%\\net-008_profiles.txt' -Width 4096 } else { 'Get-NetFirewallProfile not available' | Out-File -FilePath '%REPORT_DIR%\\net-008_profiles.txt' } ; if (Get-Command Get-NetFirewallRule -ErrorAction SilentlyContinue) { Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound'} | Select DisplayName,Profile,Action,Direction,Enabled | Out-File -FilePath '%REPORT_DIR%\\net-008_inboundrules.txt' -Width 4096 } else { netsh advfirewall firewall show rule name=all > '%REPORT_DIR%\\net-008_inboundrules.txt' }"
pause
goto menu

:net009
echo RDP & NLA settings (net-009)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\net-009_rdp_registry.txt' -Width 4096; Get-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' -Name UserAuthentication -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\net-009_nla_registry.txt' -Width 4096"
pause
goto menu

:share010
echo Network Shares & SMB Permissions (share-010)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-SmbShare -ErrorAction SilentlyContinue) { Get-SmbShare | Select Name,Path,Description,ScopeName | Out-File -FilePath '%REPORT_DIR%\\share-010_shares.txt' -Width 4096; ForEach ($s in Get-SmbShare) { try { icacls $s.Path | Out-File -Append -FilePath '%REPORT_DIR%\\share-010_icacls.txt' -Width 4096 } catch { ('Could not read ACL for ' + $s.Path) | Out-File -Append -FilePath '%REPORT_DIR%\\share-010_icacls.txt' } } } else { 'Get-SmbShare not available on this host' | Out-File -FilePath '%REPORT_DIR%\\share-010_shares.txt' }"
echo CMD fallback: net share
net share > "%REPORT_DIR%\share-010_netshare.txt" 2>&1
pause
goto menu

:perm011
echo NTFS permission scan (perm-011) - WARNING: can be slow on large volumes.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$roots = @('C:\\','D:\\') ; foreach ($r in $roots) { if (Test-Path $r) { Get-ChildItem -Path $r -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object { $acl = (Get-Acl $_.FullName).Access ; foreach ($ace in $acl) { if ($ace.IdentityReference -match 'Everyone|Authenticated Users' -and $ace.FileSystemRights -match 'FullControl|Modify|Write') { [PSCustomObject]@{Path=$_.FullName;Identity=$ace.IdentityReference;Rights=$ace.FileSystemRights} | Out-File -FilePath '%REPORT_DIR%\\perm-011_weak_acls.txt' -Append -Width 4096 } } } } }"
echo Saved perm-011 results (may be empty). File: %REPORT_DIR%\perm-011_weak_acls.txt
pause
goto menu

:audit012
echo Audit Policies & log retention (audit-012)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "auditpol /get /category:* | Out-File -FilePath '%REPORT_DIR%\\audit-012_auditpol.txt' -Width 4096; wevtutil gl Security | Out-File -FilePath '%REPORT_DIR%\\audit-012_wevtutil_security.txt' -Width 4096; Get-WinEvent -ListLog Security | Select LogName,MaximumSizeInBytes | Out-File -FilePath '%REPORT_DIR%\\audit-012_logsize.txt' -Width 4096"
pause
goto menu

:task013
echo Scheduled Tasks & autoruns (task-013)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) { Get-ScheduledTask | Select TaskName,State,TaskPath | Out-File -FilePath '%REPORT_DIR%\\task-013_tasks.txt' -Width 4096 } else { schtasks /query /fo LIST | Out-File -FilePath '%REPORT_DIR%\\task-013_tasks.txt' }"
wmic startup get caption,command > "%REPORT_DIR%\task-013_startup_wmic.txt" 2>&1
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" > "%REPORT_DIR%\task-013_run_hklm.txt" 2>&1
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" > "%REPORT_DIR%\task-013_run_hkcu.txt" 2>&1
pause
goto menu

:sw014
echo Installed Software Inventory (sw-014)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Select DisplayName,DisplayVersion,Publisher,InstallDate | Out-File -FilePath '%REPORT_DIR%\\sw-014_installed_wow64.txt' -Width 4096; Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Select DisplayName,DisplayVersion,Publisher,InstallDate | Out-File -FilePath '%REPORT_DIR%\\sw-014_installed_x64.txt' -Width 4096"
pause
goto menu

:ep015
echo Antivirus / Endpoint Protection status (ep-015)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Get-MpComputerStatus | Select AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,QuickScanTime | Out-File -FilePath '%REPORT_DIR%\\ep-015_defender_status.txt' -Width 4096 } catch { 'Get-MpComputerStatus not available' | Out-File -FilePath '%REPORT_DIR%\\ep-015_error.txt' }"
pause
goto menu

:net016
echo Legacy network protocol checks (net-016)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue) { Get-SmbServerConfiguration | Select EnableSMB1Protocol | Out-File -FilePath '%REPORT_DIR%\\net-016_smb1.txt' -Width 4096 } else { 'Get-SmbServerConfiguration not available' | Out-File -FilePath '%REPORT_DIR%\\net-016_smb1.txt' } ; Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select Description,SettingID,DNSServerSearchOrder,DomainDNSRegistrationEnabled | Out-File -FilePath '%REPORT_DIR%\\net-016_netconf.txt' -Width 4096; Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\DNSClient' -Name EnableMulticast -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\net-016_llmnr_registry.txt' -Width 4096"
pause
goto menu

:tls017
echo TLS / Schannel settings (tls-017)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols' -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\tls-017_schannel.txt' -Width 4096"
pause
goto menu

:iis018
echo IIS checks (iis-018)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Get-Website -ErrorAction SilentlyContinue) { Import-Module WebAdministration -ErrorAction SilentlyContinue; Get-Website | Select name,state,physicalPath | Out-File -FilePath '%REPORT_DIR%\\iis-018_websites.txt' -Width 4096; Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter \"system.webServer/directoryBrowse\" -name enabled | Out-File -FilePath '%REPORT_DIR%\\iis-018_dirbrowse.txt' -Width 4096 } else { 'IIS WebAdministration module not present' | Out-File -FilePath '%REPORT_DIR%\\iis-018_websites.txt' }"
netsh http show sslcert > "%REPORT_DIR%\iis-018_sslcerts.txt" 2>&1
pause
goto menu

:net019
echo DNS/DHCP role checks (net-019)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-DnsServerZone -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\net-019_dns_zones.txt' -Width 4096; Get-DhcpServerInDC -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\net-019_dhcp.txt' -Width 4096"
pause
goto menu

:net020
echo Time sync / NTP (net-020)...
w32tm /query /status > "%REPORT_DIR%\net-020_w32tm_status.txt" 2>&1
w32tm /query /configuration > "%REPORT_DIR%\net-020_w32tm_config.txt" 2>&1
pause
goto menu

:cert021
echo Certificates & PKI (cert-021)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path Cert:\\LocalMachine\\My | Select-Object Subject,Thumbprint,NotBefore,NotAfter,FriendlyName | Out-File -FilePath '%REPORT_DIR%\\cert-021_localmachine_my.txt' -Width 4096"
pause
goto menu

:fim022
echo Disk & FIM checks (fim-022)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PSDrive -PSProvider FileSystem | Select Name,Free,Used | Out-File -FilePath '%REPORT_DIR%\\fim-022_psdrive.txt' -Width 4096; Get-Service | Where-Object {$_.Name -match 'tripwire|ossec|sysmon|titan'} | Out-File -FilePath '%REPORT_DIR%\\fim-022_fim_agents.txt' -Width 4096"
pause
goto menu

:log023
echo Event forwarding & subscriptions (log-023)...
wecutil gr > "%REPORT_DIR%\log-023_wecutil_gr.txt" 2>&1
wecutil gs > "%REPORT_DIR%\log-023_wecutil_gs.txt" 2>&1
pause
goto menu

:backup024
echo Scheduled Backups (backup-024)...
wbadmin get versions > "%REPORT_DIR%\backup-024_wbadmin_versions.txt" 2>&1
wbadmin get status > "%REPORT_DIR%\backup-024_wbadmin_status.txt" 2>&1
pause
goto menu

:share025
echo SMB open sessions & file handles (share-025)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-SmbSession | Out-File -FilePath '%REPORT_DIR%\\share-025_sessions.txt' -Width 4096; Get-SmbOpenFile | Out-File -FilePath '%REPORT_DIR%\\share-025_openfiles.txt' -Width 4096"
pause
goto menu

:svccreds026
echo Service accounts & password policy checks (svccreds-026)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WmiObject Win32_Service | Select Name,StartName,DisplayName,State | Out-File -FilePath '%REPORT_DIR%\\svccreds-026_services.txt' -Width 4096; Get-LocalUser | Select Name,PasswordNeverExpires | Out-File -FilePath '%REPORT_DIR%\\svccreds-026_localusers_pwflags.txt' -Width 4096"
pause
goto menu

:auth027
echo SMB/LDAP signing checks (auth-027)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters' -Name RequireSecuritySignature -ErrorAction SilentlyContinue | Out-File -FilePath '%REPORT_DIR%\\auth-027_smb_signing.txt' -Width 4096"
pause
goto menu

:net028
echo Listening ports & owning process (net-028)...
netstat -ano > "%REPORT_DIR%\net-028_netstat_ano.txt" 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess | Out-File -FilePath '%REPORT_DIR%\\net-028_tcpconns.txt' -Width 4096; (Get-NetTCPConnection -State Listen).OwningProcess | ForEach-Object { try { Get-Process -Id $_ | Select-Object Id,ProcessName | Out-File -Append -FilePath '%REPORT_DIR%\\net-028_listening_procs.txt' } catch { } }"
pause
goto menu

:driver029
echo Unsigned drivers & recently installed drivers (driver-029)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.Signer -ne 'Microsoft Windows Hardware Compatibility Publisher'} | Select DeviceName,DriverVersion,Manufacturer,Signer | Out-File -FilePath '%REPORT_DIR%\\driver-029_unsigned_drivers.txt' -Width 4096"
pause
goto menu

:def030
echo Defender Exploit Guard & ASR (def-030)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-MpPreference | Select-Object AttackSurfaceReductionRules_Ids,AttackSurfaceReductionRules_Actions,EnableControlledFolderAccess | Out-File -FilePath '%REPORT_DIR%\\def-030_mp_preference.txt' -Width 4096; Get-MpThreat | Select Timestamp,ThreatName,ActionSuccess | Out-File -FilePath '%REPORT_DIR%\\def-030_mp_threats.txt' -Width 4096"
pause
goto menu

:sec031
echo Local Security Options (UAC, ExecutionPolicy) (sec-031)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System' | Select EnableLUA,ConsentPromptBehaviorAdmin | Out-File -FilePath '%REPORT_DIR%\\sec-031_uac.txt' -Width 4096; Get-ExecutionPolicy -List | Out-File -FilePath '%REPORT_DIR%\\sec-031_execpolicy.txt' -Width 4096"
pause
goto menu

:web032
echo Web root executable scan (web-032)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path C:\\inetpub\\wwwroot -Recurse -Include *.exe,*.ps1,*.scr -ErrorAction SilentlyContinue | Select FullName | Out-File -FilePath '%REPORT_DIR%\\web-032_wwwroot_exes.txt' -Width 4096; Get-ChildItem -Path C:\\Users -Recurse -Include *.exe -ErrorAction SilentlyContinue | Select FullName | Out-File -FilePath '%REPORT_DIR%\\web-032_users_exes.txt' -Width 4096"
pause
goto menu

:perf033
echo Performance baseline (perf-033)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Counter '\\Processor(_Total)\\% Processor Time','\\Memory\\Available MBytes','\\LogicalDisk(_Total)\\% Disk Time' | Out-File -FilePath '%REPORT_DIR%\\perf-033_counters.txt' -Width 4096"
pause
goto menu

:baseline034
echo Baseline exports (baseline-034)...
secedit /export /cfg "%REPORT_DIR%\baseline-034_secpol.cfg" > "%REPORT_DIR%\baseline-034_secedit_log.txt" 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-SmbServerConfiguration | Out-File -FilePath '%REPORT_DIR%\\baseline-034_smbconfig.txt' -Width 4096; Get-NetFirewallProfile | Out-File -FilePath '%REPORT_DIR%\\baseline-034_firewallprofiles.txt' -Width 4096"
pause
goto menu

:report035
echo Generating consolidated audit index (report-035)...
echo Report generated on %DATE% %TIME% > "%REPORT_DIR%\report-035_index.txt"
echo Host: %HOST% >> "%REPORT_DIR%\report-035_index.txt"
echo Timestamp: %TS% >> "%REPORT_DIR%\report-035_index.txt"
echo >> "%REPORT_DIR%\report-035_index.txt"
echo Contents: >> "%REPORT_DIR%\report-035_index.txt"
dir /b "%REPORT_DIR%" >> "%REPORT_DIR%\report-035_index.txt"
echo Completed index at %REPORT_DIR%\report-035_index.txt
pause
goto menu

:run_critical
echo Running ALL Critical checks sequentially. This will run read-only enumerations for critical items and save to report folder.
echo (May require Administrator privileges for full output.)
call :preflight
call :patch001
call :acct003
call :acct004
call :acct005
call :svc007
call :net008
call :share010
call :perm011
call :audit012
call :task013
call :sw014
call :ep015
call :backup024
call :report035
echo Completed critical checks. See %REPORT_DIR%
pause
goto menu
