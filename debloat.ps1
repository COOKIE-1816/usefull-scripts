# MICROSOFT WINDOWS 10+ DEBLOAT SCRIPT
# ======================================
#   rev 1.0.
#
# Please read these bunch of text here before executing so you do not trash your computer and you do not
# accidentaly remove/disable/change/etc. something you actually do not want to.
#
# WHAT DOES THIS SCRIPT DO?
# ===========================
# - Disables Windows Telemetry (Data collection)
# - Disables Wi-Fi Sense, so newly connected Wi-Fi passwords are no longer saved to MicroSoft's servers
# - Disables SmartScreen filter
# - Disables Bing search in Start menu
# - Disables Start menu suggestions
# - Disables location tracking
# - Disables MicroSoft Feedback
# - Disables Cortana
# - Restricts P2P to local network only
# - Disables Windows Diagnosis tracking
# - Disables WAP Push
# - Enables shared drive mapping between users
# - Disables implicit administration shares
# - Disables Windows Firewall
# - Disables Windows Defender
# - Disables MRT
# - Disables auto ("unexcepted") restart after Windows update
# - Disables home groups
# - Disables remote assistance
# - Disables sticky keys
# - Disables and uninstalls OneDrive
# - Uninstalls some default (metro, UWP) apps
# - Disables Xbox DVR
# - Uninstalls Media Player
# - Uninstalls work folders client
# - Enables old photo viewer
#
# DO NOT RUN THIS IF...
# =======================
# - This computer is often used in in-secure nor public networks
# - This computer is a part of a domain
# - You want not to disable some security features
# - You want to use some of removed features
# - This computer is not property of yours or you have no permission from owner so you can run this
# 
# SIDE EFFECTS OF RUNNING THIS SCRIPT
# =====================================
# Running this script may have few side effects. Anyways, do not be afraid to them, do not be
# scared when they actually occur - as it usually does - because it does not have long-lasting
# side effects at all and they are not sign of any demage.
#
# If you actually spot some unlisted side effects, please let me know.
# Here is a list of known (reported) side effects:
#
# - Windows Explorer (desktop, start menu, taskbar, file manager) may crash when this script is
#   running. It should start up again almost immediatelly, if not, you can start it using task
#   manager.
# - Network connections (Wi-Fi especially) may become unstable or stop working. Again, this does
#   not last any long. Should also start working again almost immediatelly. If it does not,
#   restarting your computer would work for sure.
#
# Do not be scared if you see some errors during de-bloat process. They are common and may not
# be important as usual, so let script complete it's work. If you are always not sure if it is
# okay, send me link you got this script from, its version and version, and everything this
# script printed on screen.
#
# BEFORE RUNNING THIS SCRIPT
# ============================
# Be sure that other apps are not running.
#
# AFTER RUNNING THIS SCRIPT
# ===========================
# 1. Restart your computer as soon as possible
# 2. After restart, run cleanmgr.exe and clean system files that were created during de-bloat
#
# After running this script, you should see used system volume space slowly decrease. Not sure
# why, but it tooks few minutes before results are fully visible.
#
# After running this script, my system volume used space slowly decreased about 14.3 GB. Please
# note this may not be same for every computer and has many factors it depends on.

Write-Host "Windows Debloat script by Vaclav Hajsman!"

Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
		Exit
	}
}

Function Step-Print($StepNo, $StepName) {
    Write-Host ("STEP", $StepNo, $StepName) -Separator ": " -ForegroundColor Magenta
}

Function Disable-Telemetry {
    Step-Print "01" "Disable telemetry"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"                -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"                               -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    -Name "AllowTelemetry" -Type DWord -Value 0
}

Function Disable-Wifi-Sense {
    Step-Print "02" "Disable Wi-Fi tense"

    If (! (Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"           -Name "Value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
}

Function Disable-Smart-Screen {
    Step-Print "03" "Disable SmartScreen Filter"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled"         -Type String -Value "Off"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost"  -Name "EnableWebContentEvaluation" -Type DWord  -Value 0
}

Function Disable-Start-Bing {
    Step-Print "04" "Disable Bing search in Start menu"

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
}

Function Disable-Start-Suggestions {
    Step-Print "05" "Disable Start menu app suggestions"

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
}

Function Disable-Location-Tracking {
    Step-Print "06" "Disable location tracking"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"                                        -Name "Status"                -Type DWord -Value 0
}

Function Disable-Feedback {
    Step-Print "07" "Disable feedback"

    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
}

Function Disable-Cortana {
    Step-Print "08" "Disable Cortana"

    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0

    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection"   -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection"    -Type DWord -Value 1

    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
}

Function P2PRestrict {
    Step-Print "09" "Restrict P2P to local network only"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
    
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization")) {
	    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" | Out-Null
    }
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value 3
}

Function Disable-Diagnosis-Tracking {
    Step-Print "10" "Disable diagnosis tracking"

    Stop-Service "DiagTrack"
    Set-Service  "DiagTrack" -StartupType Disabled
}

Function Disable-WAP-Push {
    Step-Print "11" "Disable WAP Push service"

    Stop-Service "dmwappushservice"
    Set-Service "dmwappushservice" -StartupType Disabled
}

Function Enable-SharedDrive-Mapping-BetweenUsers {
    Step-Print "12" "Enable shared drive mapping between users"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
}

Function Disable-Implicit-Administrative-Shares {
    Step-Print "13" "Disable implicit administrative shares"

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Type DWord -Value 0
}

Function Disable-Firewall {
    Step-Print "14" "Disable Windows Firewall"

    Set-NetFirewallProfile -Profile * -Enabled False
}

Function Disable-Defender {
    Step-Print "15" "Disable Windows Defender"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"     -Name "DisableAntiSpyware"  -Type DWord -Value 1
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender"     -ErrorAction SilentlyContinue
}

Function Disable-MRT {
    Step-Print "16" "Disable Malicious Removal Tool (MRT)"

    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
}

Function Disable-Update-AutoRestart {
    Step-Print "17" "Disable 'unexcepted' restart after update"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
}

Function Disable-HomeGroup {
    Step-Print "18" "Disable home groups"

    Stop-Service "HomeGroupListener"
    Set-Service "HomeGroupListener" -StartupType Disabled

    Stop-Service "HomeGroupProvider"
    Set-Service "HomeGroupProvider" -StartupType Disabled
}

Function Disable-RemoteAssistance {
    Step-Print "19" "Disable remote assistance"

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
}

Function Disable-StickyKeys {
    Step-Print "20" "Disable Sticky keys"

    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
}

Function Disable-OneDrive {
    Step-Print "21" "Disable OneDrive"

    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
}

Function Remove-OneDrive {
    Step-Print "22" "Uninstall OneDrive"

    $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"

    Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
    Start-Sleep -s 3

    If (!(Test-Path $onedrive)) {
        $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
    }

    Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
    Start-Sleep -s 3

    Stop-Process -Name explorer -ErrorAction SilentlyContinue
    Start-Sleep -s 3

    Remove-Item "$env:USERPROFILE\OneDrive"             -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive"  -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive"   -Force -Recurse -ErrorAction SilentlyContinue

    If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
        Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
    }

    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }

    Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"              -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"  -Recurse -ErrorAction SilentlyContinue
}

Function Uninstall-DefaultApps {
    Step-Print "23" "Remove useless UWP apps"

    # Uncomment this if you want to
    # Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
    
    Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
    Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage

    Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
    Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
    Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
    Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
    Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
    Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
    Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
}

Function Disable-Xbox-DVR {
    Step-Print "24" "Remove Xbox DVR"

    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

Function Uninstall-Media-Player {
    Step-Print "25" "Uninstall Windows Media Player"

    dism /online /Disable-Feature /FeatureName:MediaPlayback /NoRestart
}

Function Uninstall-WorkFolders-Client {
    Step-Print "26" "Uninstall work folders client"
    dism /online /Disable-Feature /FeatureName:WorkFolders-Client /NoRestart
}

Function Enable-Old-PhotoViewer {
    Step-Print "27" "Enable the old good photo viewer"
    
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }

    ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
        New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
        New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null

        Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
        Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
    }

    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }

    New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
    New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null

    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
}

RequireAdmin

Disable-Telemetry
Disable-Wifi-Sense
Disable-Smart-Screen
Disable-Start-Bing
Disable-Start-Suggestions
Disable-Location-Tracking
Disable-Feedback
Disable-Cortana
P2PRestrict
Disable-Diagnosis-Tracking
Disable-WAP-Push
Enable-SharedDrive-Mapping-BetweenUsers
Disable-Implicit-Administrative-Shares
Disable-Firewall
Disable-Defender
Disable-MRT
Disable-Update-AutoRestart
Disable-HomeGroup
Disable-RemoteAssistance
Disable-StickyKeys
Disable-OneDrive
Remove-OneDrive
Uninstall-DefaultApps
Disable-Xbox-DVR
Uninstall-WorkFolders-Client
Enable-Old-PhotoViewer