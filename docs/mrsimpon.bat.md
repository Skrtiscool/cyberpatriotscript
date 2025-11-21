# mrsimpon.bat Documentation

## Overview

`mrsimpon.bat` is a batch script that provides a menu-driven interface for Windows system administration and security hardening, with a focus on password policies and account lockout settings. It combines batch scripting with embedded PowerShell to perform elevated operations.

## Key Features

- **Elevation Handling**: Automatically requests and escalates to administrator privileges
- **Menu-Driven Interface**: Interactive command-line menu system for selecting operations
- **Password & Lockout Policy Management**: Apply, verify, and configure Windows password and account lockout policies
- **Self-Contained**: Writes PowerShell scripts to `%TEMP%` and executes them elevated
- **Policy Export/Verification**: Exports security policies for backup and verification

## Prerequisites

- **Administrator Privileges**: Script requires elevation to perform security operations
- **Windows OS**: Batch scripting and secedit/gpupdate commands (Windows-specific)
- **PowerShell**: Embedded PowerShell commands for advanced operations
- **secedit.exe**: Windows Security Editor (standard on Windows systems)

## Main Menu Options

### 1. Apply Recommended Password & Lockout Policy
Applies comprehensive security policy settings in a single operation.

**What it does:**
- Exports current local security policy to a backup file
- Reads the security policy configuration
- Sets the following recommended values:
  - Minimum Password Length: 14 characters
  - Password Complexity: Enabled (1)
  - Password History Size: 24 previous passwords remembered
  - Clear Text Password: Disabled (0)
  - Maximum Password Age: 60 days
  - Minimum Password Age: 1 day
  - Account Lockout Threshold: 5 failed attempts
  - Lockout Duration: 30 minutes
  - Lockout Observation Window: 30 minutes

**Process:**
1. Exports original policy to `%TEMP%\secpol_orig_<timestamp>.cfg`
2. Creates a backup copy: `%TEMP%\secpol_backup_<timestamp>.cfg`
3. Modifies the policy with recommended values
4. Applies via `secedit /configure`
5. Runs `gpupdate /force` to refresh group policies
6. Verifies applied settings and displays relevant policy entries
7. Stores verification in `%TEMP%\secpol_check_<timestamp>.cfg`

**Output Files:**
- Original policy backup: `secpol_orig_<timestamp>.cfg`
- Safety backup: `secpol_backup_<timestamp>.cfg`
- Modified config: `secpol_new_<timestamp>.cfg`
- Verification config: `secpol_check_<timestamp>.cfg`
- Database file: `secedit_<timestamp>.sdb`

### 2. Verify Current Password & Lockout Settings
Displays the current password and lockout policy settings without modification.

**What it does:**
1. Runs `net accounts` command to show account-related settings
2. Exports current security policy to `%windir%\Temp\secpol_verify.cfg`
3. Extracts and displays the following policy values:
   - MinimumPasswordLength
   - PasswordComplexity
   - PasswordHistorySize
   - ClearTextPassword
   - MaximumPasswordAge
   - MinimumPasswordAge
   - LockoutBadCount
   - ResetLockoutCount
   - LockoutDuration

**Output:** Displayed in console, read-only operation

## Technical Details

### Elevation Mechanism

The script uses `net session` to check for administrator privileges:
```batch
net session >nul 2>&1
if errorlevel 1 (
    echo Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
```

If not elevated, it re-launches itself with `RunAs` verb in PowerShell.

### PowerShell Integration

**Applied Policy Script Structure:**
- Reads policy file with proper encoding detection (UTF-16, UTF-8, or Default)
- Normalizes line endings to `\r\n`
- Parses policy sections (`[System Access]`)
- Modifies key-value pairs using string replacement
- Handles missing sections gracefully (creates them if needed)

**Key Functions:**
- `Get-SectionRange()`: Locates policy sections and their boundaries
- `Set-KeyValueInSection()`: Modifies or adds key-value pairs within sections

### Configuration Files

Policy files are stored in INI format with sections like `[System Access]`. Example:
```ini
[System Access]
MinimumPasswordLength = 14
PasswordComplexity = 1
PasswordHistorySize = 24
ClearTextPassword = 0
MaximumPasswordAge = 60
MinimumPasswordAge = 1
LockoutBadCount = 5
ResetLockoutCount = 30
LockoutDuration = 30
```

## Usage Examples

### Basic Usage

1. Run the script:
   ```batch
   mrsimpon.bat
   ```

2. When prompted for elevation, click "Yes" in the UAC prompt

3. Select option from the menu

### Apply Policy
```
Select an option: 1
```
Then wait for the operation to complete. Files will be saved in `%TEMP%` with timestamps.

### Verify Settings
```
Select an option: 2
```
View current settings without making changes.

## File Locations

All temporary files are created in `%TEMP%` (typically `C:\Users\<username>\AppData\Local\Temp\`)

- **Original Policy**: `secpol_orig_YYYYMMDD-HHMMSS.cfg`
- **Backup Copy**: `secpol_backup_YYYYMMDD-HHMMSS.cfg`
- **Modified Config**: `secpol_new_YYYYMMDD-HHMMSS.cfg`
- **Verification Export**: `secpol_check_YYYYMMDD-HHMMSS.cfg`
- **Database File**: `secedit_YYYYMMDD-HHMMSS.sdb`

## Policy Values Explained

| Setting | Value | Purpose |
|---------|-------|---------|
| **MinimumPasswordLength** | 14 | Requires passwords to be at least 14 characters |
| **PasswordComplexity** | 1 | Requires passwords to contain uppercase, lowercase, digits, and special chars |
| **PasswordHistorySize** | 24 | Prevents reuse of last 24 passwords |
| **ClearTextPassword** | 0 | Disables reversible encryption (passwords not stored in cleartext) |
| **MaximumPasswordAge** | 60 | Forces password change every 60 days |
| **MinimumPasswordAge** | 1 | Prevents immediate password re-use (must wait 1 day between changes) |
| **LockoutBadCount** | 5 | Locks account after 5 failed login attempts |
| **ResetLockoutCount** | 30 | Resets lockout counter if no failed attempts for 30 minutes |
| **LockoutDuration** | 30 | Keeps account locked for 30 minutes after threshold exceeded |

## Error Handling

The script includes several error checks:

- **secedit Export Failure**: Exits if unable to export original policy (checks elevation/secedit availability)
- **PowerShell Script Write Failure**: Returns to menu if unable to write to `%TEMP%`
- **Missing Verification File**: Displays warning if unable to export verification policy

## Troubleshooting

### "secedit export failed" Error
- Ensure script is run as Administrator
- Verify `secedit.exe` is present on the system (standard on Windows)
- Check available disk space in `%TEMP%`

### Changes Not Applied
- Ensure the script completed without errors
- Run "Verify current settings" option to check
- May require system restart in some cases
- Check that no Group Policy Objects (GPO) override these settings

### Cannot Find Temp Files
- Check: `C:\Users\<your-username>\AppData\Local\Temp\`
- Files are prefixed with `secpol_` and `secedit_`
- Include timestamp in filename (format: `YYYYMMDD-HHMMSS`)

## Security Considerations

### Recommended Policy Strengths
- **14-character passwords**: Provides strong entropy while remaining user-friendly
- **Password complexity**: Prevents dictionary attacks
- **24-character history**: Prevents cycle attacks on password reuse
- **60-day maximum age**: Periodic password rotation for security
- **Account lockout**: Prevents brute-force attacks

### Backup Files
The script automatically creates backup files before modification. Keep these for:
- Reverting to previous settings if needed
- Compliance auditing
- Troubleshooting

## Related Commands

- `net accounts`: View/modify account-related settings
- `secedit /export`: Export security policy
- `secedit /configure`: Apply security policy
- `gpupdate /force`: Force group policy refresh
- `auditpol`: View/modify audit policies

## Limitations

- Only modifies local security policy (not GPO in Domain environments)
- Some settings may be overridden by Active Directory GPO
- PowerShell encoding detection supports UTF-16, UTF-8, and default encoding
- Policy files are parsed as INI format; complex configurations may require manual adjustment

## Exit Codes

- **0**: Successful completion or user-initiated exit
- **1**: PowerShell script write failure
- **Other**: Batch error levels (refer to specific error messages)

## Version Information

- **Script Type**: Batch + Embedded PowerShell
- **Compatibility**: Windows 7 SP1+, Windows Server 2008 R2+
- **Tested On**: Windows 10/11, Windows Server 2016/2019/2022
