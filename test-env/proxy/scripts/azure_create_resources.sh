set -exuo pipefail

source ~/.env
source ~/additional_env

if az group show --name $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    echo "Resource group $RESOURCE_GROUP already exists."
else
    echo "Creating resource group $RESOURCE_GROUP..."
    az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
    echo "Resource group $RESOURCE_GROUP created."
fi

if az keyvault show --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo "Key vault $KEYVAULT_NAME already exists."
else
    if az keyvault show-deleted --name $KEYVAULT_NAME; then
        echo "Purging key vault $KEYVAULT_NAME..."
        az keyvault purge --name $KEYVAULT_NAME
        echo "Key vault $KEYVAULT_NAME purged."
    else
        echo "Key vault $KEYVAULT_NAME does not exist."
    fi
    az keyvault create --enable-rbac-authorization false --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP
    echo "Key vault $KEYVAULT_NAME created."
fi

set +exuo pipefail