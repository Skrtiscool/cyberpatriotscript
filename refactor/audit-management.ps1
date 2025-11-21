# audit-management.ps1
# Functions for configuring Windows audit policies

param(
    [ValidateSet("EnableCommon", "ShowStatus")]
    [string]$Action = "EnableCommon"
)

function Enable-CommonAuditCategories {
    Write-Host "Enabling audit policy subcategories..." -ForegroundColor Cyan
    
    $auditCategories = @(
        "Logon",
        "Account Logon",
        "User Account Management",
        "Privilege Use",
        "Process Creation",
        "System"
    )
    
    foreach ($category in $auditCategories) {
        Write-Host "  Enabling: $category" -ForegroundColor Cyan
        auditpol /set /subcategory:"$category" /success:enable /failure:enable 2>$null
    }
    
    Write-Host "Audit policies configured successfully" -ForegroundColor Green
}

function Show-AuditStatus {
    Write-Host "Current audit policy status:" -ForegroundColor Cyan
    auditpol /get /category:*
}

# Execute based on action parameter
switch ($Action) {
    "EnableCommon" { Enable-CommonAuditCategories }
    "ShowStatus" { Show-AuditStatus }
    default { Write-Error "Invalid action. Use: EnableCommon, ShowStatus" }
}
