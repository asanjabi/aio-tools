#!/bin/bash
set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

login_azure_cli_device_code $TENANT_ID $SUBSCRIPTION_ID

providers=(
    "Microsoft.Compute"
    "Microsoft.Keyvault"
    "Microsoft.Network"
    "Microsoft.ExtendedLocation"
    "Microsoft.Kubernetes"
    "Microsoft.KubernetesConfiguration"
    "Microsoft.IoTOperationsOrchestrator"
    "Microsoft.IoTOperations"
    "Microsoft.DeviceRegistry")

register_resource_providers "${providers[@]}"

set +euo pipefail
