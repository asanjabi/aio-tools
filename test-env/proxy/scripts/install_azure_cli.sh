set -exuo pipefail

source ~/.env
source ~/proxy_env

# see https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
# Get packages needed for installation process
sudo apt-get update
sudo NEEDRESTART_MODE=a apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

# Download and install the Microsoft signing key
sudo mkdir -p /etc/apt/keyrings
bash -c 'source proxy_env; curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg'
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
# Prepare the certificate bundle for Azure CLI
~/setup_az_cli_cert.sh


set +exuo pipefail