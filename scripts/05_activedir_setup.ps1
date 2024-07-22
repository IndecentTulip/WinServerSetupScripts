
Import-Module ActiveDirectory

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted


$domain = "plskys.com"

# main OUs
try {
  New-ADOrganizationalUnit -Name "NEWUsers" -Path "DC=plskys,DC=com"
  New-ADOrganizationalUnit -Name "NEWGroups" -Path "DC=plskys,DC=com"
  New-ADOrganizationalUnit -Name "GlobalGroups" -Path "OU=NEWGroups, DC=plskys,DC=com"
  New-ADOrganizationalUnit -Name "DomainLocalGroups" -Path "OU=NEWGroups, DC=plskys,DC=com"
}
catch{
  Write-Host "The NEWGroups, NEWUsers, GlobalGroups, DomainLocalGroups are already created"
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
      -Path "OU=NEWUsers,DC=plskys,DC=com" `
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

foreach ($ggname in $globalGroupsNames) {
  $ouPath = "OU=GlobalGroups,OU=NEWGroups,DC=plskys,DC=com"

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
  "DomainAdminAccess", "Tier1Access",
  "Tier2Access", "Tier3Access"
)
foreach ($dlname in $domainLocalGroupsNames) {
  $ouPath = "OU=DomainLocalGroups,OU=NEWGroups,DC=plskys,DC=com"
  try {
    New-ADOrganizationalUnit `
      -Name $dlname `
      -Path $ouPath
  }
  catch{
    Write-Host "Failed to create OU for $dlname"
  }


}
foreach ($dlname in $domainLocalGroupsNames) {
  $ouPath = "OU=DomainLocalGroups,OU=NEWGroups,DC=plskys,DC=com"

  try {
    New-ADGroup -Name $dlname `
      -GroupScope DomainLocal `
      -GroupCategory Security `
      -Path "OU=" + $dlname + "," + $ouPath
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
    # $members = @() "array" 
    
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

#TODO finish OU permissions and fix the current file permissions

# Define shared folder paths and names
$sharedFolders = @{
    "Employees records" = "C:\SharedFolders\EmployeesRecords"
    "Financial records" = "C:\SharedFolders\FinancialRecords"
    "Business tools" = "C:\SharedFolders\BusinessTools"
    "Customer records" = "C:\SharedFolders\CustomerRecords"
    "Admin docs, programms" = "C:\SharedFolders\AdminDocsPrograms"
    "Support team reports" = "C:\SharedFolders\SupportTeamReports"
    "Tier1 tools" = "C:\SharedFolders\Tier1Tools"
    "Tier2 tools" = "C:\SharedFolders\Tier2Tools"
    "Tier3 tools" = "C:\SharedFolders\Tier3Tools"
}

# Create shared folders
foreach ($folderName in $sharedFolders.Keys) {
    $folderPath = $sharedFolders[$folderName]
    if (-not (Test-Path $folderPath)) {
        New-Item -Path $folderPath -ItemType Directory -Force
    }
    # Share the folder
    New-SmbShare -Name $folderName -Path $folderPath -FullAccess "Domain Admins"
}

# Define permissions for each domain local group
$permissions = @{
    "BusinessAdminAccess" = @("Employees records", "Financial records", "Business tools", "Customer records", "Admin docs, programms")
    "SupportStaffAccess" = @("Employees records", "Financial records", "Business tools", "Support team reports")
    "DomainAdminAccess" = @("Employees records", "Financial records", "Business tools", "Support team reports", "Customer records", "Admin docs, programms", "Tier1 tools", "Tier2 tools", "Tier3 tools")
    "Tier1Access" = @("Support team reports", "Customer records", "Tier1 tools")
    "Tier2Access" = @("Support team reports", "Customer records", "Tier1 tools", "Tier2 tools")
    "Tier3Access" = @("Support team reports", "Customer records", "Tier1 tools", "Tier2 tools", "Tier3 tools")
}

foreach ($group in $permissions.Keys) {
    $folders = $permissions[$group]
    foreach ($folder in $folders) {
        try {
            $acl = Get-Acl -Path ("\\localhost\" + $folder)
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("PLSKYS\$group", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.SetAccessRule($rule)
            Set-Acl -Path ("\\localhost\" + $folder) -AclObject $acl
        } catch {
            Write-Host "Failed to set permissions for $folder"
        }
    }
}





