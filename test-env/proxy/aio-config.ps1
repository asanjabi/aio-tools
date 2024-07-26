using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
    [switch]$SetupEnv,
    [switch]$InstallAzureCLI,
    [switch]$InstallCLIExtensions,
    [switch]$Login,
    [switch]$RegisterProviders,
    [switch]$CreateAzureResources,
    [switch]$InstallK3s,
    [switch]$GetKubeConfigSettings,
    [switch]$ConnectCluster,
    [switch]$IntallAio,
    [switch]$InstallAll,
    [switch]$DeleteAzureResources,
    [switch]$Help,
    [switch]$H
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
if($InstallK3s) {
    Write-Output "Installing k3s"
    copy_and_run_script "k3s_install.sh"
}
if($GetKubeConfigSettings) {
    Write-Output "Getting kubeconfig settings"
    multipass exec $vm -- sudo cp /etc/rancher/k3s/k3s.yaml ./k3s.yaml
    multipass exec $vm -- sudo chown ubuntu:ubuntu ./k3s.yaml
    multipass transfer ${vm}:./k3s.yaml ./k3s.yaml

    $fullPath = Join-Path -Path $PWD.Path -ChildPath "k3s.yaml"
    Write-Output $fullPath
    Set-Item -Path Env:KUBECONFIG -Value $fullPath



    Remove-Item -Path Env:KUBECONFIG
    
    # mkdir ~/.kube
    # sudo KUBECONFIG=~/.kube/config:/etc/rancher/k3s/k3s.yaml kubectl config view --flatten > ~/.kube/merged
    # mv ~/.kube/merged ~/.kube/config
    # chmod  0600 ~/.kube/config
    # export KUBECONFIG=~/.kube/config
    # #switch to k3s context
    # kubectl config use-context default
}
if($ConnectCluster) {
    Write-Output "Connecting Cluster"
    copy_and_run_script "arc_connect_cluster.sh"
}
if($InstallAio) {
    Write-Output "Installing AIO"
    copy_and_run_script "aio_install.sh"
}

if($Help -or $H) {
    $usage = @"
    Following options are available, you should run them in order, and can specify multiple options at once:
    
    -SetupEnv
    -InstallK3s
    -InstallAzureCLI
    -InstallCLIExtensions
    -Login (Interacitve login to Azure)
    -RegisterProviders (Register Azure providers for your subscription, required only once per subscription)
    -CreateAzureResources
    -ConnectCluster
    -IntallAio

    Other options:
    -InstallAll (Runs all the above options)
    -DeleteAzureResources (Deletes all the Azure resources created by the script)
"@

    Write-Output "$usage"
}

Remove-Module -name tools