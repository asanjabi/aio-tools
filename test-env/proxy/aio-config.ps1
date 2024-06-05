using module "../../tools/pwsh/Tools.psm1"

param (
    [switch]$SetupEnv,
    [switch]$InstallK3s,
    [switch]$InstallAzureCLI,
    [switch]$InstallCLIExtensions,
    [switch]$Login,
    [switch]$RegisterAzureExtensions,
    [switch]$CreateAzureResources,
    [switch]$ConnectCluster,
    [switch]$IntallAio,
    [switch]$InstallAll
)

ReadVariablesFromFile ".env"
$vm = $client_vmName

function copy_script {
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
}

function copy_and_run_script {
    param (
        [string]$script
    )
    copy_script $script
    
    multipass exec $vm -- bash -c "~/scripts/$script >> ~/logs/$script.log 2>&1"
    #multipass exec $vm -- bash -c "cat ~/logs/$script.log"
}

function SetupEnv{
    Write-Output "Setting up environment"
    copy_and_run_script "setup_env.sh"
}

function InstallK3S {
    Write-Output "Installing k3s"
    copy_and_run_script "install_k3s.sh"
}

function InstallAzureCLI {
    Write-Output "Installing Azure CLI"
    copy_and_run_script "install_azure_cli.sh"
}


function InstallCLIExtensions {
    Write-Output "Installing extensions"
    copy_and_run_script "install_cli_extensions.sh"
}


function Login {
    Write-Output "Logging in"
    copy_script "login.sh"
    # Run bash interactively and run the login script
    multipass exec $vm -- bash -c 'bash -i <<< ~/scripts/login.sh'
}

function RegisterAzureExtensions {
    Write-Output "Registering Azure Extensions"
    copy_and_run_script "register_azure_extensions.sh"
}

function CreateAzureResources{
    Write-Output "Creating Azure Resources"
    copy_and_run_script "create_azure_resources.sh"
}

function ConnectCluster{
    Write-Output "Connecting Cluster"
    copy_and_run_script "connect_cluster.sh"
}
 
function InstallAio{
    Write-Output "Installing AIO"
    copy_and_run_script "install_aio.sh"
}
if($SetupEnv) {
    Write-Output "Setting up environment"
    SetupEnv
}
if($InstallK3s) {
    Write-Output "Installing k3s"
    InstallK3S
}
if($InstallAzureCLI) {
    Write-Output "Installing Azure CLI"
    InstallAzureCLI
}
if($InstallCLIExtensions) {
    Write-Output "Installing CLI Extensions"
    InstallCLIExtensions
}
if($Login) {
    Write-Output "Logging in"
    Login
}
if($RegisterAzureExtensions) {
    Write-Output "Registering Azure Extensions"
    RegisterAzureExtensions
}
if($CreateAzureResources) {
    Write-Output "Creating Azure Resources"
    CreateAzureResources
}
if($ConnectCluster) {
    Write-Output "Connecting Cluster"
    ConnectCluster
}
if($IntallAio) {
    Write-Output "Installing AIO"
    InstallAio
}
if ($InstallAll) {
    SetupEnv
    InstallK3S
    InstallAzureCLI
    InstallCLIExtensions
    Login
    RegisterAzureExtensions
    CreateAzureResources
    ConnectCluster
    InstallAio
}

Remove-Module -name tools