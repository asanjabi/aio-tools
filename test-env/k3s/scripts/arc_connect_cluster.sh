set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh



# Check if connected cluster exists
if az connectedk8s show -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    write-info "Connected cluster $CLUSTER_NAME already exists. Deleting it."
    # Delete the connected cluster
    execute az connectedk8s delete -n $CLUSTER_NAME -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --yes
fi

execute az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID \
    --debug  

execute kubectl get deployments,pods -n azure-arc

execute export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
execute az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

set +euo pipefail