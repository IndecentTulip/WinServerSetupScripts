Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "TechProSolutions.com" `
    -DomainNetbiosName "TechProSolutions" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns `
    -NoRebootOnCompletion

Restart-Computer -Force
