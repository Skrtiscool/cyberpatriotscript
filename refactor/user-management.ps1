# user-management.ps1
# Functions for managing local user accounts

param(
    [ValidateSet("List", "Create", "Delete", "Disable", "SetPassword", "ForcePasswordChange", "DisableBuiltIn")]
    [string]$Action,
    
    [string]$Username,
    [string]$Password,
    [string]$Description = "Created by Cyber Patriot"
)

function Get-LocalUsersList {
    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        # Below is all users
        #Get-LocalUser | Select-Object * | Format-Table Name, Enabled, LastLogon, Description -AutoSize
        #  Below is only administrators
        #Get-LocalGroupMember -Name Administrators | Select-Object -ExpandProperty Name

    }
    else {
        net user
    }
}

function New-LocalUserAccount {
    param(
        [string]$UserName,
        [string]$Password,
        [string]$Description
    )
    
    if (Get-Command New-LocalUser -ErrorAction SilentlyContinue) {
        if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
            $secPassword = ConvertTo-SecureString $Password -AsPlainText -Force
            New-LocalUser -Name $UserName -Password $secPassword -FullName $UserName -Description $Description
            Add-LocalGroupMember -Group 'Users' -Member $UserName
            Write-Host "Created user: $UserName" -ForegroundColor Green
        }
        else {
            Write-Host "User already exists: $UserName" -ForegroundColor Yellow
        }
    }
    else {
        net user $UserName $Password /add /comment:$Description
        Write-Host "Created user (via net): $UserName" -ForegroundColor Green
    }
}

function Remove-LocalUserAccount {
    param([string]$UserName)
    
    if (Get-Command Remove-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
            Remove-LocalUser -Name $UserName -Confirm:$false
            Write-Host "Deleted user: $UserName" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $UserName" -ForegroundColor Yellow
        }
    }
    else {
        net user $UserName /delete
        Write-Host "Deleted user (via net): $UserName" -ForegroundColor Green
    }
}

function Disable-LocalUserAccount {
    param([string]$UserName)
    
    if (Get-Command Disable-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
            Disable-LocalUser -Name $UserName
            Write-Host "Disabled user: $UserName" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $UserName" -ForegroundColor Yellow
        }
    }
    else {
        net user $UserName /active:no
        Write-Host "Disabled user (via net): $UserName" -ForegroundColor Green
    }
}

function Set-LocalUserPassword {
    param(
        [string]$UserName,
        [string]$NewPassword
    )
    
    $secPassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    
    if (Get-Command Set-LocalUser -ErrorAction SilentlyContinue) {
        if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
            Set-LocalUser -Name $UserName -Password $secPassword
            Write-Host "Password set for user: $UserName" -ForegroundColor Green
        }
        else {
            Write-Host "User not found: $UserName" -ForegroundColor Yellow
        }
    }
    else {
        net user $UserName $NewPassword
        Write-Host "Password set (via net) for user: $UserName" -ForegroundColor Green
    }
}

function Force-PasswordChangeAtLogon {
    param([string]$UserName)
    
    net user $UserName /logonpasswordchg:yes
    Write-Host "User will be forced to change password at next logon: $UserName" -ForegroundColor Green
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
    "List" { Get-LocalUsersList }
    "Create" { New-LocalUserAccount -UserName $Username -Password $Password -Description $Description }
    "Delete" { Remove-LocalUserAccount -UserName $Username }
    "Disable" { Disable-LocalUserAccount -UserName $Username }
    "SetPassword" { Set-LocalUserPassword -UserName $Username -NewPassword $Password }
    "ForcePasswordChange" { Force-PasswordChangeAtLogon -UserName $Username }
    "DisableBuiltIn" { Disable-BuiltInAccounts }
    default { Write-Error "Invalid action. Use -Action with: List, Create, Delete, Disable, SetPassword, ForcePasswordChange, DisableBuiltIn" }
}
