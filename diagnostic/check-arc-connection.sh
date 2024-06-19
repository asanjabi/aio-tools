#bin/bash
set -euo pipefail

source ../tools/bash/validation.sh

REGION="eastus"
ARCREGION="eus"

check-url https://www.microsoft.com

# Required for the agent to connect to Azure and register the cluster.
check-url https://management.azure.com

#Data plane endpoint for the agent to push status and fetch configuration information.
check-url https://$REGION.dp.kubernetesconfiguration.azure.com

# Required to fetch and update Azure Resource Manager tokens.
check-url https://login.microsoftonline.com
check-url https://$REGION.login.microsoft.com
check-url https://login.windows.net

# Required to pull container images for Azure Arc agents.
check-url https://mcr.microsoft.com
check-url https://$REGION.data.mcr.microsoft.com


# Required to get the regional endpoint for pulling system-assigned Managed Identity certificates.
check-url https://gbl.his.arc.azure.com

# Required to pull system-assigned Managed Identity certificates.
check-url https://$ARCREGION.his.arc.azure.com

# az connectedk8s connect uses Helm 3 to deploy Azure Arc agents on the Kubernetes cluster. 
# This endpoint is needed for Helm client download to facilitate deployment of the agent helm chart.
check-url https://k8connecthelm.azureedge.net

# For Cluster Connect and for Custom Location based scenarios.
check-url https://guestnotificationservice.azure.com
###########
#check-url https://*.guestnotificationservice.azure.com
check-url https://sts.windows.net
check-url https://k8sconnectcsp.azureedge.net

# For Cluster Connect and for Custom Location based scenarios.
###########
#check-url https://*.servicebus.windows.net
sburls=$(curl -s "https://guestnotificationservice.azure.com/urls/allowlist?api-version=2020-01-01&location=$REGION")
# echo "$response" | jq -r '.[]'

echo "$response" | jq -r '.[]' | while read -r line; do
    check-url "$line"
done

# Required when Azure RBAC is configured.
check-url https://graph.microsoft.com

# Required to manage connected clusters in Azure portal.
###########
check-url https://$REGION.arc.azure.net

# Required when Cluster Connect is configured.
check-url https://$ARCREGION.obo.arc.azure.com:8084

# Required when automatic agent upgrade is enabled.
check-url https://dl.k8s.io

# Required if using Azure Arc-enabled Kubernetes extensions.
check-url https://linuxgeneva-microsoft.azurecr.io



check-url https://storage.googleapis.com/kubernetes-release/release/stable.txt
check-url https://storage.googleapis.com/kubernetes-release/release/v1.30.2/bin/linux/amd64/kubectl
check-url https://api.github.com/repos/Azure/kubelogin/releases/latest
check-url https://github.com/Azure/kubelogin/releases/download/v0.1.3/kubelogin.zip
check-url https://k8connecthelm.azureedge.net/helm/helm-v3.12.2-linux-amd64.tar.gz
check-url https://$REGION.dp.kubernetesconfiguration.azure.com/azure-arc-k8sagents/GetLatestHelmPackagePath?api-version=2019-11-01-preview&releaseTrain=stable



set +euo pipefail