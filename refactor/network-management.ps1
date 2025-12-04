## TODO: This whole this thing is broken
# network-management.ps1
# Functions for managing network adapter settings

param(
    [ValidateSet("ListAdapters", "SetStaticIP", "SetDNS", "EnableDHCP", "DisableIPv6")]
    [string]$Action,
    
    [string]$InterfaceAlias,
    [string]$IPAddress,
    [int]$PrefixLength = 24,
    [string]$Gateway,
    [string]$DNSServers
)

function Get-NetworkAdaptersList {
    Write-Host "Network adapters:" -ForegroundColor Cyan
    Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, MacAddress -AutoSize
}

function Set-StaticIPAddress {
    param(
        [string]$Alias,
        [string]$IP,
        [int]$Prefix,
        [string]$GW
    )
    
    Write-Host "Setting static IP on $Alias..." -ForegroundColor Cyan
    
    try {
        New-NetIPAddress -InterfaceAlias $Alias -IPAddress $IP -PrefixLength $Prefix -DefaultGateway $GW
        Write-Host "Static IP configured: $IP/$Prefix on $Alias" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to set static IP: $_"
    }
}

function Set-DNSServers {
    param(
        [string]$Alias,
        [string]$DNSList
    )
    
    Write-Host "Setting DNS servers on $Alias..." -ForegroundColor Cyan
    
    $servers = @($DNSList -split ',')
    Set-DnsClientServerAddress -InterfaceAlias $Alias -ServerAddresses $servers
    Write-Host "DNS configured on $Alias" -ForegroundColor Green
}

function Enable-DHCPOnInterface {
    param([string]$Alias)
    
    Write-Host "Enabling DHCP on $Alias..." -ForegroundColor Cyan
    
    Set-NetIPInterface -InterfaceAlias $Alias -Dhcp Enabled
    Set-DnsClientServerAddress -InterfaceAlias $Alias -ResetServerAddresses
    Write-Host "DHCP enabled on $Alias" -ForegroundColor Green
}

function Disable-IPv6Binding {
    param([string]$Alias)
    
    Write-Host "Disabling IPv6 on $Alias..." -ForegroundColor Cyan
    
    Disable-NetAdapterBinding -Name $Alias -ComponentID ms_tcpip6
    Write-Host "IPv6 disabled on $Alias" -ForegroundColor Green
}

# Execute based on action parameter
switch ($Action) {
    "ListAdapters" { Get-NetworkAdaptersList }
    "SetStaticIP" { Set-StaticIPAddress -Alias $InterfaceAlias -IP $IPAddress -Prefix $PrefixLength -GW $Gateway }
    "SetDNS" { Set-DNSServers -Alias $InterfaceAlias -DNSList $DNSServers }
    "EnableDHCP" { Enable-DHCPOnInterface -Alias $InterfaceAlias }
    "DisableIPv6" { Disable-IPv6Binding -Alias $InterfaceAlias }
    default { Write-Error "Invalid action. Use: ListAdapters, SetStaticIP, SetDNS, EnableDHCP, DisableIPv6" }
}
