# CyberPatriot Test Suite

Comprehensive unit tests for all refactored PowerShell modules in the CyberPatriot refactoring project.

## Overview

This test suite validates the structure, functionality, and correctness of all 14 PowerShell modules extracted from the original `mrsimpon.bat` script. Tests use pattern-based validation to ensure modules contain required functions, parameters, and command implementations without requiring elevated privileges or actual script execution.

## Test Coverage

### Core Security Modules (6 tests)

-   **Test-ApplyPolicy.ps1**: Validates policy application functionality

    -   Policy hashtable definitions
    -   Encoding detection (UTF-16, UTF-8, ASCII)
    -   Secedit integration
    -   Policy file creation and application

-   **Test-VerifyPolicy.ps1**: Validates policy verification functionality

    -   Secedit export command
    -   Policy verification logic
    -   Output formatting with color-coding
    -   Display functions

-   **Test-AuditManagement.ps1**: Validates audit logging configuration

    -   Audit category definitions (Logon, Account Logon, User Account Management, etc.)
    -   Auditpol command usage
    -   Success/failure event logging
    -   Audit status display

-   **Test-UserManagement.ps1**: Validates user account operations

    -   User action definitions (List, Create, Delete, Disable, SetPassword, ForcePasswordChange, DisableBuiltIn)
    -   Function implementations
    -   Parameter validation
    -   Error handling and fallbacks

-   **Test-GroupManagement.ps1**: Validates group management operations

    -   Group action definitions (List, ListMembers, AddMember, RemoveMember)
    -   PowerShell cmdlet usage (Get-LocalGroup, Add-LocalGroupMember, etc.)
    -   Fallback net command availability
    -   Function definitions

-   **Test-PolicyManagement.ps1**: Validates security policy configuration
    -   Policy action definitions (7 total)
    -   Default parameter values
    -   Secedit command integration
    -   Policy value constants

### System Administration Modules (8 tests)

-   **Test-ServiceManagement.ps1**: Validates Windows service operations

    -   Service action definitions (List, Start, Stop, Disable, SetAutomatic)
    -   Get-Service, Start-Service, Stop-Service, Set-Service cmdlets
    -   Service parameters (StartupType, DisplayName)
    -   Fallback net commands

-   **Test-FeaturesManagement.ps1**: Validates Windows feature management

    -   Feature disable actions (SMBv1, Telnet, FTP, IIS)
    -   DISM command usage and parameters
    -   Feature name references
    -   Error handling

-   **Test-FirewallManagement.ps1**: Validates firewall configuration

    -   Firewall action definitions (Enable, ListInbound, CreateRule, DeleteRule, BlockAll)
    -   Net-Firewall cmdlets (Set-NetFirewallProfile, Get-NetFirewallRule, New-NetFirewallRule, Remove-NetFirewallRule)
    -   Firewall profiles (Domain, Private, Public)
    -   Rule parameters (DisplayName, Direction, Protocol, Action, LocalPort)

-   **Test-NetworkManagement.ps1**: Validates network configuration

    -   Network action definitions (ListAdapters, SetStaticIP, SetDNS, EnableDHCP, DisableIPv6)
    -   Net-Adapter cmdlets (Get-NetAdapter, New-NetIPAddress, Set-DnsClientServerAddress, Set-NetIPInterface)
    -   Network parameters (InterfaceAlias, IPAddress, PrefixLength, DefaultGateway, ServerAddresses)
    -   IPv6 disabling logic

-   **Test-FilesystemManagement.ps1**: Validates filesystem and ACL operations

    -   Filesystem action definitions (7 total)
    -   ACL cmdlets (Get-Acl, Set-Acl, New-Object FileSystemAccessRule)
    -   Filesystem parameters (Path, Identity, FileSystemRights, AccessControlType, Allow, Deny)
    -   "Everyone" Full Control removal logic
    -   Inheritance propagation handling

-   **Test-StartupManagement.ps1**: Validates startup and task management

    -   Startup action definitions (5 total)
    -   Scheduled task cmdlets (Get-ScheduledTask, Disable-ScheduledTask, Unregister-ScheduledTask)
    -   Registry path references (HKCU Run, HKLM Run, Startup folders)
    -   Startup folder path handling

-   **Test-UpdatesManagement.ps1**: Validates Windows Update management

    -   Update action definitions (4 total)
    -   Windows Update service references (wuauserv)
    -   Update check and installation logic
    -   System reboot logic (Restart-Computer)

-   **Test-CleanupManagement.ps1**: Validates system cleanup operations
    -   Cleanup action definitions (4 total)
    -   Temporary file handling ($env:TEMP, $env:WINDIR)
    -   Browser cache references (Chrome, Edge, Firefox, Internet Explorer)
    -   AppX package handling (Get-AppxPackage, Remove-AppxPackage)
    -   Registry policy reset logic

## Running Tests

### Run All Tests

```powershell
.\Run-AllTests.ps1
```

### Run Specific Module Tests

```powershell
.\Test-ApplyPolicy.ps1
.\Test-UserManagement.ps1
.\Test-FirewallManagement.ps1
# ... etc
```

### Run with Verbose Output

```powershell
.\Run-AllTests.ps1 -Verbose
.\Test-UserManagement.ps1 -Verbose
```

### Run with Error Stopping

```powershell
.\Run-AllTests.ps1 -StopOnError
```

## Test Structure

Each test file follows a consistent pattern:

```powershell
# 1. File Existence Validation
Test-FileExists

# 2. Valid Actions Validation
Test-ValidActions
# Checks that all expected action values are defined in ValidateSet

# 3. Required Functions Validation
Test-RequiredFunctions
# Validates presence of all expected function definitions

# 4. Command/Cmdlet Validation
Test-[ServiceType]Cmdlets
# Verifies PowerShell cmdlets are used correctly

# 5. Parameter Validation
Test-[ServiceType]Parameters
# Checks for required parameters and options

# 6. Domain-Specific Tests
Test-[SpecificFeature]
# Custom tests for module-specific functionality
# Examples: encoding detection, fallback commands, policy values, etc.

# 7. Results Reporting
# Color-coded output (Green ✓ for pass, Red ✗ for fail)
# Summary: "Results: X/Y tests passed"
```

## Test Output Format

Each test displays results with color-coded output:

-   **Green (✓)**: Test passed - component found and validated
-   **Red (✗)**: Test failed - required component missing or incorrect
-   **Cyan**: Section headers and category labels
-   **White**: Informational messages

Example output:

```
======================================
Testing: user-management.ps1
======================================

Testing valid actions...
  ✓ Action defined: List
  ✓ Action defined: Create
  ✓ Action defined: Delete
  ✓ Action defined: Disable
  ✓ Action defined: SetPassword
  ✓ Action defined: ForcePasswordChange
  ✓ Action defined: DisableBuiltIn

Testing function definitions...
  ✓ Function defined: List-Users
  ✓ Function defined: Create-User
  ✓ Function defined: Delete-User
  ...

======================================
Results: 12/12 tests passed
======================================
```

## Validation Approach

Tests use **pattern-based validation** rather than execution-based testing:

### Advantages

✓ No elevated privileges required
✓ Safe to run on any system
✓ Fast execution
✓ Portable across environments
✓ Clear pass/fail reporting
✓ Easy to extend and maintain

### Method

-   Read script file content with `Get-Content -Raw`
-   Use PowerShell `-like` operator for pattern matching
-   Check for presence of:
    -   Function definitions
    -   ValidateSet action values
    -   Required cmdlets and commands
    -   Parameter definitions
    -   Domain-specific elements (encoding, registry paths, etc.)

## Module Testing Matrix

| Module                | Test File                 | Actions | Functions | Domain Tests                |
| --------------------- | ------------------------- | ------- | --------- | --------------------------- |
| apply-policy          | Test-ApplyPolicy          | 9       | 1         | Encoding, Hashtable         |
| verify-policy         | Test-VerifyPolicy         | N/A     | 1         | Secedit export              |
| audit-management      | Test-AuditManagement      | 2       | 2         | Categories, Commands        |
| user-management       | Test-UserManagement       | 7       | 7         | Parameters, Fallbacks       |
| group-management      | Test-GroupManagement      | 4       | 4         | Cmdlets, Fallbacks          |
| policy-management     | Test-PolicyManagement     | 7       | 7         | Defaults, Values            |
| service-management    | Test-ServiceManagement    | 5       | 5         | Cmdlets, Fallbacks          |
| features-management   | Test-FeaturesManagement   | 4       | 4         | DISM, Features              |
| firewall-management   | Test-FirewallManagement   | 5       | 5         | Profiles, Rules             |
| network-management    | Test-NetworkManagement    | 5       | 5         | Adapters, IPv6              |
| filesystem-management | Test-FilesystemManagement | 7       | 7         | ACLs, Everyone, Inheritance |
| startup-management    | Test-StartupManagement    | 5       | 5         | Tasks, Registry             |
| updates-management    | Test-UpdatesManagement    | 4       | 4         | Services, Reboot            |
| cleanup-management    | Test-CleanupManagement    | 4       | 4         | Temp, Browsers, AppX        |

## Expected Test Results

**Total Test Files**: 14
**Total Test Functions**: 85+
**Expected Pass Rate**: 100% (all components present and correctly defined)

If any test fails, it indicates a missing or incorrectly defined component in the corresponding PowerShell module. Review the test output to identify the specific missing element.

## Integration with CI/CD

These tests are suitable for continuous integration pipelines:

```yaml
# Example: GitHub Actions
- name: Run CyberPatriot Test Suite
  run: powershell -File tests/Run-AllTests.ps1

# Example: Azure Pipelines
- task: PowerShell@2
  inputs:
      targetType: "filePath"
      filePath: "$(System.DefaultWorkingDirectory)/tests/Run-AllTests.ps1"
```

## Troubleshooting

### Test Returns "File not found"

-   Verify the `refactor/` directory exists in the workspace root
-   Ensure all 14 PowerShell modules are present in `refactor/` directory
-   Check file paths are correct relative to test location

### Test Returns "Action missing"

-   Review the corresponding PowerShell module
-   Verify ValidateSet parameter includes expected action values
-   Check for typos in action names

### Test Returns "Function missing"

-   Review the corresponding PowerShell module
-   Verify all expected functions are defined with `function` keyword
-   Ensure function names match exactly

### Test Returns "Cmdlet missing"

-   Verify PowerShell module uses correct cmdlet names
-   Check for typos or case sensitivity issues
-   Ensure cmd commands or PowerShell cmdlets are present

## Future Enhancements

Potential test suite expansions:

-   [ ] Execution-based tests with mocked elevation
-   [ ] Parameter validation tests
-   [ ] Error handling scenario tests
-   [ ] Performance/resource usage tests
-   [ ] Integration tests (cyber-patriot.bat menu validation)
-   [ ] Acceptance tests (end-to-end workflows)
-   [ ] Security validation tests (permission checking, etc.)

## Notes

-   Tests are read-only; they do not modify any files
-   Tests do not require administrative privileges
-   Tests can be run safely in restricted environments
-   All tests are idempotent and can be run multiple times
-   Test files are standalone and can be executed individually or together

## Support

For issues or questions about the test suite:

1. Review the test output for specific failures
2. Check the corresponding PowerShell module for the indicated missing element
3. Refer to the `refactor/README.md` for module documentation
4. Review `REFACTOR_SUMMARY.md` for overall refactoring context
