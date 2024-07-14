# >>>> AD set up
Import-Module ActiveDirectory
$domain = "plskys.com"
$cred = Get-Credential
Connect-ADServer -Server $domain -Credential $cred

# >>>> global group
$groupName = "FinanceUsers"  # Replace with your desired group name
$ou = "OU=Groups,DC=yourdomain,DC=com"  # Replace with the OU where you want to create the group

New-ADGroup -Name $groupName -GroupScope Global -Path $ou -Description "Global group for Finance users"

# >>>> domain local group
$groupName = "Admins_DomainLocal"  # Replace with your desired group name
$ou = "OU=Groups,DC=yourdomain,DC=com"  # Replace with the OU where you want to create the group

New-ADGroup -Name $groupName -GroupScope DomainLocal -Path $ou -Description "Domain Local group for administrators"


# >>>> account
$username = "Owner"
$password = ConvertTo-SecureString "1234varystrongpassword" -AsPlainText -Force
$fullname = "John Snow"
$ou = "OU=Users,DC=yourdomain,DC=com"  # Replace with the OU where you want to create the user

New-ADUser -Name $username -SamAccountName $username -UserPrincipalName "$username@$domain" `
           -DisplayName $fullname -GivenName $fullname -Surname " " -AccountPassword $password `
           -Enabled $true -Path $ou

# >>>> domain local group -> perm

$groupName = "Admins_DomainLocal"  # Replace with the name of your Domain Local group
$group = Get-ADGroup -Filter { Name -eq $groupName }

$folderPath = "C:\Path\To\Folder"
$acl = Get-Acl $folderPath
$permission = New-Object System.Security.AccessControl.FileSystemAccessRule("yourdomain\$groupName", "Read", "Allow")
$acl.SetAccessRule($permission)
Set-Acl $folderPath $acl

$objectPath = "CN=SomeObject,OU=Objects,DC=yourdomain,DC=com"
$acl = Get-Acl $objectPath
$permission = New-Object System.DirectoryServices.ActiveDirectoryAccessRule("yourdomain\$groupName", "ReadProperty", "Allow")
$acl.AddAccessRule($permission)
Set-Acl $objectPath $acl

# >>>> account -> global group

$groupName = "FinanceUsers"  # Replace with the name of your global group
$group = Get-ADGroup -Identity $groupName

$user1 = Get-ADUser -Identity "user1"  # Replace with the username or object identity
$user2 = Get-ADUser -Identity "user2"  # Replace with the username or object identity

Add-ADGroupMember -Identity $group -Members $user1, $user2

# Get-ADGroupMember -Identity $group # to see see member of the group

# >>>> global group -> domain local group

$globalGroupName = "FinanceUsers"  # Replace with the name of your global group
$domainLocalGroupName = "Admins_DomainLocal"  # Replace with the name of your domain local group

$globalGroup = Get-ADGroup -Identity $globalGroupName
$domainLocalGroup = Get-ADGroup -Identity $domainLocalGroupName

Add-ADGroupMember -Identity $domainLocalGroup -Members $globalGroup

# Get-ADGroupMember -Identity $domainLocalGroup # to see group memebers



