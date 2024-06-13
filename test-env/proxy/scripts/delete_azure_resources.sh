set -exuo pipefail

source ~/.env
source ~/proxy_env


if az group show --name $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID &>/dev/null; then
    az group delete --name $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --yes
    echo "Resource group $RESOURCE_GROUP deleted."
fi
  
set +exuo pipefail