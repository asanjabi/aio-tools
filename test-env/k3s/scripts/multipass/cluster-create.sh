  
#!/bin/bash
set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

#get script directory
script_dir=$(dirname $0)
source $script_dir/utilities.sh

multipass_path=$(get_multipass_path)
cloudInit_path=$(convert_path $cloudInit_path)


# Create a new VM with the specified name, CPU, memory, disk size, and cloud-init file
write-info "creating VM $aio_vmName"
execute $multipass_path launch 22.04 --name $aio_vmName -c 8 -m 16G -d 20G --cloud-init $cloudInit_path
set +euo pipefail

# Set up the VM to forward packets
# need to run these as admin in powershell
# Set-NetIPInterface -ifAlias "vEthernet (WSL (Hyper-V firewall))" -Forwarding Enabled
# Set-NetIPInterface -ifAlias "vEthernet (Default Switch)" -Forwarding Enabled