# features-management.ps1
# Functions for managing Windows features and roles

param(
    [ValidateSet("DisableSMBv1", "DisableTelnet", "DisableFTP", "DisableIIS")]
    [string]$Action
)

function Disable-SMBv1Protocol {
    Write-Host "Disabling SMBv1 protocol..." -ForegroundColor Cyan
    
    if (Get-Command Set-SmbServerConfiguration -ErrorAction SilentlyContinue) {
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
        Write-Host "SMBv1 disabled via PowerShell" -ForegroundColor Green
    }
    
    dism /online /norestart /disable-feature /featurename:SMB1Protocol 2>$null
    Write-Host "SMBv1 disable via DISM completed. Restart may be required." -ForegroundColor Yellow
}

function Disable-TelnetClient {
    Write-Host "Disabling Telnet Client..." -ForegroundColor Cyan
    dism /online /norestart /disable-feature /featurename:TelnetClient 2>$null
    Write-Host "Telnet client disable completed" -ForegroundColor Green
}

function Disable-FTPFeature {
    Write-Host "Disabling FTP features..." -ForegroundColor Cyan
    dism /online /norestart /disable-feature /featurename:IIS-FTPSvc 2>$null
    Write-Host "FTP service disable completed" -ForegroundColor Green
}

function Disable-IISFeature {
    Write-Host "Disabling IIS features..." -ForegroundColor Cyan
    dism /online /norestart /disable-feature /featurename:IIS-WebServerRole 2>$null
    dism /online /norestart /disable-feature /featurename:IIS-FTPSvc 2>$null
    Write-Host "IIS features disable completed. Restart may be required." -ForegroundColor Yellow
}

# Execute based on action parameter
switch ($Action) {
    "DisableSMBv1" { Disable-SMBv1Protocol }
    "DisableTelnet" { Disable-TelnetClient }
    "DisableFTP" { Disable-FTPFeature }
    "DisableIIS" { Disable-IISFeature }
    default { Write-Error "Invalid action. Use: DisableSMBv1, DisableTelnet, DisableFTP, DisableIIS" }
}
