using module "../../tools/pwsh/Tools.psm1"

[CmdletBinding()]
param (
    [string]$CloudInitFile = $null,

    [switch]$DeleteAzureResources,
    [switch]$DeleteVm,
    [switch]$CreateVM,
    [switch]$ConfigureVM,
    [switch]$InstaAzureCli,
    [switch]$Login,
    [switch]$CreateAzureResources,
    [switch]$InstallK3s,
    [switch]$ConnectArc,
    [switch]$InstallAIO,
    [switch]$Rebuild,
    [switch]$DoAllTheThings
)

ReadVariablesFromFile ".env"

$vm = $aio_vmName
$cloudInit = $cloudInit_path

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
    
    multipass exec $vm -- bash -c "bash -i <<< ""~/scripts/$script 2>&1 | tee ~/logs/$script.log """
}

if($DoAllTheThings) {
    $DeleteVm = $true
    $DeleteAzureResources = $true
    $CreateVM = $true
    $ConfigureVM = $true
    $InstaAzureCli = $true
    $Login = $true
    $CreateAzureResources = $true
    $InstallK3s = $true
    $ConnectArc = $true
    $InstallAIO = $true
}

if ($Rebuild) {
    Write-Information "Rebuilding VM $vm"
    $DeleteVm = $true
    $CreateVM = $true
    $ConfigureVM = $true
    $InstaAzureCli = $true
}

if($DeleteAzureResources) {
    Write-Information "Running azure_delete_resources.sh script on the client VM"
    copy_and_run_script "azure_delete_resources.sh"
}

if ($DeleteVm){
    Write-Information "Deleting VM $vm"
    multipass delete $vm
    multipass purge
}

if($CreateVM){
    Write-Information "Creating VM $vm"

    if($null -ne $cloudInit) {
        multipass launch 22.04 --name $vm -c 8 -m 16G -d 20G --cloud-init $cloudInit
    }else{
        multipass launch 22.04 --name $vm -c 8 -m 16G -d 20G
    }
}

if($ConfigureVM) {
    Write-Information "Running setup_client_vm.sh script on the client VM"
    copy_and_run_script "env_setup.sh"
}

if($InstaAzureCli) {
    Write-Information "Running azure_cli_install.sh script on the client VM"
    copy_and_run_script "cli_install.sh"
}

if($Login) {
    Write-Information "Running azure_login.sh script on the client VM"
    copy_and_run_script "azure_login_device_code.sh"
}

if($CreateAzureResources) {
    Write-Information "Running azure_create_resources.sh script on the client VM"
    copy_and_run_script "azure_create_resources.sh"
}

if($InstallK3s) {
    Write-Information "Running k3s_install.sh script on the client VM"
    copy_and_run_script "k3s_install.sh"
}

if($ConnectArc) {
    Write-Information "Running arc_connect_cluster.sh script on the client VM"
    copy_and_run_script "arc_connect_cluster.sh"
}

if ($InstallAIO) {
    Write-Information "Running aio_install.sh script on the client VM"
    copy_and_run_script "aio_install.sh"
}

Remove-Module -name tools