
$output = ipconfig
$IPtemp = $output | Select-String "IPv4 Address"
$Masktemp = $output | Select-String "Subnet Mask"
$Gatetemp = $output | Select-String "Default Gateway"
$IPline = $IPtemp.Line
$Maskline = $Masktemp.Line
$Gateline = $Gatetemp.Line
$IP = $IPline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'
$Mask = $Maskline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'
$Gate = $Gateline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'
$octets = $Mask.Split('.')
$binary = $octets | ForEach-Object { [convert]::ToString($_, 2).PadLeft(8, '0') }
$prefixLength = ($binary -join "").Replace('0','').Length
$adapter = "Ethernet"  
$DNS_Server = $IP

# <><><><><><><><><><><><><><><><> DNS <><><><><><><><><><><><><><><><>

# Forvard look up
$ZoneName = "TechProSolutions.com"
$ZoneFile = "TechProSolutions.com.DNS"
Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile $ZoneFile -DynamicUpdate NonsecureAndSecure

# Reverse look up
$OctetsforRev = $IP -split '\.'
$ReverseIP = "$($OctetsforRev[2]).$($OctetsforRev[1]).$($OctetsforRev[0])"
$ReverseZone = $ReverseIP + ".in-addr.arpa"
$WorkID = "$($OctetsforRev[0]).$($OctetsforRev[1]).$($OctetsforRev[2])" + ".0" + "/" + $prefixLength
Write-Host "ReverseIP: $ReverseIP"
Write-Host "ReverseZone: $ReverseZone"
Write-Host "WorkID : $WorkID "
Add-DnsServerPrimaryZone -NetworkID $WorkID  -ZoneFile $ReverseZone
Add-DnsServerPrimaryZone -NetworkID "10.1.0.0/24" -ReplicationScope "Forest"

# A record
$ARecordName = "dns01"
Add-DnsServerResourceRecordA -Name $ARecordName -ZoneName $ZoneName -AllowUpdateAny -IPv4Address $IP
#$OctetsforHost = $IP.Split('.')
#$hostlastOCT = [int]$OctetsforHost[-1]
#$hostlastOCT++
#Write-Host "host1lastOCT : $host1lastOCT"
#$HostIP = "$($OctetsforHost[0]).$($OctetsforHost[1]).$($OctetsforHost[2]).$host1lastOCT"

# PTR
$PTRdomainName = $ARecordName + $ZoneName
Add-DnsServerResourceRecordPtr -Name $OctetsforRev[-1] -ZoneName $ReverseZone -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName $PTRdomainName
#Configure Forwarders

$forwarders = "8.8.8.8", "8.8.4.4"  

Set-DnsServerForwarder -IPAddress $forwarders

Read-Host "press anything to continue(debug)"
Resolve-DnsName TechProSolutions.com
Resolve-DnsName example.com
Get-DnsServer
ping google.com


# <><><><><><><><><><><><><><><><> DHCP <><><><><><><><><><><><><><><><>
Import-Module DhcpServer

# IP 10.0.0.14
$OctetsforDHCP = $IP.Split('.')

$lastOCT = [int]$OctetsforDHCP[-1] 

$StartRange = "$($OctetsforDHCP[0]).$($OctetsforDHCP[1]).$($OctetsforDHCP[2]).$($lastOCT + 1)"  
$EndRange = "$($OctetsforDHCP[0]).$($OctetsforDHCP[1]).$($OctetsforDHCP[2]).$($lastOCT + 100)"  

Add-DhcpServerv4Scope -Name "LAN Scope" -StartRange $StartRange -EndRange $EndRange -SubnetMask $Mask  

Add-DhcpServerInDC -DnsName "TechProSolutions.com" -IPAddress $IP 

Start-Service DHCPServer

