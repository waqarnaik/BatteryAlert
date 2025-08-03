<#
.SYNOPSIS
    Monitors battery levels and displays notifications Alerts.

.DESCRIPTION
    This script continuously monitors the battery level of a Windows device.
    It displays notifications with different icons based on the charge status:
    - Battery Full: Unplug your charger
    - Battery Low: Plug your charger

.NOTES
    File Name      : BatteryAlert.ps1
    Version        : v1.0.1
    Author         : Waqar Naik
    GitHub         : https://github.com/waqarnaik/BatteryAlert
    Prerequisite   : PowerShell, BurntToast module
#>

# Install BurntToast module if not already installed
if (-not (Get-Module -Name BurntToast -ListAvailable)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
}

# Import BurntToast module
Import-Module BurntToast -Force

$BatterySettings = [PSCustomObject]@{
    LowThreshold  = 29
    HighThreshold = 79
}

function Show-BatteryNotification {
    param (
        [string]$Message,
        [string]$IconSource
    )

    $image = New-BTImage -Source $IconSource -Crop None

    New-BurntToastNotification -Text $Message -AppLogo $image
}

while ($true) {
    $battery = Get-CimInstance -Namespace root/cimv2 -ClassName Win32_Battery

    if ($battery -and $battery.EstimatedChargeRemaining -ne $null) {
        $batteryLevel = $battery.EstimatedChargeRemaining
        $batteryStatus = $battery.BatteryStatus

        if ($batteryStatus -eq 2) {  # 2 represents charging
            if ($batteryLevel -gt $BatterySettings.HighThreshold) {
                Show-BatteryNotification -Message "~`nBattery Full! Unplug your charger`nCurrently at ($batteryLevel%)" -IconSource "$PSScriptRoot\icons\full_battery.png"
            }
        }
        else {
            if ($batteryLevel -lt $BatterySettings.LowThreshold) {
                Show-BatteryNotification -Message "~`nBattery Low! Plug Your Charger`nCurrently at ($batteryLevel%)" -IconSource "$PSScriptRoot\icons\low_battery.png"
            }
        }
    }
    else {
        Write-Host "Battery information not available or null value detected."
    }

    Start-Sleep -Seconds 120  # Notification sleeps for 2 minute (adjust as needed)
}
