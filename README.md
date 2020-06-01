# Windows System Setup

A PowerShell script to help setup Windows on a new machine in a consistent manner.

This script will install various programs and applies configuration options for both Windows and the programs installed.
Programs are installed via [winget](https://github.com/microsoft/winget-cli) where possible but [Chocolatey](https://chocolatey.org/) is currently still used as well.

The new Microsoft winget package manager is currently only available in the insider version of Windows 10.
You may also need to manually install the [App Installer](https://www.microsoft.com/en-gb/p/app-installer/9nblggh4nns1) but hopefully that will come preinstalled going forward.

To run this script directly from powerShell on a new system simply run:
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/peteoshea/windows-system-setup/master/setup.ps1'))
```
