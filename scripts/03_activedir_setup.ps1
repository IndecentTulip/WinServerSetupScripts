
Import-Module ActiveDirectory

$domain = "plskys.com"

# main OUs
New-ADOrganizationalUnit -Name "NEWUsers" -Path "DC=plskys,DC=com"
New-ADOrganizationalUnit -Name "NEWGroups" -Path "DC=plskys,DC=com"
New-ADOrganizationalUnit -Name "GlobalGroups" -Path "OU=NEWGroups, DC=plskys,DC=com"
New-ADOrganizationalUnit -Name "DomainLocalGroups" -Path "OU=NEWGroups, DC=plskys,DC=com"


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
    New-ADGroup -Name $dlname `
      -GroupScope DomainLocal `
      -GroupCategory Security `
      -Path $ouPath
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


# # Example setting NTFS permissions using PowerShell
# $businessAdminAccess = Get-ADGroup -Identity "BusinessAdminAccess"
# 
# # Replace with actual paths to your resources
# $folderPaths = @(
#     "\\server\Business tools",
#     "\\server\Employees records",
#     "\\server\Customer records",
#     "\\server\Financial records"
# )
# 
# foreach ($folderPath in $folderPaths) {
#     # Set Full Control for BusinessAdminAccess on Business tools, Employees records, and Customer records
#     $acl = Get-Acl -Path $folderPath
#     $permission = New-Object System.Security.AccessControl.FileSystemAccessRule(
#         "yourdomain\$businessAdminAccess",
#         "FullControl",
#         "ContainerInherit,ObjectInherit",
#         "None",
#         "Allow"
#     )
#     $acl.SetAccessRule($permission)
#     Set-Acl -Path $folderPath -AclObject $acl
# 
#     # Set Read permissions for BusinessAdminAccess on Financial records
#     $acl = Get-Acl -Path $folderPath
#     $permission = New-Object System.Security.AccessControl.FileSystemAccessRule(
#         "yourdomain\$businessAdminAccess",
#         "Read",
#         "ContainerInherit,ObjectInherit",
#         "None",
#         "Allow"
#     )
#     $acl.SetAccessRule($permission)
#     Set-Acl -Path $folderPath -AclObject $acl
# }

# # Define the paths to resources
# $BusinessToolsPath = "\\server\Business tools"
# $EmployeesRecordsPath = "\\server\Employees records"
# $CustomerRecordsPath = "\\server\Customer records"
# $FinancialRecordsPath = "\\server\Financial records"
# 
# # Set permissions for BusinessAdminAccess group
# $BusinessAdminAccessGroup = "BusinessAdminAccess"
# $PermissionFullControl = "FullControl"
# $PermissionRead = "ReadAndExecute"
# 
# # loop
# # Create access rules
# $AccessRuleBusinessTools = 
#   New-Object 
#     System.Security.AccessControl.FileSystemAccessRule(
#       $BusinessAdminAccessGroup,
#       $PermissionFullControl,
#       "ContainerInherit,ObjectInherit",
#       "None",
#       "Allow"
#     )
# 
# $AccessRuleEmployeesRecords =
#   New-Object 
#     System.Security.AccessControl.FileSystemAccessRule(
#       $BusinessAdminAccessGroup,
#       $PermissionFullControl,
#       "ContainerInherit,ObjectInherit",
#       "None",
#       "Allow"
#     )
# $AccessRuleCustomerRecords = New-Object System.Security.AccessControl.FileSystemAccessRule($BusinessAdminAccessGroup, $PermissionFullControl, "ContainerInherit,ObjectInherit", "None", "Allow")
# $AccessRuleFinancialRecords = New-Object System.Security.AccessControl.FileSystemAccessRule($BusinessAdminAccessGroup, $PermissionRead, "ContainerInherit,ObjectInherit", "None", "Allow")
# 
# # Apply access rules to resources
# $BusinessToolsACL = Get-Acl $BusinessToolsPath
# $BusinessToolsACL.SetAccessRule($AccessRuleBusinessTools)
# Set-Acl -Path $BusinessToolsPath -AclObject $BusinessToolsACL
# 
# $EmployeesRecordsACL = Get-Acl $EmployeesRecordsPath
# $EmployeesRecordsACL.SetAccessRule($AccessRuleEmployeesRecords)
# Set-Acl -Path $EmployeesRecordsPath -AclObject $EmployeesRecordsACL
# 
# $CustomerRecordsACL = Get-Acl $CustomerRecordsPath
# $CustomerRecordsACL.SetAccessRule($AccessRuleCustomerRecords)
# Set-Acl -Path $CustomerRecordsPath -AclObject $CustomerRecordsACL
# 
# $FinancialRecordsACL = Get-Acl $FinancialRecordsPath
# $FinancialRecordsACL.SetAccessRule($AccessRuleFinancialRecords)
# Set-Acl -Path $FinancialRecordsPath -AclObject $FinancialRecordsACL
# 
# 
# # Create shares for the folders
# New-SmbShare -Name "BusinessToolsShare" -Path $BusinessToolsPath -FullAccess "Domain Admins"
# New-SmbShare -Name "EmployeesRecordsShare" -Path $EmployeesRecordsPath -FullAccess "Domain Admins"
# New-SmbShare -Name "CustomerRecordsShare" -Path $CustomerRecordsPath -FullAccess "Domain Admins"
# New-SmbShare -Name "FinancialRecordsShare" -Path $FinancialRecordsPath -ReadAccess "BusinessAdminAccess"
# 
# # Create a new GPO
# $GPOName = "BusinessAdminAccess_Permissions"
# New-GPO -Name $GPOName
# 
# # Get the GUID of the newly created GPO
# $GPO = Get-GPO -Name $GPOName
# $GPOGuid = $GPO.Id
# 
# # Link the GPO to the Users OU
# $OUName = "OU=Users,DC=domain,DC=com"  # Replace with your actual domain
# New-GPLink -Name $GPOName -Target $OUName


# assuming that I will have resources(dedicated folders with documents and software).
# I want everyone who is in domain local group "BusinessAdminAccess"
# have a full excess to "Business tools" , "employees records", "Customer records" and read but not write permissions to "Financial records" resources?  can u show me a powershell script for that (assume that there are OUs but no GPUs so u would need to make GPU)
# 
# assumed structure:
# () for it's content
# OUs:
# Users
# Groups(BusinessAdmins, BusinessAdminAccess)
# Accounts: 
# Owner
# SupportStaffManager
# global groups:
# BusinessAdministrators(Owner, SupportStaffManager)
# domain local groups:
# BusinessAdminAccess(BusinessAdministrators)
# 
# all accounts are in Users OU
# BusinessAdministrators and BusinessAdminAccess are in their dedicated OUs

