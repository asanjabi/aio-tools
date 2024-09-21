
cleanup() {
    echo "Cleaning up"
    set +exuo pipefail
}

setup_debug() {
    if [ -z "$log_file" ]; then
        export log_file="$project_dir/$(date +"%Y-%m-%d-%H-%M-%S")-aio.log"
    fi
    
    exec 1> >(tee -a $log_file)
    exec 5> $log_file
    BASH_XTRACEFD="5"

    PS4='$(basename ${BASH_SOURCE}):${LINENO}: '
    set -x
    trap cleanup ERR EXIT
}

execute(){
    #read all the parameters as an array and then execute the command
    local command=("$@")
    echo "${command[@]}"
    eval '${command[@]}'
}

get_project_cube_config_Path() {
    echo "$project_dir/kube/config"
}

set_project_cube_config_environment_var() {
    local cfg_full_path=$(get_project_cube_config_Path)
    export KUBECONFIG=$cfg_full_path
}

# Install Azure Developer CLI
install_azd() {
    curl -fsSL https://aka.ms/install-azd.sh | bash
}

install_azure_cli() {
    # use the step by step process just incase the script fails, it would be easier to debug
    # Alternatively you can just run the following command:
    # curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # see https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
    # Get packages needed for installation process
    sudo apt-get update
    sudo NEEDRESTART_MODE=a apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

    # Download and install the Microsoft signing key
    sudo mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /etc/apt/keyrings/microsoft.gpg
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

    #Add the Azure CLI software repository
    AZ_DIST=$(lsb_release -cs)
    echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources

    # Install the Azure CLI
    sudo apt-get update
    sudo NEEDRESTART_MODE=a apt-get install azure-cli -y
}

install_azure_cli_extension() {
    # Check if parameter was passed in
    if [ -z "$1" ]; then
        echo "Please provide the name of the Azure CLI extension to install"
        return
    fi

    # Check if az is installed
    if ! command -v az &>/dev/null; then
        echo "az command not found, please install Azure CLI first"
        return
    fi

    # Install the Azure CLI extension or upgrade to latest
    echo "Installing extension $1"
    az extension add --name "$1" --upgrade
}

login_azure_cli_device_code() {
    # Check if parameters were passed in
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please provide the tenant ID and subscription ID"
        return
    fi

    # Check if user is already logged in and has access to the subscription ID
    if az account show &>/dev/null; then
        echo "User is already logged in"
        current_tenant=$(az account show --query 'tenantId' -o tsv)
        if [ "$current_tenant" == "$1" ]; then
            echo "User has access to the specified tenant ID"
        else
            echo "Lets login again"
            az login --use-device-code --tenant "$1"
        fi
    else
        echo "User is not logged in"
        az login --use-device-code --tenant "$1"
    fi

    az account set --subscription "$2"
}

register_resource_providers() {
    # Check if az is installed
    if ! command -v az &>/dev/null; then
        write-error "az command not found, please install Azure CLI first"
        return
    fi

    providers=("$@")

    # Check if resource providers array is empty
    if [ ${#providers[@]} -eq 0 ]; then
        write-error "No resource providers specified"
        return
    fi

    # Loop through the resource providers array and start registering them
    for provider in "${providers[@]}"; do
        write-info "Registering resource provider: $provider"
        execute az provider register --namespace "$provider"
    done

    # Now wait for all the resource providers to be registered
    for provider in "${providers[@]}"; do
        write-info  "Waiting for $provider to register"
        execute az provider register --namespace "$provider" --wait
    done
}

install_kubectl() {
    if ! command -v kubectl &>/dev/null; then
        execute sudo snap install kubectl --classic
    fi

    # Add kubectl completion to bashrc
    if ! grep -q "# Kubernetes config" ~/.bashrc; then
        cat <<EOF >>~/.bashrc

# Kubernetes config
if command -v kubectl &> /dev/null; then
    alias k=$(command -v kubectl)
    source <(kubectl completion bash)
    source <(kubectl completion bash | sed s/kubectl/k/g)

    alias kcd='kubectl config set-context $(kubectl config current-context) --namespace '
    #export KUBE_EDITOR='code --wait'
    export KUBE_EDITOR='nano'
fi
EOF
    fi
}

install_k9s() {
    if ! command -v k9s &>/dev/null; then
        execute sudo snap install k9s
        #bug in installer
        execute sudo ln -s /snap/k9s/current/bin/k9s /usr/bin
    fi
}
