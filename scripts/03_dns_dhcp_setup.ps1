
$DNS_Server = "10.0.0.15"
Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses $DNS_Server

$ZoneName = "plskys.com"
$ZoneFile = "plskys.com.DNS"
Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile $ZoneFile -DynamicUpdate NonsecureAndSecure

$ARecordName = "host1"
$ARecordIP = "10.0.0.50"
Add-DnsServerResourceRecordA -Name $ARecordName -ZoneName $ZoneName -AllowUpdateAny -IPv4Address 10.0.0.50

$ReverseZone = "1.168.192.in-addr.arpa"
Add-DnsServerPrimaryZone -NetworkID 192.168.140.0/24 -ZoneFile $ReverseZone

Resolve-DnsName host1.plskys.com

Read-Host "windows suck"

