# startup-management.ps1
# Functions for managing startup items and scheduled tasks

param(
    [ValidateSet("ListTasks", "DisableTask", "DeleteTask", "ClearStartupFolders", "ListRunKeys")]
    [string]$Action,
    
    [string]$TaskName
)

function Get-ScheduledTasksList {
    Write-Host "Current scheduled tasks:" -ForegroundColor Cyan
    Get-ScheduledTask | Format-Table TaskName, State, Actions -AutoSize
}

function Disable-ScheduledTaskByName {
    param([string]$Name)
    
    Write-Host "Disabling scheduled task: $Name..." -ForegroundColor Cyan
    
    if (Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue) {
        Disable-ScheduledTask -TaskName $Name
        Write-Host "Scheduled task disabled: $Name" -ForegroundColor Green
    } else {
        schtasks /Change /TN $Name /Disable 2>$null
        Write-Host "Attempted to disable task (via schtasks): $Name" -ForegroundColor Yellow
    }
}

function Delete-ScheduledTaskByName {
    param([string]$Name)
    
    Write-Host "Deleting scheduled task: $Name..." -ForegroundColor Cyan
    
    if (Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $Name -Confirm:$false
        Write-Host "Scheduled task deleted: $Name" -ForegroundColor Green
    } else {
        schtasks /Delete /TN $Name /F 2>$null
        Write-Host "Attempted to delete task (via schtasks): $Name" -ForegroundColor Yellow
    }
}

function Clear-StartupFolders {
    Write-Host "Clearing startup folders..." -ForegroundColor Cyan
    
    $currentUserStartup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $allUsersStartup = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
    
    Remove-Item -Path "$currentUserStartup\*" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$allUsersStartup\*" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Startup folders cleared (shortcuts removed)" -ForegroundColor Green
}

function Show-RunKeys {
    Write-Host "Current Run registry keys:" -ForegroundColor Cyan
    Write-Host "`n=== HKCU:\Software\Microsoft\Windows\CurrentVersion\Run ===" -ForegroundColor Cyan
    Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -ErrorAction SilentlyContinue
    
    Write-Host "`n=== HKLM:\Software\Microsoft\Windows\CurrentVersion\Run ===" -ForegroundColor Cyan
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run -ErrorAction SilentlyContinue
}

# Execute based on action parameter
switch ($Action) {
    "ListTasks" { Get-ScheduledTasksList }
    "DisableTask" { Disable-ScheduledTaskByName -Name $TaskName }
    "DeleteTask" { Delete-ScheduledTaskByName -Name $TaskName }
    "ClearStartupFolders" { Clear-StartupFolders }
    "ListRunKeys" { Show-RunKeys }
    default { Write-Error "Invalid action. Use: ListTasks, DisableTask, DeleteTask, ClearStartupFolders, ListRunKeys" }
}
