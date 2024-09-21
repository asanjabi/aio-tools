# # Run this as administrator to configure the switches for WSL and Multipass
# Get-NetIPInterface | where {$_.InterfaceAlias -eq 'vEthernet (WSL)' -or $_.InterfaceAlias -eq 'vEthernet (K8s-Switch)'} | Set-NetIPInterface -Forwarding Enabled
# get-vm | where-object -p Name -eq 'alice-1' | get-vmnetworkadapter | where-object -p SwitchName -eq 'multipass' | Set-VMNetworkAdapter -Devicenaming on

# Set up the VM to forward packets
# need to run these as admin in powershell
Set-NetIPInterface -ifAlias "vEthernet (WSL (Hyper-V firewall))" -Forwarding Enabled
Set-NetIPInterface -ifAlias "vEthernet (Default Switch)" -Forwarding Enabled
# more details
#https://serverfault.com/questions/929081/how-can-i-enable-packet-forwarding-on-windows

# Get a list of all interfaces
#Get-NetIPInterface | select ifIndex,InterfaceAlias,AddressFamily,ConnectionState,Forwarding | Sort-Object -Property IfIndex | Format-Table
