using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
    [switch]$SetupEnv,
    [switch]$InstallK3s,
    [switch]$InstallAzureCLI,
    [switch]$InstallCLIExtensions,
    [switch]$Login,
    [switch]$RegisterProviders,
    [switch]$CreateAzureResources,
    [switch]$ConnectCluster,
    [switch]$IntallAio,
    [switch]$InstallAll,
    [switch]$DeleteAzureResources
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
    
    multipass exec $vm -- bash -c "bash -i <<< ""~/scripts/$script 2>&1 | tee ~/logs/$script.log """
}


if ($InstallAll) {
    $SetupEnv = $true
    $InstallK3s = $true
    $InstallAzureCLI = $true
    $InstallCLIExtensions = $true
    $Login = $true
    $RegisterProviders = $true
    $CreateAzureResources = $true
    $ConnectCluster = $true
    $InstallAio = $true
}

if ($DeleteAzureResources) {
    Write-Output "Deleting Azure Resources"
    copy_and_run_script "azure_delete_resources.sh"
}

if($SetupEnv) {
    Write-Output "Setting up environment"
    copy_and_run_script "env_setup.sh"
}
if($InstallK3s) {
    Write-Output "Installing k3s"
    copy_and_run_script "k3s_install.sh"
}
if($InstallAzureCLI) {
    Write-Output "Installing Azure CLI"
    copy_and_run_script "cli_install.sh"
}
if($InstallCLIExtensions) {
    Write-Output "Installing extensions"
    copy_and_run_script "cli_extensions_install.sh"
}
if($Login) {
    Write-Output "Logging in"
    copy_and_run_script "azure_login.sh"
}
if($RegisterProviders) {
    Write-Output "Registering Azure Extensions"
    copy_and_run_script "azure_subscription_register_providers.sh"
}
if($CreateAzureResources) {
    Write-Output "Creating Azure Resources"
    copy_and_run_script "azure_create_resources.sh"
}
if($ConnectCluster) {
    Write-Output "Connecting Cluster"
    copy_and_run_script "arc_connect_cluster.sh"
}
if($InstallAio) {
    Write-Output "Installing AIO"
    copy_and_run_script "aio_install.sh"
}

Remove-Module -name tools