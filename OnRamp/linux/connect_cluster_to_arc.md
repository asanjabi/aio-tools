# Arc enable your cluster

For more information about this process refer to: https://learn.microsoft.com/en-us/azure/iot-operations/deploy-iot-ops/howto-prepare-cluster?tabs=ubuntu

For preview we need to install an update connectedk8s extension.  Remove old extension and install this one.

```bash
# Special preview path
az --version
az extension list --output table

az extension remove --name connectedk8s
curl -L -o connectedk8s-1.10.0-py2.py3-none-any.whl https://github.com/AzureArcForKubernetes/azure-cli-extensions/raw/refs/heads/connectedk8s/public/cli-extensions/connectedk8s-1.10.0-py2.py3-none-any.whl   
az extension add --upgrade --source connectedk8s-1.10.0-py2.py3-none-any.whl
rm connectedk8s-1.10.0-py2.py3-none-any.whl

az --version
az extension list --output table
```

Create the resource group we are landing in

```bash
env_file_path="../.env"
source $env_file_path

if az group show --name $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    echo "Resource group $RESOURCE_GROUP already exists."
else
    echo "Creating resource group $RESOURCE_GROUP..."
    az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
    echo "Resource group $RESOURCE_GROUP created."
fi
```

Check to see if the cluster resource exists, if so delete it

```bash
if az connectedk8s show -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    echo "Connected cluster $CLUSTER_NAME already exists. Deleting it."
    # Delete the connected cluster
    echo az connectedk8s delete -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --yes
fi
```

Connect the cluster

```bash
source ../.env
az connectedk8s connect --name $CLUSTER_NAME -l $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --enable-oidc-issuer --enable-workload-identity --debug
kubectl get deployments,pods -n azure-arc
```

Get the cluster's issuer URL

```bash
source ../.env
export issuer_rul=$(az connectedk8s show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query oidcIssuerProfile.issuerUrl --output tsv)
echo "issuer_rul: $issuer_rul"
echo "paste this into your /etc/rancher/k3s/config.yaml file"
echo "
kube-apiserver-arg:
  - service-account-issuer=$issuer_rul
  - service-account-max-token-expiration=24h
"
```

Update the configuration see also: https://docs.k3s.io/installation/configuration
This is not scripted yet for now use the script [here](./create_cluster/multipass/handy_multipass_scripts.md) to connect to your cluster and modify the /etc/rancher/k3s/config.yaml based on instruction on step 8 here: https://learn.microsoft.com/en-us/azure/iot-operations/deploy-iot-ops/howto-prepare-cluster?tabs=ubuntu

Run the script below and copy teh snippet it generates.  
When connected run   
```sudo nano /etc/rancher/k3s/config.yam```  
Add the snippet in and save and exit.  
Don't forget to restart k3s:  
```sudo systemctl restart k3s```

```bash
echo "kube-apiserver-arg:
  - service-account-issuer=$issuer_rul
  - service-account-max-token-expiration=24h
"
```

Get the objectId of the Microsoft Entra ID application that the Azure Arc service uses in your tenant and save it as an environment variable.

```bash
export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations
```