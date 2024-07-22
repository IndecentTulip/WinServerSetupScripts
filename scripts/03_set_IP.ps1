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
Set-DnsClientServerAddress -InterfaceAlias $adapter -ServerAddresses $DNS_Server


