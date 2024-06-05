set -exuo pipefail

source ~/.env
source ~/proxy_env
az login --use-device-code
az account set --subscription $SUBSCRIPTION_ID

set +exuo pipefail