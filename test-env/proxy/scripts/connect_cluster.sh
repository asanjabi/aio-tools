set -exuo pipefail

source ~/.env
source ~/proxy_env

# Connect the cluster to Azure Arc
# When using proxy server, you need to specify the proxy server IP address and port, and optionally the IP ranges to exclude from the proxy server.
# If the proxy server requires a certificate, you can specify the path to the certificate file.
# The following example shows how to connect a cluster to Azure Arc using a proxy server:
# See https://learn.microsoft.com/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli#connect-using-an-outbound-proxy-server
#az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-https https://<proxy-server-ip-address>:<port> --proxy-http http://<proxy-server-ip-address>:<port> --proxy-skip-range <excludedIP>,<excludedCIDR> --proxy-cert <path-to-cert-file>

control_plane_ip=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk -F'//' '{print $2}' | awk -F':' '{print $1}')
kubernetes_service_ip=$(kubectl get svc kubernetes -o jsonpath='{.spec.clusterIP}')
echo "Control Plame IP: $control_plane_ip"
echo "Kubernetes Service IP: $kubernetes_service_ip"

az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID \
    --proxy-https $https_proxy --proxy-http $http_proxy \
    --proxy-skip-range $control_plane_ip,$kubernetes_service_ip,127.0.0.0/16 \
    --proxy-cert $certfile_crt \
    --debug
  

kubectl get deployments,pods -n azure-arc

export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

set +exuo pipefail