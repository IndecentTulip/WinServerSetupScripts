# Function to install Windows feature and handle reboot
function Install-WindowsFeatureWithReboot {
    param (
        [string]$FeatureName
    )

    Install-WindowsFeature -Name $FeatureName -IncludeManagementTools -Restart
}

# Install Active Directory Domain Services
Install-WindowsFeatureWithReboot -FeatureName "AD-Domain-Services"

# Install DHCP Server
Install-WindowsFeatureWithReboot -FeatureName "DHCP"

# Install DNS Server
Install-WindowsFeatureWithReboot -FeatureName "DNS"

# Install FTP Server (using IIS role)
Install-WindowsFeatureWithReboot -FeatureName "Web-Server"

# After all installations complete, script execution continues here
Write-Output "All features installed. Server will now reboot."

# You can optionally add a delay or sleep command here if needed
# Start-Sleep -Seconds 30

# Force a reboot
Restart-Computer -Force

