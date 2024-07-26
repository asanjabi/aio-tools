set -exuo pipefail

source ~/.env

# Check if connected cluster exists
if az connectedk8s show -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    echo "Connected cluster $CLUSTER_NAME already exists. Deleting it."
    # Delete the connected cluster
    az connectedk8s delete -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --yes
fi

az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID \
    --debug  

kubectl get deployments,pods -n azure-arc

export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

set +exuo pipefail