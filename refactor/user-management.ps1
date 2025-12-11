# user-management.ps1
# Functions for managing local user accounts

param(
    [ValidateSet("ListUsers","ListAdmins", "Create", "Delete", "Disable", "SetPassword", "ForcePasswordChange", "DisableBuiltIn")]
    [string]$Action,
    
    [string]$Username,
    [string]$Password,
    [string]$Description = "Created by Cyber Patriot"
)

function Get-LocalUsersList {
    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        Get-LocalUser | Select-Object * | Format-Table Name, Enabled, LastLogon, Description -AutoSize
    }
    else {
        net user
    }
}

function Get-AdminLists { 
    if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) {
        Get-LocalGroupMember -Name Administrators | Select-Object -ExpandProperty Name
    }
    else {
        net user
    }
}
    

function New-LocalUserAccount {
    param(
        [string]$Username,
        [string]$Password,
        [string]$Description
    )
    
    if (Get-Command New-LocalUser -ErrorAction SilentlyContinue) {
        if (-not (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)) {
            $secPassword = ConvertTo-SecureString $Password -AsPlainText -Force
            New-LocalUser -Name $Username -Password $secPassword -FullName $Username -Description $Description
            Add-LocalGroupMember -Group 'Users' -Member $Username
            Write-Host "Created user: $Username" -ForegroundColor Green
        }
        else {
            Write-Host "User already exists: $Username" -ForegroundColor Yellow
        }
    }
    else {
        net user $Username $Password /add /comment:$Description
        Write-Host "Created user (via net): $Username" -ForegroundColor Green
    }
}

function Remove-LocalUserAccount {
    param([string]$Username)
    
    if (Get-Command Remove-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            Remove-LocalUser -Name $Username -Confirm:$false
            Write-Host "Deleted user: $Username" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $Username" -ForegroundColor Yellow
        }
    }
    else {
        net user $Username /delete
        Write-Host "Deleted user (via net): $Username" -ForegroundColor Green
    }
}

function Disable-LocalUserAccount {
    param([string]$Username)
    
    if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            Disable-LocalUser -Name $Username
            Write-Host "Disabled user: $Username" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $Username" -ForegroundColor Yellow
        }
    }
    else {
        net user $Username /active:no
        Write-Host "Disabled user (via net): $Username" -ForegroundColor Green
    }
}

function Set-LocalUserPassword {
    param(
        [string]$Username,
        [string]$NewPassword
    )
    
    $secPassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    
    if (Get-Command Set-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            Set-LocalUser -Name $Username -Password $secPassword
            Write-Host "Password set for user: $Username" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $Username" -ForegroundColor Yellow
        }
    }
    else {
        net user $Username $NewPassword
        Write-Host "Password set (via net) for user: $Username" -ForegroundColor Green
    }
}

function Force-PasswordChangeAtLogon {
    param([string]$Username)
    
    net user $Username /logonpasswordchg:yes
    Write-Host "User will be forced to change password at next logon: $Username" -ForegroundColor Green
}

function Disable-BuiltInAccounts {
    $builtInAccounts = @('Guest', 'DefaultAccount', 'WDAGUtilityAccount')
    
    foreach ($account in $builtInAccounts) {
        if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) {
            if (Get-LocalUser -Name $account -ErrorAction SilentlyContinue) {
                Disable-LocalUser -Name $account
                Write-Host "Disabled built-in account: $account" -ForegroundColor Green
            }
        }
        else {
            if (net user $account 2>$null) {
                net user $account /active:no
                Write-Host "Disabled built-in account (via net): $account" -ForegroundColor Green
            }
        }
    }
}

# Execute based on action parameter
switch ($Action) {
    "ListUsers" { Get-LocalUsersList }
    "ListAdmins" { Get-AdminLists }
    "Create" { New-LocalUserAccount -UserName $Username -Password $Password -Description $Description }
    "Delete" { Remove-LocalUserAccount -UserName $Username }
    "Disable" { Disable-LocalUserAccount -UserName $Username }
    "SetPassword" { Set-LocalUserPassword -UserName $Username -NewPassword $Password }
    "ForcePasswordChange" { Force-PasswordChangeAtLogon -UserName $Username }
    "DisableBuiltIn" { Disable-BuiltInAccounts }
    default { Write-Error "Invalid action. Use -Action with: List, Create, Delete, Disable, SetPassword, ForcePasswordChange, DisableBuiltIn" }
}
