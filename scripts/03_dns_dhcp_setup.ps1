New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.0.15" -PrefixLength 16 -DefaultGateway "10.0.0.1"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.0.0.15"

$dnsIPAddress = "10.0.0.15"
$dnsServerName = "bestdns"
$dnsZoneName = "plskys.com"

Add-DnsServerPrimaryZone -Name $dnsZoneName -ZoneFile "$dnsZoneName.dns"
Set-DnsServerPrimaryZone -Name $dnsZoneName -MasterServers $dnsIPAddress
Add-DnsServerResourceRecordA -Name $dnsServerName -ZoneName $dnsZoneName -IPv4Address $dnsIPAddress

$dhcpScopeName = "LANScope"
$dhcpStartRange = "10.0.0.1"
$dhcpEndRange = "10.0.255.254"
$dhcpSubnetMask = "255.255.0.0"
$dhcpRouter = "10.0.0.1"
$dnsServerIP = "10.0.0.15"

Add-DhcpServerInDC
Add-DhcpServerv4Scope -Name $dhcpScopeName -StartRange $dhcpStartRange -EndRange $dhcpEndRange -SubnetMask $dhcpSubnetMask -Router $dhcpRouter

Set-DhcpServerv4OptionValue -OptionId 6 -ScopeId $dhcpScopeName -DnsServer $dnsServerIP

Restart-Computer -Force

