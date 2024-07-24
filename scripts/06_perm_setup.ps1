Import-Module GroupPolicy

# Create GPO
$GPOForDomainLocal = @(
  "BusinessAdminAccessPerm", "SupportStaffAccessPerm",
  "DomainAdminAccessPerm","Tier3AccessPerm", "Tier2AccessPerm",
  "Tier1AccessPerm", "DomainLocalPerm"
)

foreach ($gpoName in $GPOForDomainLocal) {

  try {
    New-GPO -Name $gpoName -Comment "Permissions for domain local group $gpoName"
  }
  catch {
    Write-Host "Failed to create GPO $gpoName"
  }
}



# DomainLocalPerm 
# DisableWindowsStorePolicy
Set-GPRegistryValue -Name "DomainLocalPerm" -Key "HKCU\Software\Policies\Microsoft\WindowsStore" -ValueName "RemoveWindowsStore" -Type DWORD -Value 1 -Confirm:$false

# Tier1AccessPerm
# ControlPanelPolicy(1)
Set-GPRegistryValue -Name "Tier1AccessPerm" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWORD -Value 1 -Confirm:$false


# Tier2AccessPerm
# ControlPanelPolicy(0)
Set-GPRegistryValue -Name "Tier1AccessPerm" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWORD -Value 0 -Confirm:$false
# RestartPermissionPolicy
Set-GPRegistryValue -Name "Tier1AccessPerm" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ShutdownWithoutLogon" -Type DWORD -Value 1 -Confirm:$false
# BitLockerPolicy
Set-GPRegistryValue -Name "Tier1AccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\FVE" -ValueName "OSRequireActiveDirectoryBackup" -Type DWORD -Value 1 -Confirm:$false


# Tier3AccessPerm
# RemoteDesktopPolicy
Set-GPRegistryValue -Name "Tier3AccessPerm" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 0 -Confirm:$false
# DisableUACPolicy
Set-GPRegistryValue -Name "Tier3AccessPerm" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableLUA" -Type DWORD -Value 0 -Confirm:$false

# DomainAdminAccessPerm
# WindowsDefenderPolicy
Set-GPRegistryValue -Name "DomainAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" -ValueName "DisableAntiSpyware" -Type DWORD -Value 1 -Confirm:$false
# RemoteDesktopPolicy
Set-GPRegistryValue -Name "DomainAdminAccessPerm" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 0 -Confirm:$false
# RestartPermissionPolicy
Set-GPRegistryValue -Name "DomainAdminAccessPerm" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ShutdownWithoutLogon" -Type DWORD -Value 1 -Confirm:$false
# DisableUACPolicy
Set-GPRegistryValue -Name "DomainAdminAccessPerm" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableLUA" -Type DWORD -Value 0 -Confirm:$false


# SupportStaffAccessPerm
# PreventDisableDefenderPolicy
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -ValueName "DisableRealtimeMonitoring" -Type DWORD -Value 0 -Confirm:$false
# PrinterConnectionsPolicy
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKCU\Software\Policies\Microsoft\Windows NT\Printers" -ValueName "DisableAddPrinter" -Type DWORD -Value 1 -Confirm:$false
# SoftwareRestrictionPolicy
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWORD -Value 1 -Confirm:$false
# ControlPanelPolicy(1)
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWORD -Value 1 -Confirm:$false
# BitLockerPolicy
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\FVE" -ValueName "EncryptionMethodWithXtsOs" -Type DWORD -Value 7 -Confirm:$false
# RemoteDesktopPolicy
Set-GPRegistryValue -Name "SupportStaffAccessPerm" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 0 -Confirm:$false

# BusinessAdminAccessPerm 
# PreventDisableDefenderPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -ValueName "DisableRealtimeMonitoring" -Type DWORD -Value 0 -Confirm:$false
# PreventSoftwareInstallationPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWORD -Value 1 -Confirm:$false
# BlockCMDandPowerShellPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWORD -Value 1 -Confirm:$false
# SoftwareRestrictionPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWORD -Value 1 -Confirm:$false
# ControlPanelPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWORD -Value 1 -Confirm:$false
# BitLockerPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SOFTWARE\Policies\Microsoft\FVE" -ValueName "EncryptionMethodWithXtsOs" -Type DWORD -Value 7 -Confirm:$false
# RemoteDesktopPolicy
Set-GPRegistryValue -Name "BusinessAdminAccessPerm" -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 0 -Confirm:$false



#$GPOnPermissions @{
#  "BusinessAdminAccessPerm" = @{}
#  "SupportStaffAccessPerm" = @{}
#  "DomainAdminAccessPerm" = @{}
#  "Tier3AccessPerm" = @{}
#  "Tier2AccessPerm" = @{}
#  "Tier1AccessPerm" = @{} 
#}
#
#
#foreach ($gpoName in $GPOForDomainLocal) {
#  $params = $GPOnPermissions[$gpoName]
#  try {
#    Set-GPRegistryValue @params
#  }
#  catch {
#  }
#}

# Link
$defaltPath = "OU=DomainLocalGroups,OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
$ouPathsnGPONames = @{
  "BusinessAdminAccessPerm" = @("OU=BusinessAdminAccess")
  "SupportStaffAccessPerm" = @("OU=SupportStaffAccess")
  "DomainAdminAccessPerm" = @("OU=DomainAdminAccess")
  "Tier1AccessPerm" = @("OU=Tier1Access,OU=Tier2Access,OU=Tier3Access")
  "Tier2AccessPerm" = @("OU=Tier2Access,OU=Tier3Access")
  "Tier3AccessPerm" = @("OU=Tier3Access")
  "DomainLocalPerm" = @("")

}
foreach ($name in $GPOForDomainLocal) {
    $path = $ouPathsnGPONames[$name] 
    $newPath = "$path,$defaltPath"
    
    try {
      New-GPLink -Name $name -Target $newPath 
    }
    catch{
      Write-Host "failed link $name to $newPath"
    }

}


