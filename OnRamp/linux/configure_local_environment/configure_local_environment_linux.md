# Configuring your local environment (WSL)

## 1. Install Azure CLI

Easiest way to install Azure CLI in your WSL environment is to run the all in one script:

```bash
if ! command -v az &>/dev/null; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi
```

If you already have Azure CLI installed, it's a good idea to make sure you have the latest version.

```bash
sudo apt-get update
sudo apt-get install --only-upgrade azure-cli
```

If you run into issues installing Azure CLI see look at this document [Troubleshooting Azure CLI Installation](linux/configure_local_environment/troubleshoot_Azure_CLI_Install_linux.md)

## 2. Install Required Azure CLI extensions

Log the current version of installed extensions and Azure CLI

```bash
az --version
az extension list --output table
```

```bash
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
    az extension add --name "$1" --upgrade --allow-preview true
}

# install_azure_cli_extension connectedk8s
install_azure_cli_extension azure-iot-ops
install_azure_cli_extension customlocation
install_azure_cli_extension k8s-extension
```

Log the final version of installed extensions and Azure CLI

```bash
az --version
az extension list --output table
```

## 3. Install kubectl

Install kubectl if it is not installed

```bash
if ! command -v kubectl &>/dev/null; then
    sudo snap install kubectl --classic
    echo "kubectl installed"
    else
    echo "kubectl already installed"
fi
```

Optional but highly recommended
Update your .bashrc file to for auto complete and and setup some convenient aliases

```bash
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
```

## 4. Install k9s (optional but highly recommended)

```bash
if ! command -v k9s &>/dev/null; then
    sudo snap install k9s
    #bug in installer
    sudo ln -s /snap/k9s/current/bin/k9s /usr/bin
fi
```
