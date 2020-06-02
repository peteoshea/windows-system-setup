# Check for Admininstrator permissions
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator"
    exit
}

Write-Host "==> Update settings..."

Write-Host "===> Allow running of signed scripts"
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq "Restricted") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
}

Write-Host "===> Enable developer mode"
$registryItem = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $registryItem -Name AllowDevelopmentWithoutDevLicense -Value 1

Write-Host "===> Update power settings:"
Write-Host "- Monitor to sleep after 15 minutes when plugged in"
PowerCfg /Change monitor-timeout-ac 15
Write-Host "- Never sleep when plugged in"
PowerCfg /Change standby-timeout-ac 0

Write-Host "===> Update file explorer settings:"
$registryItem = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Write-Host "- Show hidden files"
Set-ItemProperty -Path $registryItem -Name Hidden -Value 1
Write-Host "- Show file extensions"
Set-ItemProperty -Path $registryItem -Name HideFileExt -Value 0
Write-Host "- Expand to current folder"
Set-ItemProperty -Path $registryItem -Name NavPaneExpandToCurrentFolder -Value 1
Write-Host "- Show Recycle Bin"
Set-ItemProperty -Path $registryItem -Name NavPaneShowAllFolders -Value 1

Write-Host
Write-Host "==> Install programs..."

$chocolateyInstalled = $false
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $chocolateyInstalled = $true
}
if ($chocolateyInstalled -eq $false) {
    Write-Host "===> Installing Chocolatey..."

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Host "===> Updating Chocolatey..."
    choco upgrade chocolatey
}

function Install-ChocolateyPackage {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )
    Write-Host "===> Installing '$Name' using Chocolatey"
    choco upgrade $Name --confirm
}
function Install-WinGetPackage {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,
        [Parameter(Mandatory=$false)]
        [switch]
        $Exact
    )
    Write-Host "===> Installing '$Name' using winget"
    if ($Exact) {
        winget install $Name --exact
    } else {
        winget install $Name
    }
}

Install-WinGetPackage -Name 1password
Install-WinGetPackage -Name Git.Git -Exact
Install-WinGetPackage -Name Microsoft.GitCredentialManagerforWindows -Exact
Install-WinGetPackage -Name slack
# Install-WinGetPackage -Name sourcetree # Doesn't see to work at the moment
Install-WinGetPackage -Name terminal
Install-WinGetPackage -Name vscode

Install-ChocolateyPackage -Name soucetree

Write-Host
Write-Host "==> Configure programs..."
Write-Host "===> Install VS Code settings sync extension..."
code --install-extension shan.code-settings-sync

Write-Host
Write-Host "==> Setup completed!"
$restartResponse = Read-Host -Prompt "Enter 'yes' if you wish to trigger a restart"
if ($restartResponse -eq "yes") {
    Write-Host "Okay, restarting system"
    Restart-Computer
}
