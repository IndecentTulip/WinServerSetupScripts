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


# Forvard look up
$ZoneName = "plskys.com"
$ZoneFile = "plskys.com.DNS"
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


# A record
$OctetsforHost = $IP.Split('.')
$host1lastOCT = [int]$OctetsforHost[-1]
$host1lastOCT++
Write-Host "host1lastOCT : $host1lastOCT"
$Host1IP = "$($OctetsforHost[0]).$($OctetsforHost[1]).$($OctetsforHost[2]).$host1lastOCT"
$ARecordName = "host1"
Add-DnsServerResourceRecordA -Name $ARecordName -ZoneName $ZoneName -AllowUpdateAny -IPv4Address $Host1IP 

# PTR
$PTRdomainName = $ARecordName + $ZoneName
Write-Host "host1lastOCT : $host1lastOCT "
Add-DnsServerResourceRecordPtr -Name $host1lastOCT -ZoneName $ReverseZone -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName $PTRdomainName

Read-Host "press anything to continue(debug)"
Resolve-DnsName host1.plskys.com
ping google.com


