Import-Module GroupPolicy

# Create GPO
$GPOForDomainLocal = @(
  "BusinessAdminAccessPerm", "SupportStaffAccessPerm",
  "DomainAdminAccessPerm","Tier3AccessPerm", "Tier2AccessPerm",
  "Tier1AccessPerm"
)

foreach ($gpoName in $GPOForDomainLocal) {

  try {
    New-GPO -Name $gpoName -Comment "Permissions for domain local group $gpoName"
  }
  catch {
    Write-Host "Failed to create GPO $gpoName"
  }
}

## Set Permissions
#$GPOnPermissions @{
#  "BusinessAdminAccessPerm",
#  "SupportStaffAccessPerm",
#  "DomainAdminAccessPerm",
#  "Tier3AccessPerm",
#  "Tier2AccessPerm",
#  "Tier1AccessPerm" 
#}
#
#$params = @{
#    Name      = "BusinessAdminAccessPerm"
#    Key       = ''
#    ValueName = ''
#    Value     = 
#    Type      = ''
#}
#Set-GPRegistryValue @params
#foreach ($gpoName in $GPOForDomainLocal) {
#
#  try {
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


