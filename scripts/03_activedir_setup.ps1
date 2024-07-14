import-module activedirectory

# IT DOESN'T WORK NOW

$domain = "plskys.com"
# main ous
new-adorganizationalunit -name "users" -path "dc=$domain"
new-adorganizationalunit -name "groups" -path "dc=$domain"


# creation of users
$accountnames = @(
  "owner", "supportstaffmanager",
  "accountmanager", "operationsmanager",
  "networkadmin", "systemadmin",
  "databaseadmin", "helpdesksupport",
  "itsupportjunior", "itsupportsenior",
  "itinfrastructureconsultant",
  "securityspecialist", "databasespecialist",
  "networkspecialist"
)

foreach ($name in $accountnames) {
  new-aduser -name $name `
    -samaccountname $name `
    -userprincipalname ($name + "@" + $domain) `
    -accountpassword (convertto-securestring "p@ssw0rd" -asplaintext -force) `
    -path "ou=users,dc=$domain" `
    -enabled $true
}

# create global groups and ous for them
$globalgroupsnames = @(
  "businessadmins", "supportstaff", 
  "administrativestaff", "tier1support", 
  "tier2support", "tier3support" 
)

foreach ($name in $globalgroupsnames) {
  new-adorganizationalunit ` 
    -name $name `
    -path "ou=groups,dc=$domain"


  new-adgroup -name $name `
    -groupscope global `
    -groupcategory security `
    -path "ou=$name ou=groups,dc=$domain"
}

# create domain local groups and ous for them
$domainlocalgroupsnames = @(
  "businessadminaccess", "supportstaffaccess",
  "domainadminaccess", "tier1access",
  "tier2access", "tier3access"
)

foreach ($name in $domainlocalgroupsnames) {
  new-adorganizationalunit ` 
    -name $name `
    -path "ou=groups,dc=$domain"


  new-adgroup -name $name `
    -groupscope domainlocal `
    -groupcategory security `
    -path "ou=$name ou=groups,dc=$domain"
}

# yes, turns out there are hashtables in powershell 
$globalgroupmembers = @{
  "businessadmins" = @("owner", "supportstaffmanager")
  "supportstaff" = @("accountmanager", "operationsmanager")
  "administrativestaff" = @("systemadmin", "networkadmin", "databaseadmin")
  "tier1support" = @("helpdesksupport", "itsupportjunior")
  "tier2support" = @("itsupportsenior", "itinfrastructureconsultant")
  "tier3support" = @("securityspecialist", "databasespecialist", "networkspecialist")
}

foreach ($name in $globalgroupsnames) {
  if ($globalgroupmembers.containskey($name)) {
    $members = $globalgroupmembers[$name]  # get members for the current group
    # $members = @() "array" 
    
    $admembers = $members | foreach-object { get-aduser -identity $_ }
    # $_ is current element of array that foreach goes though
    add-adgroupmember -identity $name -members $admembers
  }

}

$domainlocalgroupmembers = @{
  "businessadminaccess" = @("businessadmins")
  "supportstaffaccess" = @("supportstaff")
  "domainadminaccess" = @("administrativestaff")
  "tier1access" = @("tier1support")
  "tier2access" = @("tier2support")
  "tier3access" = @("tier3support")
}

foreach ($name in $domainlocalgroupsnames) {
  if ($domainlocalgroupmembers.containskey($name)){
    $members = $domainlocalgroupmembers[$name]

    $admembers = $members | foreach-object { get-adgroup -identity $_}
    add-adgroupmember -identity $name -members $admembers
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
