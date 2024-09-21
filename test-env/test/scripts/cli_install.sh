set -exuo pipefail

source ~/.env

############################################
# Install Azure CLI
############################################
# use the step by step process just incase the script fails, it would be easier to debug
# Alternatively you can just run the following command:
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# see https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
# Get packages needed for installation process
sudo apt-get update
sudo NEEDRESTART_MODE=a apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

# Download and install the Microsoft signing key
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

#Add the Azure CLI software repository
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources

############################################
# Install the Azure CLI
############################################
sudo apt-get update
sudo NEEDRESTART_MODE=a apt-get install azure-cli -y


############################################
# Increase default timeout for pip installs to make sure we don't time out on slow connections
# some environments may need this to be set to a higher value
# Also see https://pip.pypa.io/en/stable/topics/configuration/
############################################
grep -qxF 'export PIP_DEFAULT_TIMEOUT' ~/.bashrc || echo 'export PIP_DEFAULT_TIMEOUT=100' >> ~/.bashrc
export PIP_DEFAULT_TIMEOUT=100

############################################
# Install required extensions
############################################
az extension add --name connectedk8s
az extension add --name azure-iot-ops
az extension add --name customlocation
az extension add --name k8s-extension

# Take a snapshot for logs
az --version

set +exuo pipefail