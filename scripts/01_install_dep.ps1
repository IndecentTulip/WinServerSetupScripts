Rename-Computer DCTechProSolutions01

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
