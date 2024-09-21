#!/bin/bash
set -euo pipefail

source $tools_dir/functions.sh
source $tools_dir/console.sh


echo -e "${COLOR_YELLOW}"
echo ""
echo "Installing required tools..."
echo "This script will install or update the following tools:"
echo "1. Azure CLI"
echo "2. Azure Developer CLI"
echo "3. Required Azure CLI Extensions"
echo "4. kubectl"
echo "5. k9s"
echo -e "${COLOR_NC}"

read -p "Do you want to continue? (y/n): " choice
if [[ $choice == "n" ]]; then
    exit 0
fi


install_azure_cli
install_azd

install_azure_cli_extension connectedk8s
install_azure_cli_extension azure-iot-ops
install_azure_cli_extension customlocation
install_azure_cli_extension k8s-extension

install_kubectl
install_k9s

az --version
az extension list --output table
azd --version

set +euo pipefail
