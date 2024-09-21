set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

#execute az iot ops verify-host
execute export KEYVAULT_ID=$(az keyvault show -n $KEYVAULT_NAME -g $RESOURCE_GROUP --query id -o tsv)
execute az iot ops init \
    --cluster $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kv-id $KEYVAULT_ID \
    --ensure-latest true \
    --simulate-plc true \
    --debug
execute az iot ops check

set +euo pipefail