$output = ipconfig

$IPtemp = $output | Select-String "IPv4 Address"
$Masktemp = $output | Select-String "Subnet Mask"
$Gatetemp = $output | Select-String "Default Gateway"

# Extract IPv4 address line from the match object
$IPline = $IPtemp.Line
$Maskline = $Masktemp.Line
$Gateline = $Gatetemp.Line

$IP = $IPline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'
$Mask = $Maskline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'
$Gate = $Gateline -replace '.*:\s*(\d+\.\d+\.\d+\.\d+).*', '$1'

# Output the IPv4 address
Write-Host "IPv4 Address: $IP"
Write-Host "Mask: $Mask"
Write-Host "Gate: $Gate"


# Split the subnet mask into octets and convert to binary
$octets = $Mask.Split('.')
$binary = $octets | ForEach-Object { [convert]::ToString($_, 2).PadLeft(8, '0') }

$prefixLength = ($binary -join "").Replace('0','').Length

Write-Host "Mask in Length: $prefixLength"

$adapter = "Ethernet"  
# IP and Mask and Gate
Get-NetIPAddress -InterfaceAlias $adapter -IPAddress $IP -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false
New-NetIPAddress -InterfaceAlias $adapter -IPAddress $IP -PrefixLength $prefixLength -DefaultGateway $Gate

# Set default gateway
#New-Netroute -InterfaceAlias $adapter -NextHop $Gate -destinationprefix "0.0.0.0/0" -confirm:$false

# Set DNS server
$DNS_Server = $IP
Set-DnsClientServerAddress -InterfaceAlias $adapter -ServerAddresses $($DNS_Server, "8.8.8.8")

$ZoneName = "plskys.com"
$ZoneFile = "plskys.com.DNS"
Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile $ZoneFile -DynamicUpdate NonsecureAndSecure

$OctetsforRev = $IP -split '\.'
$ReverseIP = "$($OctetsforRev[2]).$($OctetsforRev[1]).$($OctetsforRev[0])"
$ReverseZone = $ReverseIP + ".in-addr.arpa"
$WorkID = "$($OctetsforRev[0]).$($OctetsforRev[1]).$($OctetsforRev[2])" + ".0" + "/" + $prefixLength
Write-Host "ReverseIP: $ReverseIP"
Write-Host "ReverseZone: $ReverseZone"
Write-Host "WorkID : $WorkID "
Add-DnsServerPrimaryZone -NetworkID $WorkID  -ZoneFile $ReverseZone

$ARecordName = "host1"
Add-DnsServerResourceRecordA -Name $ARecordName -ZoneName $ZoneName -AllowUpdateAny -IPv4Address $DNS_Server

Read-Host "press anything to continue(debug)"
Resolve-DnsName host1.plskys.com
ping google.com

