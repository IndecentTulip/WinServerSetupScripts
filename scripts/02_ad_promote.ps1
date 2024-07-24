Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

Import-Module ADDSDeployment

# HAVE A GOOD PASSWORD, OR IT WILL NOT RUN

Install-ADDSForest `
    -DomainName "TechProSolutions.com" `
    -DomainNetbiosName "TECHPRO" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns `
    -NoRebootOnCompletion

Restart-Computer -Force
