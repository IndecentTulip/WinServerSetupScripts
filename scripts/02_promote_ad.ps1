Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "plskys.com" `
    -DomainNetbiosName "PLSKYS" `
    -DomainMode "WinThreshold" `
    -ForestMode "WinThreshold" `
    -InstallDNS `
    -NoRebootOnCompletion

