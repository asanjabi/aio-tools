source ~/.env
source ~./bashrc
az iot ops verify-host
az keyvault create --enable-rbac-authorization false --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP
export KEYVAULT_ID=$(az keyvault show -n $KEYVAULT_NAME -g $RESOURCE_GROUP --query id -o tsv); az iot ops init --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP --kv-id $KEYVAULT_ID
az iot ops check