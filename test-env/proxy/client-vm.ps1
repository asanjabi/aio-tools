using module "../../tools/pwsh/Tools.psm1"

[CmdletBinding()]
param (
    [switch]$Create,
    [switch]$Configure,
    [switch]$Delete,
    [switch]$Rebuild,
    [string]$CloudInitFile = $null
)

ReadVariablesFromFile ".env"


$vm = $client_vmName
$cloudInit = $client_cloudInit

if($CloudInitFile -ne $null -and $CloudInitFile -ne '') {
    $cloudInit = $CloudInitFile
}

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
    
    #multipass exec $vm -- bash -c "~/scripts/$script >> ~/logs/$script.log 2>&1"
    multipass exec $vm -- bash -c "bash -i <<< ""~/scripts/$script 2>&1 | tee ~/logs/$script.log """
}

function CreateVm {
    Write-Output "Creating VM $vm"

    $ci_segment=""
    if($null -ne $cloudInit) {
        # $ci_segment = "----cloud-init $cloudInit"
        multipass launch 22.04 --name $vm -c 8 -m 16G -d 20G --cloud-init $cloudInit
    }else{
        multipass launch 22.04 --name $vm -c 8 -m 16G -d 20G $ci_segment
    }
}

function ConfigureVM {
    Write-Output "copying the proxy certificate over to the client"
    multipass transfer ${certfile_der} ${vm}:.  
    
    Write-Output "Running setup_client_vm.sh script on the client VM"
    copy_and_run_script "client_vm_configure.sh"
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
    ConfigureVM
}

if ($Create) {
    CreateVm
}

if ($Configure) {
    ConfigureVM
}

if ($Delete) {
    DeleteVm
}

if ($Rebuild) {
    RebuildVm
}

if($Create -eq $false -and $Configure -eq $false -and $Delete -eq $false -and $Rebuild -eq $false) {
    Write-Output "Usage: client.ps1 -Create | -Delete | -Rebuild"
}


Remove-Module -name tools