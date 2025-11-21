@echo off
REM cyber-patriot.bat - Refactored Windows security hardening tool
REM Uses external PowerShell scripts from the refactor directory
REM Run as Administrator

:: Require elevation - relaunch self as admin if needed
net session >nul 2>&1
if errorlevel 1 (
    echo Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ================================================
echo   Cyber Patriot - Security Hardening Toolkit
echo ================================================
echo 1: User Accounts
echo 2: Groups
echo 3: Password ^& Lockout Policies
echo 4: Auditing
echo 5: Services
echo 6: Features ^& Roles
echo 7: Firewall
echo 8: Network
echo 9: File System ^& ACLs
echo 10: Startup ^& Scheduled Tasks
echo 11: Updates ^& Reboot
echo 12: Cleanup ^& Browsers
echo 0: Exit
echo.
set /p choice=Select an option: 

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
if "%choice%"=="0" goto :eof

echo Invalid choice. Press any key to continue...
pause >nul
goto menu

:user_accounts
cls
echo User Accounts submenu
echo 1: List local users
echo 2: Create user
echo 3: Delete user
echo 4: Disable user
echo 5: Set user password
echo 6: Force password change at next logon
echo 7: Disable built-in accounts (Guest, DefaultAccount, WDAGUtilityAccount)
echo 8: Back
set /p uchoice=Choice [1-8]: 
if "%uchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "List"
  pause
  goto menu
)
if "%uchoice%"=="2" (
  set /p uname=Enter new username: 
  set /p upass=Enter password (visible): 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "Create" -Username "%uname%" -Password "%upass%"
  pause
  goto menu
)
if "%uchoice%"=="3" (
  set /p deluser=Enter username to delete: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "Delete" -Username "%deluser%"
  pause
  goto menu
)
if "%uchoice%"=="4" (
  set /p duser=Enter username to disable: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "Disable" -Username "%duser%"
  pause
  goto menu
)
if "%uchoice%"=="5" (
  set /p spuser=Enter username to set password for: 
  set /p spass=Enter new password (visible): 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "SetPassword" -Username "%spuser%" -Password "%spass%"
  pause
  goto menu
)
if "%uchoice%"=="6" (
  set /p fuser=Enter username to force change at next logon: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "ForcePasswordChange" -Username "%fuser%"
  pause
  goto menu
)
if "%uchoice%"=="7" (
  echo Disabling built-in accounts...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "DisableBuiltIn"
  pause
  goto menu
)
if "%uchoice%"=="8" goto menu
goto user_accounts

:groups
cls
echo Groups submenu
echo 1: List local groups
echo 2: List members of a group
echo 3: Add user to a group
echo 4: Remove user from a group
echo 5: Back
set /p gchoice=Choice [1-5]: 
if "%gchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\group-management.ps1" -Action "List"
  pause
  goto menu
)
if "%gchoice%"=="2" (
  set /p gname=Enter group name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\group-management.ps1" -Action "ListMembers" -GroupName "%gname%"
  pause
  goto menu
)
if "%gchoice%"=="3" (
  set /p gu=Enter username to add: 
  set /p gg=Enter group name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\group-management.ps1" -Action "AddMember" -UserName "%gu%" -GroupName "%gg%"
  pause
  goto menu
)
if "%gchoice%"=="4" (
  set /p rgu=Enter username to remove: 
  set /p rgg=Enter group name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\group-management.ps1" -Action "RemoveMember" -UserName "%rgu%" -GroupName "%rgg%"
  pause
  goto menu
)
if "%gchoice%"=="5" goto menu
goto groups

:policies
cls
echo Password ^& Lockout Policies submenu
echo 1: Apply recommended password ^& lockout policy (secure defaults)
echo 2: Set minimum password length
echo 3: Enable password complexity
echo 4: Set max/min password age
echo 5: Set password history length
echo 6: Disable reversible encryption
echo 7: Set account lockout threshold/duration/window
echo 8: Verify current settings
echo 9: Back
set /p pchoice=Choice [1-9]: 
if "%pchoice%"=="1" (
  echo Applying recommended password and lockout policy...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "ApplyRecommended"
  pause
  goto menu
)
if "%pchoice%"=="2" (
  set /p minlen=Enter minimum password length e.g. 14: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "SetMinLength" -MinLength %minlen%
  pause
  goto menu
)
if "%pchoice%"=="3" (
  echo Enabling password complexity (local policy)...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "EnableComplexity"
  pause
  goto menu
)
if "%pchoice%"=="4" (
  set /p maxdays=Enter maximum password age in days e.g. 60: 
  set /p mindays=Enter minimum password age in days e.g. 1: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "SetPasswordAge" -MaxPasswordAgeDays %maxdays% -MinPasswordAgeDays %mindays%
  pause
  goto menu
)
if "%pchoice%"=="5" (
  set /p history=Enter password history count e.g. 24: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "SetPasswordHistory" -PasswordHistoryCount %history%
  pause
  goto menu
)
if "%pchoice%"=="6" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "DisableReversible"
  pause
  goto menu
)
if "%pchoice%"=="7" (
  set /p thr=Enter lockout threshold (invalid attempts) e.g. 5: 
  set /p dur=Enter lockout duration in minutes e.g. 30: 
  set /p win=Enter lockout observation window in minutes e.g. 30: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "SetLockout" -LockoutThreshold %thr% -LockoutDurationMinutes %dur% -LockoutWindowMinutes %win%
  pause
  goto menu
)
if "%pchoice%"=="8" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\verify-policy.ps1"
  pause
  goto menu
)
if "%pchoice%"=="9" goto menu
goto policies

:auditing
cls
echo Auditing submenu
echo 1: Enable common audit categories (Logon, Account Logon, Account Management, Privilege Use, Process Tracking, System)
echo 2: Show audit policy status
echo 3: Back
set /p achoice=Choice [1-3]: 
if "%achoice%"=="1" (
  echo Enabling selected audit subcategories...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\audit-management.ps1" -Action "EnableCommon"
  pause
  goto menu
)
if "%achoice%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\audit-management.ps1" -Action "ShowStatus"
  pause
  goto menu
)
if "%achoice%"=="3" goto menu
goto auditing

:services
cls
echo Services submenu
echo 1: List services
echo 2: Start a service
echo 3: Stop a service
echo 4: Disable a service
echo 5: Set service to Automatic
echo 6: Back
set /p schoice=Choice [1-6]: 
if "%schoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\service-management.ps1" -Action "List"
  pause
  goto menu
)
if "%schoice%"=="2" (
  set /p svc=Enter service name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\service-management.ps1" -Action "Start" -ServiceName "%svc%"
  pause
  goto menu
)
if "%schoice%"=="3" (
  set /p svcstop=Enter service name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\service-management.ps1" -Action "Stop" -ServiceName "%svcstop%"
  pause
  goto menu
)
if "%schoice%"=="4" (
  set /p svcd=Enter service name to disable: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\service-management.ps1" -Action "Disable" -ServiceName "%svcd%"
  pause
  goto menu
)
if "%schoice%"=="5" (
  set /p svca=Enter service name to set Automatic: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\service-management.ps1" -Action "SetAutomatic" -ServiceName "%svca%"
  pause
  goto menu
)
if "%schoice%"=="6" goto menu
goto services

:features
cls
echo Features ^& Roles submenu
echo 1: Disable SMBv1
echo 2: Disable Telnet Client
echo 3: Disable FTP
echo 4: Disable IIS
echo 5: Back
set /p fchoice=Choice [1-5]: 
if "%fchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\features-management.ps1" -Action "DisableSMBv1"
  pause
  goto menu
)
if "%fchoice%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\features-management.ps1" -Action "DisableTelnet"
  pause
  goto menu
)
if "%fchoice%"=="3" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\features-management.ps1" -Action "DisableFTP"
  pause
  goto menu
)
if "%fchoice%"=="4" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\features-management.ps1" -Action "DisableIIS"
  pause
  goto menu
)
if "%fchoice%"=="5" goto menu
goto features

:firewall
cls
echo Firewall submenu
echo 1: Enable Firewall (all profiles)
echo 2: List inbound rules
echo 3: Create inbound rule
echo 4: Delete rule
echo 5: Block all inbound/outbound
echo 6: Back
set /p fwchoice=Choice [1-6]: 
if "%fwchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\firewall-management.ps1" -Action "Enable"
  pause
  goto menu
)
if "%fwchoice%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\firewall-management.ps1" -Action "ListInbound"
  pause
  goto menu
)
if "%fwchoice%"=="3" (
  set /p rname=Enter rule name (display): 
  set /p rport=Enter local TCP port: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\firewall-management.ps1" -Action "CreateRule" -RuleName "%rname%" -Port "%rport%"
  pause
  goto menu
)
if "%fwchoice%"=="4" (
  set /p rulename=Enter rule DisplayName to delete: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\firewall-management.ps1" -Action "DeleteRule" -RuleName "%rulename%"
  pause
  goto menu
)
if "%fwchoice%"=="5" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\firewall-management.ps1" -Action "BlockAll"
  pause
  goto menu
)
if "%fwchoice%"=="6" goto menu
goto firewall

:network
cls
echo Network submenu
echo 1: List network adapters
echo 2: Set static IPv4 address
echo 3: Set IPv4 DNS server
echo 4: Enable DHCP on interface
echo 5: Disable IPv6 on interface
echo 6: Back
set /p nchoice=Choice [1-6]: 
if "%nchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\network-management.ps1" -Action "ListAdapters"
  pause
  goto menu
)
if "%nchoice%"=="2" (
  set /p iface=Enter Interface Alias: 
  set /p ip=Enter IPv4 address: 
  set /p prefix=Enter Prefix length: 
  set /p gw=Enter Gateway: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\network-management.ps1" -Action "SetStaticIP" -InterfaceAlias "%iface%" -IPAddress "%ip%" -PrefixLength %prefix% -Gateway "%gw%"
  pause
  goto menu
)
if "%nchoice%"=="3" (
  set /p ifdns=Enter Interface Alias: 
  set /p dns=Enter DNS server(s) comma-separated: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\network-management.ps1" -Action "SetDNS" -InterfaceAlias "%ifdns%" -DNSServers "%dns%"
  pause
  goto menu
)
if "%nchoice%"=="4" (
  set /p dhcpif=Enter Interface Alias: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\network-management.ps1" -Action "EnableDHCP" -InterfaceAlias "%dhcpif%"
  pause
  goto menu
)
if "%nchoice%"=="5" (
  set /p v6if=Enter Interface Alias: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\network-management.ps1" -Action "DisableIPv6" -InterfaceAlias "%v6if%"
  pause
  goto menu
)
if "%nchoice%"=="6" goto menu
goto network

:filesystem
cls
echo File System ^& ACLs submenu
echo 1: List ACLs for a directory
echo 2: Grant permissions to user
echo 3: Remove permissions from user
echo 4: Remove Everyone full-control
echo 5: Set NTFS inheritance
echo 6: Create folder
echo 7: Delete folder/file
echo 8: Back
set /p fschoice=Choice [1-8]: 
if "%fschoice%"=="1" (
  set /p fpath=Enter folder path: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "ListACLs" -Path "%fpath%"
  pause
  goto menu
)
if "%fschoice%"=="2" (
  set /p grantpath=Enter folder path: 
  set /p guser=Enter user (DOMAIN\User): 
  set /p gperm=Enter permission (e.g., Modify): 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "GrantPermission" -Path "%grantpath%" -UserName "%guser%" -Permission "%gperm%"
  pause
  goto menu
)
if "%fschoice%"=="3" (
  set /p rpath=Enter folder path: 
  set /p ruser=Enter user to remove: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "RemovePermission" -Path "%rpath%" -UserName "%ruser%"
  pause
  goto menu
)
if "%fschoice%"=="4" (
  set /p everyone_path=Enter root folder to process: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "RemoveEveryoneFullControl" -Path "%everyone_path%"
  pause
  goto menu
)
if "%fschoice%"=="5" (
  set /p inherpath=Enter folder path: 
  set /p inher=Enable inheritance? (enable/disable): 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "SetInheritance" -Path "%inherpath%" -InheritanceMode "%inher%"
  pause
  goto menu
)
if "%fschoice%"=="6" (
  set /p newfolder=Enter folder path to create: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "CreateFolder" -Path "%newfolder%"
  pause
  goto menu
)
if "%fschoice%"=="7" (
  set /p todel=Enter file/folder path to delete: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\filesystem-management.ps1" -Action "DeletePath" -Path "%todel%"
  pause
  goto menu
)
if "%fschoice%"=="8" goto menu
goto filesystem

:startup
cls
echo Startup ^& Scheduled Tasks submenu
echo 1: List scheduled tasks
echo 2: Disable scheduled task
echo 3: Delete scheduled task
echo 4: Clear startup folders
echo 5: List Run registry keys
echo 6: Back
set /p stchoice=Choice [1-6]: 
if "%stchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\startup-management.ps1" -Action "ListTasks"
  pause
  goto menu
)
if "%stchoice%"=="2" (
  set /p tname=Enter scheduled task name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\startup-management.ps1" -Action "DisableTask" -TaskName "%tname%"
  pause
  goto menu
)
if "%stchoice%"=="3" (
  set /p tdname=Enter scheduled task name to delete: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\startup-management.ps1" -Action "DeleteTask" -TaskName "%tdname%"
  pause
  goto menu
)
if "%stchoice%"=="4" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\startup-management.ps1" -Action "ClearStartupFolders"
  pause
  goto menu
)
if "%stchoice%"=="5" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\startup-management.ps1" -Action "ListRunKeys"
  pause
  goto menu
)
if "%stchoice%"=="6" goto menu
goto startup

:updates
cls
echo Updates ^& Reboot submenu
echo 1: Enable Windows Update service
echo 2: Check for updates
echo 3: Install available updates
echo 4: Reboot now
echo 5: Back
set /p upchoice=Choice [1-5]: 
if "%upchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\updates-management.ps1" -Action "EnableUpdateService"
  pause
  goto menu
)
if "%upchoice%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\updates-management.ps1" -Action "CheckUpdates"
  pause
  goto menu
)
if "%upchoice%"=="3" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\updates-management.ps1" -Action "InstallUpdates"
  pause
  goto menu
)
if "%upchoice%"=="4" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\updates-management.ps1" -Action "Reboot" -RebootDelaySeconds 5
  goto :eof
)
if "%upchoice%"=="5" goto menu
goto updates

:cleanup
cls
echo Cleanup ^& Browsers submenu
echo 1: Remove temporary files
echo 2: Clear browser caches
echo 3: Remove Windows Store app
echo 4: Reset browser policies
echo 5: Back
set /p cchoice=Choice [1-5]: 
if "%cchoice%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\cleanup-management.ps1" -Action "RemoveTempFiles"
  pause
  goto menu
)
if "%cchoice%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\cleanup-management.ps1" -Action "ClearBrowserCaches"
  pause
  goto menu
)
if "%cchoice%"=="3" (
  set /p appn=Enter Appx package name: 
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\cleanup-management.ps1" -Action "RemoveAppxPackage" -PackageName "%appn%"
  pause
  goto menu
)
if "%cchoice%"=="4" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\cleanup-management.ps1" -Action "ResetBrowserPolicies"
  pause
  goto menu
)
if "%cchoice%"=="5" goto menu
goto cleanup
