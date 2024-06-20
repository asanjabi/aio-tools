set -exuo pipefail

source ~/.env
source ~/additional_env

# see https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
# Get packages needed for installation process
sudo apt-get update
sudo NEEDRESTART_MODE=a apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

# Download and install the Microsoft signing key
sudo mkdir -p /etc/apt/keyrings
bash -c 'source additional_env; curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg'
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

# Configure Azure CLI to use the proxy

# make a copy of the certificate bundle for Azure CLI
find /opt/az/lib/*/site-packages/certifi -name cacert.pem -exec cp ""{}"" ~/ \;
# append the proxy's certificate to the certificate bundle
cat $certfile_crt >> ~/cacert.pem
# Add the new certificate bundle for Azure CLI to the proxy environment settings
echo export REQUESTS_CA_BUNDLE=~/cacert.pem >> ~/additional_env


# Increase default timeout for pip installs since using proxy can slow down the process
# some environments may need this to be set to a higher value
echo export PIP_DEFAULT_TIMEOUT=100 >> ~/additional_env


set +exuo pipefail