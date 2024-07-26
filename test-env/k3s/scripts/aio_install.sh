set -exuo pipefail

source ~/.env

az iot ops verify-host
export KEYVAULT_ID=$(az keyvault show -n $KEYVAULT_NAME -g $RESOURCE_GROUP --query id -o tsv)
az iot ops init \
    --cluster $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kv-id $KEYVAULT_ID \
    --ensure-latest true \
    --simulate-plc true \
    --debug
az iot ops check

set +exuo pipefail