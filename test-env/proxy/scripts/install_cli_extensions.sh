set -exuo pipefail

source ~/.env
source ~/proxy_env
az extension add --name connectedk8s
az extension add --name azure-iot-ops
az extension add --name customlocation
az extension add --name k8s-extension

set +exuo pipefail