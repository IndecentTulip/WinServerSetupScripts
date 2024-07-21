Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "plskys.com" `
    -DomainNetbiosName "PLSKYS" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns `
    -NoRebootOnCompletion

Restart-Computer -Force
