# firewall-management.ps1
# Functions for managing Windows Firewall settings

param(
    [ValidateSet("Enable", "ListInbound", "CreateRule", "DeleteRule", "BlockAll")]
    [string]$Action,
    
    [string]$RuleName,
    [string]$Port,
    [string]$Protocol = "TCP"
)

function Enable-FirewallProfiles {
    Write-Host "Enabling Firewall for all profiles (Domain, Private, Public)..." -ForegroundColor Cyan
    Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True
    Write-Host "Firewall profiles enabled" -ForegroundColor Green
}

function Get-InboundRulesList {
    Write-Host "Current inbound firewall rules:" -ForegroundColor Cyan
    Get-NetFirewallRule -Direction Inbound | Format-Table DisplayName, Name, Enabled, Profile, Action -AutoSize
}

function New-FirewallInboundRule {
    param(
        [string]$Name,
        [string]$PortNumber,
        [string]$ProtocolType
    )
    
    Write-Host "Creating firewall rule: $Name (Port: $PortNumber, Protocol: $ProtocolType)..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName $Name -Direction Inbound -Action Allow -Protocol $ProtocolType -LocalPort $PortNumber -Profile Domain, Private, Public
    Write-Host "Firewall rule created: $Name" -ForegroundColor Green
}

function Remove-FirewallRule {
    param([string]$Name)
    
    Write-Host "Removing firewall rule: $Name..." -ForegroundColor Cyan
    
    $rule = Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    if ($rule) {
        Set-NetFirewallRule -DisplayName $Name -Enabled False
        Remove-NetFirewallRule -DisplayName $Name -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Firewall rule removed: $Name" -ForegroundColor Green
    } else {
        Write-Host "Rule not found: $Name" -ForegroundColor Yellow
    }
}

function Set-FirewallBlockAll {
    Write-Host "Setting firewall default action to Block for all profiles..." -ForegroundColor Cyan
    Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultInboundAction Block
    Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultOutboundAction Block
    Write-Host "Default inbound/outbound actions set to Block (all profiles)" -ForegroundColor Green
}

# Execute based on action parameter
switch ($Action) {
    "Enable" { Enable-FirewallProfiles }
    "ListInbound" { Get-InboundRulesList }
    "CreateRule" { New-FirewallInboundRule -Name $RuleName -PortNumber $Port -ProtocolType $Protocol }
    "DeleteRule" { Remove-FirewallRule -Name $RuleName }
    "BlockAll" { Set-FirewallBlockAll }
    default { Write-Error "Invalid action. Use: Enable, ListInbound, CreateRule, DeleteRule, BlockAll" }
}
