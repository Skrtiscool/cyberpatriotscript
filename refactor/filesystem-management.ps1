# filesystem-management.ps1
# Functions for managing file system permissions and ACLs

param(
    [ValidateSet("ListACLs", "GrantPermission", "RemovePermission", "RemoveEveryoneFullControl", "SetInheritance", "CreateFolder", "DeletePath")]
    [string]$Action,
    
    [string]$Path,
    [string]$UserName,
    [string]$Permission = "Modify",
    [string]$InheritanceMode = "enable"
)

function Get-RecursiveACLs {
    param([string]$FolderPath)
    
    Write-Host "Listing ACLs for: $FolderPath" -ForegroundColor Cyan
    
    Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "== $($_.FullName)" -ForegroundColor Cyan
        Get-Acl $_.FullName | Format-List
    }
}

function Grant-FolderPermission {
    param(
        [string]$FolderPath,
        [string]$User,
        [string]$PermissionType
    )
    
    Write-Host "Granting $PermissionType to $User on $FolderPath..." -ForegroundColor Cyan
    
    try {
        $acl = Get-Acl $FolderPath
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $User,
            $PermissionType,
            'ContainerInherit,ObjectInherit',
            'None',
            'Allow'
        )
        $acl.AddAccessRule($rule)
        Set-Acl -Path $FolderPath -AclObject $acl
        Write-Host "Permission granted: $PermissionType for $User on $FolderPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to grant permission: $_"
    }
}

function Remove-FolderPermission {
    param(
        [string]$FolderPath,
        [string]$User
    )
    
    Write-Host "Removing permissions for $User from $FolderPath..." -ForegroundColor Cyan
    
    try {
        $acl = Get-Acl $FolderPath
        $rules = $acl.Access | Where-Object { $_.IdentityReference -like "*$User" }
        foreach ($rule in $rules) {
            $acl.RemoveAccessRule($rule)
        }
        Set-Acl -Path $FolderPath -AclObject $acl
        Write-Host "Permissions removed for $User from $FolderPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to remove permission: $_"
    }
}

function Remove-EveryoneFullControl {
    param([string]$RootPath)
    
    Write-Host "Removing 'Everyone' full-control permissions under $RootPath..." -ForegroundColor Cyan
    
    $count = 0
    Get-ChildItem -Path $RootPath -Recurse -Directory -Force | ForEach-Object {
        $acl = Get-Acl $_.FullName
        $rulesToRemove = $acl.Access | Where-Object {
            $_.IdentityReference -match 'Everyone' -and $_.FileSystemRights -match 'FullControl'
        }
        
        foreach ($rule in $rulesToRemove) {
            $acl.RemoveAccessRule($rule)
            $count++
        }
        
        Set-Acl -Path $_.FullName -AclObject $acl
    }
    
    Write-Host "Removed $count 'Everyone' full-control rules under $RootPath" -ForegroundColor Green
}

function Set-FolderInheritance {
    param(
        [string]$FolderPath,
        [string]$Mode
    )
    
    Write-Host "Setting inheritance to $Mode on $FolderPath..." -ForegroundColor Cyan
    
    if ($Mode -eq "enable") {
        icacls $FolderPath /inheritance:e 2>$null
        Write-Host "Inheritance enabled on $FolderPath" -ForegroundColor Green
    } else {
        icacls $FolderPath /inheritance:d 2>$null
        Write-Host "Inheritance disabled on $FolderPath" -ForegroundColor Green
    }
}

function New-DirectoryPath {
    param([string]$FolderPath)
    
    Write-Host "Creating folder: $FolderPath..." -ForegroundColor Cyan
    
    New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
    Write-Host "Folder created: $FolderPath" -ForegroundColor Green
}

function Remove-FilesOrFolder {
    param([string]$PathToDelete)
    
    Write-Host "Deleting: $PathToDelete..." -ForegroundColor Cyan
    
    Remove-Item -Path $PathToDelete -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Deleted: $PathToDelete" -ForegroundColor Green
}

# Execute based on action parameter
switch ($Action) {
    "ListACLs" { Get-RecursiveACLs -FolderPath $Path }
    "GrantPermission" { Grant-FolderPermission -FolderPath $Path -User $UserName -PermissionType $Permission }
    "RemovePermission" { Remove-FolderPermission -FolderPath $Path -User $UserName }
    "RemoveEveryoneFullControl" { Remove-EveryoneFullControl -RootPath $Path }
    "SetInheritance" { Set-FolderInheritance -FolderPath $Path -Mode $InheritanceMode }
    "CreateFolder" { New-DirectoryPath -FolderPath $Path }
    "DeletePath" { Remove-FilesOrFolder -PathToDelete $Path }
    default { Write-Error "Invalid action. Use: ListACLs, GrantPermission, RemovePermission, RemoveEveryoneFullControl, SetInheritance, CreateFolder, DeletePath" }
}
