set -exuo pipefail

source ~/.env
source ~/proxy_env
az provider register -n "Microsoft.ExtendedLocation" --wait
az provider register -n "Microsoft.Kubernetes" --wait
az provider register -n "Microsoft.KubernetesConfiguration" --wait
az provider register -n "Microsoft.IoTOperationsOrchestrator" --wait
az provider register -n "Microsoft.IoTOperationsMQ" --wait
az provider register -n "Microsoft.IoTOperationsDataProcessor" --wait
az provider register -n "Microsoft.DeviceRegistry" --wait


set +exuo pipefail