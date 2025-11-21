# group-management.ps1
# Functions for managing local group accounts

param(
    [ValidateSet("List", "ListMembers", "AddMember", "RemoveMember")]
    [string]$Action,
    
    [string]$GroupName,
    [string]$UserName
)

function Get-LocalGroupsList {
    if (Get-Command Get-LocalGroup -ErrorAction SilentlyContinue) {
        Get-LocalGroup | Format-Table Name, Description -AutoSize
    } else {
        net localgroup
    }
}

function Get-GroupMembers {
    param([string]$GroupName)
    
    if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) {
        Get-LocalGroupMember -Group $GroupName | Format-Table Name, ObjectClass -AutoSize
    } else {
        net localgroup $GroupName
    }
}

function Add-UserToGroup {
    param(
        [string]$UserName,
        [string]$GroupName
    )
    
    if (Get-Command Add-LocalGroupMember -ErrorAction SilentlyContinue) {
        Add-LocalGroupMember -Group $GroupName -Member $UserName
        Write-Host "Added $UserName to group: $GroupName" -ForegroundColor Green
    } else {
        net localgroup $GroupName $UserName /add
        Write-Host "Added $UserName to group (via net): $GroupName" -ForegroundColor Green
    }
}

function Remove-UserFromGroup {
    param(
        [string]$UserName,
        [string]$GroupName
    )
    
    if (Get-Command Remove-LocalGroupMember -ErrorAction SilentlyContinue) {
        Remove-LocalGroupMember -Group $GroupName -Member $UserName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Removed $UserName from group: $GroupName" -ForegroundColor Green
    } else {
        net localgroup $GroupName $UserName /delete
        Write-Host "Removed $UserName from group (via net): $GroupName" -ForegroundColor Green
    }
}

# Execute based on action parameter
switch ($Action) {
    "List" { Get-LocalGroupsList }
    "ListMembers" { Get-GroupMembers -GroupName $GroupName }
    "AddMember" { Add-UserToGroup -UserName $UserName -GroupName $GroupName }
    "RemoveMember" { Remove-UserFromGroup -UserName $UserName -GroupName $GroupName }
    default { Write-Error "Invalid action. Use -Action with: List, ListMembers, AddMember, RemoveMember" }
}
