# Configure DNS Server settings
$dnsIPAddress = "10.0.0.15"  # Replace with your server's IP address
$dnsServerName = "bestdns"
$dnsZoneName = "plskys.com"

# Configure forward lookup zone
Add-DnsServerPrimaryZone -Name $dnsZoneName -ZoneFile "$dnsZoneName.dns"

# Set DNS Server IP address
Set-DnsServerPrimaryZone -Name $dnsZoneName -MasterServers $dnsIPAddress

# Create A record for DNS Server itself
Add-DnsServerResourceRecordA -Name $dnsServerName -ZoneName $dnsZoneName -IPv4Address $dnsIPAddress

# Configure DHCP Server settings
$dhcpScopeName = "LANScope"
$dhcpStartRange = "10.0.0.16"
$dhcpEndRange = "10.0.255.255"
$dhcpSubnetMask = "255.255.0.0"
$dhcpRouter = "10.0.0.1"  # Default gateway
$dnsServerIP = "10.0.0.15"  # DNS Server IP

# Authorize DHCP Server in Active Directory
Add-DhcpServerInDC

# Create DHCP Scope
Add-DhcpServerv4Scope -Name $dhcpScopeName -StartRange $dhcpStartRange -EndRange $dhcpEndRange -SubnetMask $dhcpSubnetMask -Router $dhcpRouter

# Set DNS Servers for DHCP clients
Set-DhcpServerv4OptionValue -OptionId 6 -ScopeId $dhcpScopeName -DnsServer $dnsServerIP

