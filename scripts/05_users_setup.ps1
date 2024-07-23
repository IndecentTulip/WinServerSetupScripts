
Import-Module ActiveDirectory

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted


$domain = "TechProSolutions.com"

# main OUs
try {
  New-ADOrganizationalUnit -Name "Company" -Path "DC=TechProSolutions,DC=com"
  New-ADOrganizationalUnit -Name "Users" -Path "OU=Company,DC=TechProSolutions,DC=com"
  New-ADOrganizationalUnit -Name "Groups" -Path "OU=Company,DC=TechProSolutions,DC=com"
  New-ADOrganizationalUnit -Name "GlobalGroups" -Path "OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
  New-ADOrganizationalUnit -Name "DomainLocalGroups" -Path "OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
}
catch{
  Write-Host "The Company Groups, Users, GlobalGroups, DomainLocalGroups are already created"
}


# Creation of Users
$accountNames = @(
  "Owner", "SupportStaffManager",
  "AccountManager", "OperationsManager",
  "NetworkAdmin", "SystemAdmin",
  "DatabaseAdmin", "HelpDeskSupport",
  "ITSupportJunior", "ITSupportSenior",
  "ITInfrConsultant", "SecuritySpecialist",
  "DatabaseSpecialist", "NetworkSpecialist"
)

foreach ($acname in $accountNames) {
  try {
    New-ADUser -Name $acname `
      -SamAccountName $acname `
      -UserPrincipalName ($acname + "@" + $domain) `
      -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
      -Path "OU=Users,OU=Company,DC=TechProSolutions,DC=com" `
      -Enabled $true
  }
  catch {
    Write-Host "Failed to create user $acname"
  }
}

# Create Global Groups and OUs for them
$globalGroupsNames = @(
  "BusinessAdmins", "SupportStaff", 
  "AdministrativeStaff", "Tier1Support", 
  "Tier2Support", "Tier3Support" 
)

$ouPath = "OU=GlobalGroups,OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
foreach ($ggname in $globalGroupsNames) {

  try {
    New-ADGroup -Name $ggname `
      -GroupScope Global `
      -GroupCategory Security `
      -Path $ouPath
  }
  catch {
    Write-Host "Failed to create group $ggname"
  }
}

# Create Domain Local Groups and OUs for them
$domainLocalGroupsNames = @(
  "BusinessAdminAccess", "SupportStaffAccess",
  "DomainAdminAccess"

)
$ouPath = "OU=DomainLocalGroups,OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
foreach ($dlname in $domainLocalGroupsNames) {
  try {
    New-ADOrganizationalUnit `
      -Name $dlname `
      -Path $ouPath
  }
  catch{
    Write-Host "Failed to create OU for $dlname"
  }
}
$domainLocalGroupsTierNames = @(
  "Tier3Access", "Tier2Access",
  "Tier1Access"
)
$ouTierPath = "OU=DomainLocalGroups,OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
foreach ($dlname in $domainLocalGroupsTierNames) {
  try {
    New-ADOrganizationalUnit `
      -Name $dlname `
      -Path $ouTierPath

    $ouTierPath = "OU=$dlname,$ouTierPath"
  }
  catch{
    Write-Host "Failed to create OU for $dlname"
  }
}


foreach ($dlname in $domainLocalGroupsNames) {
  $newPath = "OU=$dlname,$ouPath"

  try {
    New-ADGroup -Name $dlname `
      -GroupScope DomainLocal `
      -GroupCategory Security `
      -Path $newPath
  }
  catch{
    Write-Host "Failed to create group $dlname"
  }
}

$outierpath = "OU=DomainLocalGroups,OU=Groups,OU=Company,DC=TechProSolutions,DC=com"
foreach ($dlname in $domainLocalGroupsTierNames) {
  $outierpath = "OU=$dlname,$outierpath"

  try {
    New-ADGroup -Name $dlname `
      -GroupScope DomainLocal `
      -GroupCategory Security `
      -Path $outierpath
  }
  catch{
    Write-Host "Failed to create group $dlname"
  }
}



# yes, turns out there are hashtables in powershell 
$globalGroupMembers = @{
  "BusinessAdmins" = @("Owner", "SupportStaffManager")
  "SupportStaff" = @("AccountManager", "OperationsManager")
  "AdministrativeStaff" = @("SystemAdmin", "NetworkAdmin", "DatabaseAdmin")
  "Tier1Support" = @("HelpDeskSupport", "ITSupportJunior")
  "Tier2Support" = @("ITSupportSenior", "ITInfrConsultant")
  "Tier3Support" = @("SecuritySpecialist", "DatabaseSpecialist", "NetworkSpecialist")
}



foreach ($name in $globalGroupsNames) {
  if ($globalGroupMembers.ContainsKey($name)) {
    $members = $globalGroupMembers[$name]  # Get members for the current group
    
    try {
      $adMembers = $members | ForEach-Object { Get-ADUser -Identity $_ }
      # $_ is current element of array that foreach goes though
      Add-ADGroupMember -Identity $name -Members $adMembers
    }
    catch{
      Write-Host "failed to add $members to $name"
    }
  }

}

$domainLocalGroupMembers = @{
  "BusinessAdminAccess" = @("BusinessAdmins")
  "SupportStaffAccess" = @("SupportStaff")
  "DomainAdminAccess" = @("AdministrativeStaff")
  "Tier1Access" = @("Tier1Support")
  "Tier2Access" = @("Tier2Support")
  "Tier3Access" = @("Tier3Support")
}

foreach ($name in $domainLocalGroupsNames) {
  if ($domainLocalGroupMembers.ContainsKey($name)){
    $members = $domainLocalGroupMembers[$name]

    try {
      $adMembers = $members | ForEach-Object { Get-ADGroup -Identity $_}
      Add-ADGroupMember -Identity $name -Members $adMembers
    }
    catch{
      Write-Host "failed to add $members to $name"
    }
  }
}


