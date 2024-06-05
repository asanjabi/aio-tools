using module "../../tools/pwsh/Tools.psm1"

param (
    [switch]$Create,
    [switch]$Delete,
    [switch]$Rebuild
)

ReadVariablesFromFile ".env"


$vm = $client_vmName

function copy_and_run_script {
    param (
        [string]$script
    )
    multipass exec $vm -- mkdir -p logs
    multipass exec $vm -- mkdir -p scripts
    multipass transfer ./.env ${vm}:.
    multipass transfer ./scripts/$script ${vm}:./scripts/$script
    multipass exec $vm -- bash -c "vim ~/.env -c ""set ff=unix"" -c "":wq"""
    multipass exec $vm -- bash -c "vim ~/scripts/$script -c ""set ff=unix"" -c "":wq"""
    multipass exec $vm -- bash -c "chmod +x ~/scripts/$script"
    
    multipass exec $vm -- bash -c "~/scripts/$script >> ~/logs/$script.log 2>&1"
}

function CreateVm {
    Write-Output "Creating VM $vm"
    multipass launch 22.04 --name $vm -c 8 -m 16G -d 20G

    # copy the proxy certificate over to the client
    multipass transfer ${certfile_der} ${vm}:.  
    
    copy_and_run_script "setup_client_vm.sh"
}

function DeleteVm {
    Write-Output "Deleting VM $vm"
    multipass delete $vm
    multipass purge
}

function RebuildVm {
    Write-Output "Rebuilding VM $vm"
    DeleteVm
    CreateVm
}

if ($Create) {
    CreateVm
}
elseif ($Delete) {
    DeleteVm
}
elseif ($Rebuild) {
    RebuildVm
}
else {
    Write-Output "Usage: client.ps1 -Create | -Delete | -Rebuild"
}


Remove-Module -name tools