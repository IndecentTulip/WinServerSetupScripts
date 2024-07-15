# Function to install Windows feature and handle reboot
function Install-WindowsFeatureWithReboot {
    param (
        [string]$FeatureName
    )

    Install-WindowsFeature -Name $FeatureName -IncludeManagementTools -Restart
}

Install-WindowsFeatureWithReboot -FeatureName "AD-Domain-Services"

Install-WindowsFeatureWithReboot -FeatureName "DHCP"

Install-WindowsFeatureWithReboot -FeatureName "DNS"

Install-WindowsFeatureWithReboot -FeatureName "FS-FileServer"


Restart-Computer -Force

