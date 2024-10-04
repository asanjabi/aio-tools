If you run into errors using the script above, you can run the steps from the script one at a time to help you troubleshoot the installation for more details you can refere to this document: https://learn.microsoft.com/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions

* First install packages needed for installation process

```bash {"excludeFromRunAll":"true","id":"01J9879M2PCWXQ3TX6698TJJ3P"}
    sudo apt-get update
    sudo NEEDRESTART_MODE=a apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
```

* Download and install the Microsoft signing key

```bash {"excludeFromRunAll":"true","id":"01J987FD2C5TCYM6YVGHM0TE33"}
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /etc/apt/keyrings/microsoft.gpg
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
```

* Add the Azure CLI software repository

```bash {"excludeFromRunAll":"true","id":"01J987H6G8BPPHKHFQWVTW9M8W"}
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
```

* Finally install Azure CLI

```bash {"id":"01J987MPD6NBNSR4XZRKSP3175"}
sudo apt-get update
sudo NEEDRESTART_MODE=a apt-get install azure-cli -y
```
