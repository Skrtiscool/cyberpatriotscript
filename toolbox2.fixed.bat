@echo off
:: Toolbox2 - consolidated Windows admin tasks (menu-driven)
:: Location: c:\Users\skrti\Downloads\toolbox2.bat
:: Note: Run as Administrator. The script will attempt to elevate if not run elevated.

REM Elevation check and relaunch as admin if needed
powershell -Command "If(-not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process -FilePath '%~f0' -Verb RunAs; Exit }"

:: Self-heal for cmd parsing issues on older Windows 10 builds.
:: If this file contains echo lines with unescaped & characters, create a fixed ASCII copy and relaunch it elevated.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $p = '%~f0'; try { $lines = Get-Content -LiteralPath $p -ErrorAction Stop } catch { Exit 0 }; $changed = $false; $out = New-Object System.Collections.Generic.List[System.String]; foreach ($line in $lines) { if ($line -match '^[ \t]*echo\b' -and $line -match '(?<!\^)\s&\s') { $line = $line -replace '(?<!\^)\s&\s',' ^& '; $changed = $true } $out.Add($line) }; if ($changed) { $fixed = [IO.Path]::ChangeExtension($p, '.fixed.bat'); Set-Content -LiteralPath $fixed -Value $out -Encoding Ascii; Start-Process -FilePath $fixed -Verb RunAs; Exit 0 } }"

title Toolbox2 - Windows Admin Toolkit
:main
cls
echo ===============================
echo  Toolbox2 - Windows Admin Toolkit
echo  (Grouped options; pick a number)
echo ===============================
echo 1) User Accounts
echo 2) Groups
echo 3) Password ^& Lockout Policies
echo 4) Auditing
echo 5) Services
echo 6) Features ^& Roles (SMBv1, Telnet, FTP, IIS)
echo 7) Firewall
echo 8) Network (IP/DNS/Adapters)
echo 9) File System ^& ACLs
echo 10) Startup ^& Scheduled Tasks
echo 11) Updates ^& Reboot
echo 12) Cleanup ^& Browsers
echo 13) IIS / DNS / DHCP (server roles)
echo 14) Security Resets ^& Repair (SFC/DISM/Firewall reset)
echo 15) Exit
echo.
set /p choice=Enter choice [1-15]: 
if "%choice%"=="1" goto user_accounts
if "%choice%"=="2" goto groups
if "%choice%"=="3" goto policies
if "%choice%"=="4" goto auditing
if "%choice%"=="5" goto services
if "%choice%"=="6" goto features
if "%choice%"=="7" goto firewall
if "%choice%"=="8" goto network
if "%choice%"=="9" goto filesystem
if "%choice%"=="10" goto startup
if "%choice%"=="11" goto updates
if "%choice%"=="12" goto cleanup
if "%choice%"=="13" goto roles
if "%choice%"=="14" goto repair
if "%choice%"=="15" goto :eof
echo Invalid choice. Press any key to try again...
pause >nul
goto main

:: -------------------------
:user_accounts
cls
echo User Accounts submenu
echo 1) List local users
echo 2) Create user
echo 3) Delete user
echo 4) Disable user
echo 5) Set user password
echo 6) Force password change at next logon
echo 7) Disable built-in accounts (Guest, DefaultAccount, WDAGUtilityAccount)
echo 8) Back
set /p uchoice=Choice [1-8]: 
if "%uchoice%"=="1" (
  powershell -NoProfile -Command "If (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) { Get-LocalUser | Format-Table Name,Enabled,LastLogon -AutoSize } else { net user }"
  pause
  goto main
)
if "%uchoice%"=="2" (
  set /p uname=Enter new username: 
  set /p upass=Enter password (visible): 
  powershell -NoProfile -Command "param([string]$u,[string]$p) if (Get-Command New-LocalUser -ErrorAction SilentlyContinue) { if (-not (Get-LocalUser -Name $u -ErrorAction SilentlyContinue)) { $sec=ConvertTo-SecureString $p -AsPlainText -Force; New-LocalUser -Name $u -Password $sec -FullName $u -Description 'Created by Toolbox2'; Add-LocalGroupMember -Group 'Users' -Member $u; Write-Host 'Created' $u } else { Write-Host 'User exists:' $u } } else { net user $u $p /add; Write-Host 'Created (net) ' $u }" -ArgumentList "%uname%","%upass%"
  pause
  goto main
)
if "%uchoice%"=="3" (
  set /p deluser=Enter username to delete: 
  powershell -NoProfile -Command "param([string]$u) if (Get-Command Remove-LocalUser -ErrorAction SilentlyContinue) { if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) { Remove-LocalUser -Name $u -Confirm:$false; Write-Host 'Deleted' $u } else { Write-Host 'User not found:' $u } } else { net user $u /delete; Write-Host 'Deleted (net) ' $u }" -ArgumentList "%deluser%"
  pause
  goto main
)
if "%uchoice%"=="4" (
  set /p duser=Enter username to disable: 
  powershell -NoProfile -Command "param([string]$u) if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) { if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) { Disable-LocalUser -Name $u; Write-Host 'Disabled' $u } else { Write-Host 'User not found:' $u } } else { net user $u /active:no; Write-Host 'Disabled (net) ' $u }" -ArgumentList "%duser%"
  pause
  goto main
)
if "%uchoice%"=="5" (
  set /p spuser=Enter username to set password for: 
  set /p spass=Enter new password (visible): 
  powershell -NoProfile -Command "param([string]$u,[string]$p) $sec=ConvertTo-SecureString $p -AsPlainText -Force; if (Get-Command Set-LocalUser -ErrorAction SilentlyContinue) { if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) { Set-LocalUser -Name $u -Password $sec; Write-Host 'Password set for' $u } else { Write-Host 'User not found:' $u } } else { net user $u $p; Write-Host 'Password set (net) for' $u }" -ArgumentList "%spuser%","%spass%"
  pause
  goto main
)
if "%uchoice%"=="6" (
  set /p fuser=Enter username to force change at next logon: 
  powershell -NoProfile -Command "param([string]$u) if (Get-Command Set-LocalUser -ErrorAction SilentlyContinue) { if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) { net user $u /logonpasswordchg:yes; Write-Host 'Set to change password at next logon for' $u } else { Write-Host 'User not found:' $u } } else { net user $u /logonpasswordchg:yes; Write-Host 'Requested change at next logon (net) for' $u }" -ArgumentList "%fuser%"
  pause
  goto main
)
if "%uchoice%"=="7" (
  echo Disabling built-in accounts (Guest, DefaultAccount, WDAGUtilityAccount)...
  powershell -NoProfile -Command "@('Guest','DefaultAccount','WDAGUtilityAccount') | ForEach-Object { if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) { if (Get-LocalUser -Name $_ -ErrorAction SilentlyContinue) { Disable-LocalUser -Name $_; Write-Host 'Disabled' $_ } } else { if (net user $_ 2>$null) { net user $_ /active:no; Write-Host 'Disabled (net)' $_ } } }"
  pause
  goto main
)
if "%uchoice%"=="8" goto main
goto user_accounts

:: -------------------------
:groups
cls
echo Groups submenu
echo 1) List local groups
echo 2) List members of a group
echo 3) Add user to a group
echo 4) Remove user from a group
echo 5) Back
set /p gchoice=Choice [1-5]: 
if "%gchoice%"=="1" (
  powershell -NoProfile -Command "If (Get-Command Get-LocalGroup -ErrorAction SilentlyContinue) { Get-LocalGroup | Format-Table Name,Description -AutoSize } else { net localgroup }"
  pause
  goto main
)
if "%gchoice%"=="2" (
  set /p gname=Enter group name: 
  powershell -NoProfile -Command "param([string]$g) if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) { Get-LocalGroupMember -Group $g | Format-Table Name,ObjectClass -AutoSize } else { net localgroup $g }" -ArgumentList "%gname%"
  pause
  goto main
)
if "%gchoice%"=="3" (
  set /p gu=Enter username to add: 
  set /p gg=Enter group name: 
  powershell -NoProfile -Command "param([string]$u,[string]$g) if (Get-Command Add-LocalGroupMember -ErrorAction SilentlyContinue) { Add-LocalGroupMember -Group $g -Member $u; Write-Host 'Added' $u 'to' $g } else { net localgroup $g $u /add; Write-Host 'Added (net)' $u 'to' $g }" -ArgumentList "%gu%","%gg%"
  pause
  goto main
)
if "%gchoice%"=="4" (
  set /p rgu=Enter username to remove: 
  set /p rgg=Enter group name: 
  powershell -NoProfile -Command "param([string]$u,[string]$g) if (Get-Command Remove-LocalGroupMember -ErrorAction SilentlyContinue) { Remove-LocalGroupMember -Group $g -Member $u -Confirm:$false -ErrorAction SilentlyContinue; Write-Host 'Removed' $u 'from' $g } else { net localgroup $g $u /delete; Write-Host 'Removed (net)' $u 'from' $g }" -ArgumentList "%rgu%","%rgg%"
  pause
  goto main
)
if "%gchoice%"=="5" goto main
goto groups

:: -------------------------
:policies
cls
echo Password ^& Lockout Policies submenu
echo 1) Set minimum password length
echo 2) Enable password complexity
echo 3) Set max/min password age
echo 4) Set password history length
echo 5) Disable reversible encryption
echo 6) Set account lockout threshold/duration/window
echo 7) Back
set /p pchoice=Choice [1-7]: 
if "%pchoice%"=="1" (
  set /p minlen=Enter minimum password length e.g. 14: 
  powershell -NoProfile -Command "param($m) net accounts /minpwlen:$m; Write-Host 'Set min password length to' $m" -ArgumentList "%minlen%"
  pause
  goto main
)
if "%pchoice%"=="2" (
  echo Enabling password complexity (local policy)...
  powershell -NoProfile -Command "secedit /export /cfg $env:windir\Temp\secpol.cfg; (Get-Content $env:windir\Temp\secpol.cfg) -replace 'PasswordComplexity = \d+','PasswordComplexity = 1' | Set-Content $env:windir\Temp\secpol.cfg; secedit /configure /db secedit.sdb /cfg $env:windir\Temp\secpol.cfg /areas SECURITYPOLICY; Write-Host 'Password complexity enabled (local policy)';"
  pause
  goto main
)
if "%pchoice%"=="3" (
  set /p maxdays=Enter maximum password age in days e.g. 60: 
  set /p mindays=Enter minimum password age in days e.g. 1: 
  powershell -NoProfile -Command "param($max,$min) net accounts /maxpwage:$max; net accounts /minpwage:$min; Write-Host 'Set max/min password age to' $max '/' $min" -ArgumentList "%maxdays%","%mindays%"
  pause
  goto main
)
if "%pchoice%"=="4" (
  set /p history=Enter password history count e.g. 24: 
  powershell -NoProfile -Command "param($h) secedit /export /cfg $env:windir\Temp\secpol.cfg; (Get-Content $env:windir\Temp\secpol.cfg) -replace 'PasswordHistorySize = \d+','PasswordHistorySize = $h' | Set-Content $env:windir\Temp\secpol.cfg; secedit /configure /db secedit.sdb /cfg $env:windir\Temp\secpol.cfg /areas SECURITYPOLICY; Write-Host 'Password history set to' $h" -ArgumentList "%history%"
  pause
  goto main
)
if "%pchoice%"=="5" (
  powershell -NoProfile -Command "secedit /export /cfg $env:windir\Temp\secpol.cfg; (Get-Content $env:windir\Temp\secpol.cfg) -replace 'ClearTextPassword = \d+','ClearTextPassword = 0' | Set-Content $env:windir\Temp\secpol.cfg; secedit /configure /db secedit.sdb /cfg $env:windir\Temp\secpol.cfg /areas SECURITYPOLICY; Write-Host 'Disabled reversible encryption (local policy)';"
  pause
  goto main
)
if "%pchoice%"=="6" (
  set /p thr=Enter lockout threshold (invalid attempts) e.g. 5: 
  set /p dur=Enter lockout duration in minutes e.g. 30: 
  set /p win=Enter lockout observation window in minutes e.g. 30: 
  powershell -NoProfile -Command "param($t,$d,$w) net accounts /lockoutthreshold:$t; net accounts /lockoutduration:$d; net accounts /lockoutwindow:$w; Write-Host 'Lockout configured'" -ArgumentList "%thr%","%dur%","%win%"
  pause
  goto main
)
if "%pchoice%"=="7" goto main
goto policies

:: -------------------------
:auditing
cls
echo Auditing submenu
echo 1) Enable common audit categories (Logon, Account Logon, Account Management, Privilege Use, Process Tracking, System)
echo 2) Back
set /p achoice=Choice [1-2]: 
if "%achoice%"=="1" (
  echo Enabling selected audit subcategories (best-effort)...
  powershell -NoProfile -Command "auditpol /set /subcategory:'Logon' /success:enable /failure:enable; auditpol /set /subcategory:'Account Logon' /success:enable /failure:enable; auditpol /set /subcategory:'User Account Management' /success:enable /failure:enable; auditpol /set /subcategory:'Privilege Use' /failure:enable; auditpol /set /subcategory:'Process Creation' /success:enable; auditpol /set /subcategory:'System' /success:enable /failure:enable; Write-Host 'Audit categories updated'"
  pause
  goto main
)
if "%achoice%"=="2" goto main
goto auditing

:: -------------------------
:services
cls
echo Services submenu
echo 1) List services
echo 2) Start a service
echo 3) Stop a service
echo 4) Disable a service
echo 5) Set service to Automatic
echo 6) Back
set /p schoice=Choice [1-6]: 
if "%schoice%"=="1" (
  powershell -NoProfile -Command "Get-Service | Sort-Object Status,Name | Format-Table Status,Name,DisplayName -AutoSize"
  pause
  goto main
)
if "%schoice%"=="2" (
  set /p svc=Enter service name: 
  powershell -NoProfile -Command "param($s) if (Get-Service -Name $s -ErrorAction SilentlyContinue) { Start-Service -Name $s; Write-Host 'Started' $s } else { Write-Host 'Service not found' }" -ArgumentList "%svc%"
  pause
  goto main
)
if "%schoice%"=="3" (
  set /p svcstop=Enter service name: 
  powershell -NoProfile -Command "param($s) if (Get-Service -Name $s -ErrorAction SilentlyContinue) { Stop-Service -Name $s -Force; Write-Host 'Stopped' $s } else { Write-Host 'Service not found' }" -ArgumentList "%svcstop%"
  pause
  goto main
)
if "%schoice%"=="4" (
  set /p svcd=Enter service name to disable: 
  powershell -NoProfile -Command "param($s) if (Get-Service -Name $s -ErrorAction SilentlyContinue) { Set-Service -Name $s -StartupType Disabled; Stop-Service -Name $s -Force -ErrorAction SilentlyContinue; Write-Host 'Disabled' $s } else { Write-Host 'Service not found' }" -ArgumentList "%svcd%"
  pause
  goto main
)
if "%schoice%"=="5" (
  set /p svca=Enter service name to set Automatic: 
  powershell -NoProfile -Command "param($s) if (Get-Service -Name $s -ErrorAction SilentlyContinue) { Set-Service -Name $s -StartupType Automatic; Write-Host 'Set' $s 'to Automatic' } else { Write-Host 'Service not found' }" -ArgumentList "%svca%"
  pause
  goto main
)
if "%schoice%"=="6" goto main
goto services

:: -------------------------
:features
cls
echo Features ^& Roles submenu
echo 1) Disable SMBv1
echo 2) Disable Telnet Client
echo 3) Disable FTP / IIS features
echo 4) Back
  set /p fchoice=Choice [1-4]: 
if "%fchoice%"=="1" (
  powershell -NoProfile -Command "If (Get-Command Set-SmbServerConfiguration -ErrorAction SilentlyContinue) { Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force } ; dism /online /norestart /disable-feature /featurename:SMB1Protocol; Write-Host 'SMBv1 disable attempted. Restart may be required.'"
  pause
  goto main
)
if "%fchoice%"=="2" (
  dism /online /norestart /disable-feature /featurename:TelnetClient
  echo Telnet client disable attempted.
  pause
  goto main
)
if "%fchoice%"=="3" (
  echo Removing common IIS/FTP features (best-effort)...
  dism /online /norestart /disable-feature /featurename:IIS-WebServerRole
  dism /online /norestart /disable-feature /featurename:IIS-FTPSvc
  echo IIS/FTP features removal requested.
  pause
  goto main
)
if "%fchoice%"=="4" goto main
goto features

:: -------------------------
:firewall
cls
echo Firewall submenu
echo 1) Enable Firewall (Domain/Private/Public)
echo 2) List inbound rules
echo 3) Create inbound rule (example: allow TCP port)
echo 4) Disable or delete rule
echo 5) Block all inbound/outbound by default
echo 6) Back
set /p fwchoice=Choice [1-6]: 
if "%fwchoice%"=="1" (
  powershell -NoProfile -Command "Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True; Write-Host 'Firewall profiles enabled'"
  pause
  goto main
)
if "%fwchoice%"=="2" (
  powershell -NoProfile -Command "Get-NetFirewallRule -Direction Inbound | Format-Table DisplayName,Name,Enabled,Profile,Action -AutoSize"
  pause
  goto main
)
if "%fwchoice%"=="3" (
  set /p rname=Enter rule name (display): 
  set /p rport=Enter local TCP port e.g. 3389: 
  powershell -NoProfile -Command "param($n,$p) New-NetFirewallRule -DisplayName $n -Direction Inbound -Action Allow -Protocol TCP -LocalPort $p -Profile Domain,Private,Public; Write-Host 'Created rule' $n" -ArgumentList "%rname%","%rport%"
  pause
  goto main
)
if "%fwchoice%"=="4" (
  set /p rulename=Enter rule DisplayName to disable/delete: 
  powershell -NoProfile -Command "param($n) Get-NetFirewallRule -DisplayName $n -ErrorAction SilentlyContinue | Set-NetFirewallRule -Enabled False; Get-NetFirewallRule -DisplayName $n -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false -ErrorAction SilentlyContinue; Write-Host 'Disabled/deleted rule' $n" -ArgumentList "%rulename%"
  pause
  goto main
)
if "%fwchoice%"=="5" (
  powershell -NoProfile -Command "Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block; Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Block; Write-Host 'Default inbound/outbound set to Block (all profiles)';"
  pause
  goto main
)
if "%fwchoice%"=="6" goto main
goto firewall

:: -------------------------
:network
cls
echo Network submenu
echo 1) List network adapters
echo 2) Set static IPv4 address
echo 3) Set IPv4 DNS server
echo 4) Enable DHCP on interface
echo 5) Disable IPv6 on interface
echo 6) Back
set /p nchoice=Choice [1-6]: 
if "%nchoice%"=="1" (
  powershell -NoProfile -Command "Get-NetAdapter | Format-Table Name,InterfaceDescription,Status,MacAddress -AutoSize"
  pause
  goto main
)
if "%nchoice%"=="2" (
  set /p iface=Enter Interface Alias e.g. Ethernet: 
  set /p ip=Enter IPv4 address: 
  set /p prefix=Enter Prefix length e.g. 24: 
  set /p gw=Enter Gateway: 
  powershell -NoProfile -Command "param($i,$a,$p,$g) New-NetIPAddress -InterfaceAlias $i -IPAddress $a -PrefixLength $p -DefaultGateway $g; Write-Host 'Set static IP on' $i" -ArgumentList "%iface%","%ip%","%prefix%","%gw%"
  pause
  goto main
)
if "%nchoice%"=="3" (
  set /p ifdns=Enter Interface Alias: 
  set /p dns=Enter DNS server(s) comma-separated: 
  powershell -NoProfile -Command "param($i,$d) Set-DnsClientServerAddress -InterfaceAlias $i -ServerAddresses ($d -split ','); Write-Host 'Set DNS on' $i" -ArgumentList "%ifdns%","%dns%"
  pause
  goto main
)
if "%nchoice%"=="4" (
  set /p dhcpif=Enter Interface Alias: 
  powershell -NoProfile -Command "param($i) Set-NetIPInterface -InterfaceAlias $i -Dhcp Enabled; Set-DnsClientServerAddress -InterfaceAlias $i -ResetServerAddresses; Write-Host 'Enabled DHCP on' $i" -ArgumentList "%dhcpif%"
  pause
  goto main
)
if "%nchoice%"=="5" (
  set /p v6if=Enter Interface Alias: 
  powershell -NoProfile -Command "param($i) Disable-NetAdapterBinding -Name $i -ComponentID ms_tcpip6; Write-Host 'Disabled IPv6 binding on' $i" -ArgumentList "%v6if%"
  pause
  goto main
)
if "%nchoice%"=="6" goto main
goto network

:: -------------------------
:filesystem
cls
echo File System ^& ACLs submenu
echo 1) List ACLs for a directory (recursive)
echo 2) Grant permissions to a user on a folder
echo 3) Remove permissions from a folder
echo 4) Remove 'Everyone' full-control recursively from directories
echo 5) Set NTFS inheritance (enable/disable)
echo 6) Create a folder
echo 7) Delete a folder or file
echo 8) Back
set /p fschoice=Choice [1-8]: 
if "%fschoice%"=="1" (
  set /p fpath=Enter folder path: 
  powershell -NoProfile -Command "param($p) Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { Write-Output '== ' $_.FullName; Get-Acl $_.FullName | Format-List }" -ArgumentList "%fpath%"
  pause
  goto main
)
if "%fschoice%"=="2" (
  set /p grantpath=Enter folder path: 
  set /p guser=Enter user (DOMAIN\User or User): 
  set /p gperm=Enter permission e.g. Modify: 
  powershell -NoProfile -Command "param($p,$u,$r) $acl=Get-Acl $p; $ar=New-Object System.Security.AccessControl.FileSystemAccessRule($u,$r,'ContainerInherit,ObjectInherit','None','Allow'); $acl.AddAccessRule($ar); Set-Acl -Path $p -AclObject $acl; Write-Host 'Granted' $r 'to' $u 'on' $p" -ArgumentList "%grantpath%","%guser%","%gperm%"
  pause
  goto main
)
if "%fschoice%"=="3" (
  set /p rpath=Enter folder path: 
  set /p ruser=Enter user to remove: 
  powershell -NoProfile -Command "param($p,$u) $acl=Get-Acl $p; $rules=$acl.Access | Where-Object { $_.IdentityReference -like '*'+$u } ; foreach ($r in $rules) { $acl.RemoveAccessRule($r) } ; Set-Acl -Path $p -AclObject $acl; Write-Host 'Removed rules for' $u 'on' $p" -ArgumentList "%rpath%","%ruser%"
  pause
  goto main
)
if "%fschoice%"=="4" (
  set /p everyone_path=Enter root folder to process: 
  powershell -NoProfile -Command "param($p) Get-ChildItem -Path $p -Recurse -Directory -Force | ForEach-Object { $acl=Get-Acl $_.FullName; $acl.Access | Where-Object { $_.IdentityReference -match 'Everyone' -and $_.FileSystemRights -match 'FullControl' } | ForEach-Object { $acl.RemoveAccessRule($_) }; Set-Acl -Path $_.FullName -AclObject $acl } ; Write-Host 'Attempted to remove Everyone full-control under' $p" -ArgumentList "%everyone_path%"
  pause
  goto main
)
if "%fschoice%"=="5" (
  set /p inherpath=Enter folder path: 
  set /p inher=Enable inheritance? y or n: 
  if /I "%inher%"=="y" ( icacls "%inherpath%" /inheritance:e ) else ( icacls "%inherpath%" /inheritance:d )
  pause
  goto main
)
if "%fschoice%"=="6" (
  set /p newfolder=Enter folder path to create: 
  powershell -NoProfile -Command "param($p) New-Item -Path $p -ItemType Directory -Force | Out-Null; Write-Host 'Created' $p" -ArgumentList "%newfolder%"
  pause
  goto main
)
if "%fschoice%"=="7" (
  set /p todel=Enter file or folder path to delete: 
  powershell -NoProfile -Command "param($p) Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue; Write-Host 'Deleted' $p" -ArgumentList "%todel%"
  pause
  goto main
)
if "%fschoice%"=="8" goto main
goto filesystem

:: -------------------------
:startup
cls
echo Startup ^& Scheduled Tasks submenu
echo 1) List scheduled tasks
echo 2) Disable a scheduled task
echo 3) Delete a scheduled task
echo 4) Remove startup shortcuts from Startup folders
echo 5) Remove startup registry entries (show+confirm)
echo 6) Back
  set /p stchoice=Choice [1-6]: 
if "%stchoice%"=="1" (
  powershell -NoProfile -Command "Get-ScheduledTask | Format-Table TaskName,State,Actions -AutoSize"
  pause
  goto main
)
if "%stchoice%"=="2" (
  set /p tname=Enter scheduled task name: 
  powershell -NoProfile -Command "param($t) if (Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue) { Disable-ScheduledTask -TaskName $t; Write-Host 'Disabled' $t } else { schtasks /Change /TN $t /Disable 2>$null; Write-Host 'Attempted (schtasks) to disable' $t }" -ArgumentList "%tname%"
  pause
  goto main
)
if "%stchoice%"=="3" (
  set /p tdname=Enter scheduled task name to delete: 
  powershell -NoProfile -Command "param($t) if (Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue) { Unregister-ScheduledTask -TaskName $t -Confirm:$false; Write-Host 'Deleted' $t } else { schtasks /Delete /TN $t /F 2>$null; Write-Host 'Attempted (schtasks) delete' $t }" -ArgumentList "%tdname%"
  pause
  goto main
)
if "%stchoice%"=="4" (
  echo Removing startup shortcuts (current user and all users)...
  del /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*" 2>nul
  del /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\*" 2>nul
  echo Startup folders cleared (shortcuts removed)
  pause
  goto main
)
if "%stchoice%"=="5" (
  echo THIS WILL LIST current Run keys. You will be asked which entry to remove.
  powershell -NoProfile -Command "Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run; Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
  set /p remk=Enter full registry key in format HKCU:\...\Run;Name or press Enter to skip: 
  if not "%remk%"=="" (
    for /f "tokens=1,2 delims=;" %%A in ("%remk%") do ( powershell -NoProfile -Command "Remove-ItemProperty -Path '%%A' -Name '%%B' -ErrorAction SilentlyContinue; Write-Host 'Removed' %%B 'from' '%%A'" )
  )
  pause
  goto main
)
if "%stchoice%"=="6" goto main
goto startup

:: -------------------------
:updates
cls
echo Updates ^& Reboot submenu
echo 1) Enable Windows Update service (set Automatic)
echo 2) Check for updates (best-effort)
echo 3) Install available updates (best-effort)
echo 4) Reboot now
echo 5) Back
  set /p upchoice=Choice [1-5]: 
if "%upchoice%"=="1" (
  powershell -NoProfile -Command "Set-Service -Name wuauserv -StartupType Automatic; Start-Service -Name wuauserv; Write-Host 'Windows Update service set to Automatic'"
  pause
  goto main
)
if "%upchoice%"=="2" (
  echo Attempting to check for updates (legacy/tools vary by Windows build)...
  wuauclt /detectnow 2>nul
  powershell -NoProfile -Command "If (Get-Command UsoClient -ErrorAction SilentlyContinue) { UsoClient StartScan }"
  pause
  goto main
)
if "%upchoice%"=="3" (
  echo Attempting to install updates (may require modules/not available on all builds)...
  powershell -NoProfile -Command "If (Get-Module -ListAvailable PSWindowsUpdate) { Import-Module PSWindowsUpdate; Get-WindowsUpdate -Install -AcceptAll -AutoReboot } else { wuauclt /detectnow /updatenow }"
  pause
  goto main
)
if "%upchoice%"=="4" (
  echo Rebooting now...
  shutdown /r /t 5
  goto :eof
)
if "%upchoice%"=="5" goto main
goto updates

:: -------------------------
:cleanup
cls
echo Cleanup ^& Browsers submenu
echo 1) Remove temporary files
echo 2) Clear browser caches (Edge/Chrome/IE examples)
echo 3) Remove Windows Store app by name (per-user)
echo 4) Reset Edge/IE policies or settings
echo 5) Back
  set /p cchoice=Choice [1-5]: 
if "%cchoice%"=="1" (
  powershell -NoProfile -Command "Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue; Dism /Online /Cleanup-Image /StartComponentCleanup /Quiet; Write-Host 'Temp cleanup attempted'"
  pause
  goto main
)
if "%cchoice%"=="2" (
  echo Clearing browser caches (user profiles) - examples for Edge and Chrome
  powershell -NoProfile -Command "Remove-Item -Path $env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\* -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path $env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\* -Recurse -Force -ErrorAction SilentlyContinue; RunDll32.exe InetCpl.cpl,ResetIEtoDefaults; Write-Host 'Cleared browser caches (best-effort)';"
  pause
  goto main
)
if "%cchoice%"=="3" (
  set /p appn=Enter Appx package name or partial e.g. Microsoft.MicrosoftEdge: 
  powershell -NoProfile -Command "param($a) Get-AppxPackage -Name $a -ErrorAction SilentlyContinue | Remove-AppxPackage; Get-AppxPackage -AllUsers -Name $a -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers; Write-Host 'Requested removal for' $a" -ArgumentList "%appn%"
  pause
  goto main
)
if "%cchoice%"=="4" (
  powershell -NoProfile -Command "Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -Force -ErrorAction SilentlyContinue; RunDll32.exe InetCpl.cpl,ResetIEtoDefaults; Write-Host 'Cleared Edge policies and reset IE defaults (best-effort)';"
  pause
  goto main
)
if "%cchoice%"=="5" goto main
goto cleanup

:: -------------------------
:roles
cls
echo IIS / DNS / DHCP submenu (server cmdlets required for DNS/DHCP)
echo 1) IIS: List/Start/Stop/Remove sites
echo 2) DNS: List zones / Add or remove record (requires DNS role tools)
echo 3) DHCP: List scopes / Add/Remove scope or reservation (requires DHCP tools)
echo 4) Back
  set /p rchoice=Choice [1-4]: 
if "%rchoice%"=="1" (
  powershell -NoProfile -Command "Import-Module WebAdministration -ErrorAction SilentlyContinue; Get-ChildItem IIS:\Sites | Format-Table Name,State,PhysicalPath -AutoSize"
  echo For start/stop/remove use the main menu -> Services or return here to extend.
  pause
  goto main
)
if "%rchoice%"=="2" (
  set /p z=Enter zone name (leave blank to list all): 
  powershell -NoProfile -Command "param($z) if (Get-Command Get-DnsServerZone -ErrorAction SilentlyContinue) { Get-DnsServerZone | Where-Object { $_.ZoneName -like $z -or $z -eq '' } | Format-Table ZoneName,ZoneType -AutoSize } else { Write-Host 'DNS server cmdlets not present on this host' }" -ArgumentList "%z%"
  pause
  goto main
)
if "%rchoice%"=="3" (
  powershell -NoProfile -Command "If (Get-Command Get-DhcpServerv4Scope -ErrorAction SilentlyContinue) { Get-DhcpServerv4Scope | Format-Table ScopeId,Name,StartRange,EndRange -AutoSize } else { Write-Host 'DHCP server cmdlets not present' }"
  pause
  goto main
)
if "%rchoice%"=="4" goto main
goto roles

:: -------------------------
:repair
cls
echo Security Resets ^& Repair submenu
echo 1) Reset Windows Firewall to default
echo 2) Reset Local Security Policy to default (best-effort)
echo 3) Reset file permissions for Program Files and Windows (best-effort ^& destructive - use with care)
echo 4) Run SFC scan
echo 5) Run DISM repair
echo 6) Back
  set /p repchoice=Choice [1-6]: 
if "%repchoice%"=="1" (
  netsh advfirewall reset
  echo Firewall reset to default
  pause
  goto main
)
if "%repchoice%"=="2" (
  secedit /configure /cfg %windir%\repair\secsetup.inf /db secedit.sdb /overwrite
  echo Attempted to restore local security policy defaults (best-effort)
  pause
  goto main
)
if "%repchoice%"=="3" (
  echo Resetting ACLs under Program Files and Windows (this is destructive). Confirm? (Y/N)
  set /p conf=
  if /I "%conf%"=="Y" (
    icacls "C:\Program Files" /reset /t /c
    icacls "C:\Windows" /reset /t /c
    echo ACL reset attempted
  ) else echo Skipped
  pause
  goto main
)
if "%repchoice%"=="4" (
  sfc /scannow
  pause
  goto main
)
if "%repchoice%"=="5" (
  DISM /Online /Cleanup-Image /RestoreHealth
  pause
  goto main
)
if "%repchoice%"=="6" goto main
goto repair

:: End of file
