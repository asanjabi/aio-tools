set -euo pipefail

source $tools_dir/functions.sh
source $tools_dir/console.sh

if az group show --name $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    write-info "Resource group $RESOURCE_GROUP already exists."
else
    write-info "Creating resource group $RESOURCE_GROUP..."
    execute az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
    write-info "Resource group $RESOURCE_GROUP created."
fi

if az keyvault show --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    write-info "Key vault $KEYVAULT_NAME already exists."
else
    if az keyvault show-deleted --name $KEYVAULT_NAME; then
        write-info "Purging key vault $KEYVAULT_NAME..."
        execute az keyvault purge --name $KEYVAULT_NAME
        write-info "Key vault $KEYVAULT_NAME purged."
    else
        write-info "echo Key vault $KEYVAULT_NAME does not exist."
    fi
    execute az keyvault create --enable-rbac-authorization false --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP
    write-info "Key vault $KEYVAULT_NAME created."
fi

set +euo pipefail