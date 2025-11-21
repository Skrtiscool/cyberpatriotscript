# PowerShell Refactor Modules

This directory contains extracted PowerShell scripts that replace embedded PowerShell commands found throughout the original `mrsimpon.bat` and Toolbox2 scripts.

## Modules Created

### 1. `apply-policy.ps1`

**Purpose**: Apply recommended password and account lockout security policies

**Usage**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "apply-policy.ps1"
```

**Features**:

-   Exports current security policy to backup
-   Detects file encoding (UTF-16, UTF-8, ASCII)
-   Applies recommended policy values
-   Runs secedit configuration
-   Updates group policies via gpupdate
-   Verifies applied settings

**Policy Values Applied**:

-   MinimumPasswordLength: 14
-   PasswordComplexity: 1
-   PasswordHistorySize: 24
-   ClearTextPassword: 0
-   MaximumPasswordAge: 60
-   MinimumPasswordAge: 1
-   LockoutBadCount: 5
-   ResetLockoutCount: 30
-   LockoutDuration: 30

---

### 2. `verify-policy.ps1`

**Purpose**: Display current password and lockout policy settings without modification

**Usage**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "verify-policy.ps1"
```

**Features**:

-   Displays `net accounts` output
-   Exports current security policy
-   Filters and displays relevant policy entries

---

### 3. `user-management.ps1`

**Purpose**: Manage local user accounts

**Usage**:

```powershell
# List all users
powershell -File "user-management.ps1" -Action "List"

# Create user
powershell -File "user-management.ps1" -Action "Create" -Username "newuser" -Password "P@ssw0rd"

# Delete user
powershell -File "user-management.ps1" -Action "Delete" -Username "olduser"

# Disable user
powershell -File "user-management.ps1" -Action "Disable" -Username "user"

# Set password
powershell -File "user-management.ps1" -Action "SetPassword" -Username "user" -Password "NewPass123"

# Force password change at next logon
powershell -File "user-management.ps1" -Action "ForcePasswordChange" -Username "user"

# Disable built-in accounts
powershell -File "user-management.ps1" -Action "DisableBuiltIn"
```

**Actions**:

-   `List` - Display all local users
-   `Create` - Create new local user account
-   `Delete` - Delete a user account
-   `Disable` - Disable a user account
-   `SetPassword` - Set or change user password
-   `ForcePasswordChange` - Force password change at next logon
-   `DisableBuiltIn` - Disable Guest, DefaultAccount, WDAGUtilityAccount

---

### 4. `group-management.ps1`

**Purpose**: Manage local group membership

**Usage**:

```powershell
# List all groups
powershell -File "group-management.ps1" -Action "List"

# List group members
powershell -File "group-management.ps1" -Action "ListMembers" -GroupName "Administrators"

# Add user to group
powershell -File "group-management.ps1" -Action "AddMember" -UserName "user" -GroupName "Administrators"

# Remove user from group
powershell -File "group-management.ps1" -Action "RemoveMember" -UserName "user" -GroupName "Administrators"
```

**Actions**:

-   `List` - Display all local groups
-   `ListMembers` - List members of a group
-   `AddMember` - Add user to group
-   `RemoveMember` - Remove user from group

---

### 5. `policy-management.ps1`

**Purpose**: Configure password and account lockout policies with granular control

**Usage**:

```powershell
# Apply all recommended policies
powershell -File "policy-management.ps1" -Action "ApplyRecommended"

# Set minimum password length
powershell -File "policy-management.ps1" -Action "SetMinLength" -MinLength 14

# Enable password complexity
powershell -File "policy-management.ps1" -Action "EnableComplexity"

# Set password age
powershell -File "policy-management.ps1" -Action "SetPasswordAge" -MaxPasswordAgeDays 60 -MinPasswordAgeDays 1

# Set password history
powershell -File "policy-management.ps1" -Action "SetPasswordHistory" -PasswordHistoryCount 24

# Disable reversible encryption
powershell -File "policy-management.ps1" -Action "DisableReversible"

# Set account lockout
powershell -File "policy-management.ps1" -Action "SetLockout" -LockoutThreshold 5 -LockoutDurationMinutes 30 -LockoutWindowMinutes 30
```

**Actions**:

-   `ApplyRecommended` - Apply all security best practices
-   `SetMinLength` - Set minimum password length
-   `EnableComplexity` - Require password complexity
-   `SetPasswordAge` - Set max/min password age
-   `SetPasswordHistory` - Set password history count
-   `DisableReversible` - Disable cleartext password storage
-   `SetLockout` - Configure account lockout

---

### 6. `audit-management.ps1`

**Purpose**: Configure Windows audit policy settings

**Usage**:

```powershell
# Enable common audit categories
powershell -File "audit-management.ps1" -Action "EnableCommon"

# Show current audit status
powershell -File "audit-management.ps1" -Action "ShowStatus"
```

**Actions**:

-   `EnableCommon` - Enable audit logging for common security events
-   `ShowStatus` - Display current audit policy configuration

**Enabled Audit Categories**:

-   Logon
-   Account Logon
-   User Account Management
-   Privilege Use
-   Process Creation
-   System

---

## Benefits of Refactoring

✅ **Modularity**: Each script has a single responsibility  
✅ **Reusability**: Functions can be called from other scripts  
✅ **Testability**: Scripts can be tested independently  
✅ **Readability**: No complex escaping or line continuations  
✅ **Maintainability**: Clear parameter-based API  
✅ **Version Control**: Easier to track changes in git  
✅ **Documentation**: Self-documenting with help comments

---

## Integration with Batch Scripts

### Using in `cyber-patriot.bat`:

```batch
REM Call policy verification
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\verify-policy.ps1"

REM Call user management
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\user-management.ps1" -Action "List"

REM Call policy configuration
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refactor\policy-management.ps1" -Action "ApplyRecommended"
```

---

## Error Handling

All scripts include error handling for:

-   Missing commands (fallback to `net` commands when modern cmdlets unavailable)
-   Missing files
-   Insufficient permissions
-   secedit failures

Errors are logged with color coding:

-   🟢 **Green**: Success messages
-   🔵 **Cyan**: Informational messages
-   🔴 **Red**: Errors (via Write-Error)
-   🟡 **Yellow**: Warnings

---

### 7. `service-management.ps1`

**Purpose**: Manage Windows services

**Actions**:

-   `List` - Display all services
-   `Start` - Start a service
-   `Stop` - Stop a service
-   `Disable` - Disable and stop a service
-   `SetAutomatic` - Set service to Automatic startup

---

### 8. `features-management.ps1`

**Purpose**: Manage Windows features and roles

**Actions**:

-   `DisableSMBv1` - Disable SMB version 1 protocol
-   `DisableTelnet` - Disable Telnet client
-   `DisableFTP` - Disable FTP service
-   `DisableIIS` - Disable IIS services

---

### 9. `firewall-management.ps1`

**Purpose**: Manage Windows Firewall settings

**Actions**:

-   `Enable` - Enable firewall for all profiles
-   `ListInbound` - List inbound firewall rules
-   `CreateRule` - Create new inbound firewall rule
-   `DeleteRule` - Delete/disable firewall rule
-   `BlockAll` - Block all inbound/outbound by default

---

### 10. `network-management.ps1`

**Purpose**: Manage network adapter configuration

**Actions**:

-   `ListAdapters` - List all network adapters
-   `SetStaticIP` - Configure static IP address
-   `SetDNS` - Configure DNS servers
-   `EnableDHCP` - Enable DHCP on interface
-   `DisableIPv6` - Disable IPv6 protocol

---

### 11. `filesystem-management.ps1`

**Purpose**: Manage file system permissions and ACLs

**Actions**:

-   `ListACLs` - List ACLs recursively
-   `GrantPermission` - Grant user permissions on folder
-   `RemovePermission` - Remove user permissions
-   `RemoveEveryoneFullControl` - Remove Everyone full-control entries
-   `SetInheritance` - Enable/disable permission inheritance
-   `CreateFolder` - Create new folder
-   `DeletePath` - Delete file or folder

---

### 12. `startup-management.ps1`

**Purpose**: Manage startup items and scheduled tasks

**Actions**:

-   `ListTasks` - List scheduled tasks
-   `DisableTask` - Disable scheduled task
-   `DeleteTask` - Delete scheduled task
-   `ClearStartupFolders` - Clear startup shortcuts
-   `ListRunKeys` - Display Run registry keys

---

### 13. `updates-management.ps1`

**Purpose**: Manage Windows updates and system reboots

**Actions**:

-   `EnableUpdateService` - Enable Windows Update service
-   `CheckUpdates` - Check for available updates
-   `InstallUpdates` - Install available updates
-   `Reboot` - Reboot system with delay

---

### 14. `cleanup-management.ps1`

**Purpose**: System cleanup and browser management

**Actions**:

-   `RemoveTempFiles` - Remove temporary files
-   `ClearBrowserCaches` - Clear browser cache data
-   `RemoveAppxPackage` - Remove Windows Store app
-   `ResetBrowserPolicies` - Reset browser policies and settings

---

## Prerequisites

-   **Windows OS**: Windows 7 SP1 or later
-   **PowerShell**: 3.0 or later (included in Windows 8+)
-   **Administrator Privileges**: Required for most operations
-   **secedit.exe**: Standard Windows utility
