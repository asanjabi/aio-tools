#Install k3s, source the additional_env file to set the proxy settings first
set -exuo pipefail

source ~/.env

echo "Installing k3s using quick install script"
curl -sfL https://get.k3s.io | sh -

# write this to logs so that we can see the environment variables that were set
sudo cat /etc/systemd/system/k3s.service.env

# Copy the kubeconfig file to the user's home directory
mkdir -p ~/.kube
sudo cp -f /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
chmod  0600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# Add KUBECONFIG to .bashrc if it doesn't exist
if ! grep -q "export KUBECONFIG=~/.kube/config" ~/.bashrc; then
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
fi

############################################
# Wait for kube-system pods to be ready
############################################
namespace="kube-system"
timeout="10m"

# Check Kubernetes client version
client_version=$(kubectl version --client | awk '{print $3}')
required_version="v1.31.0"

if [[ "$(printf '%s\n' "$client_version" "$required_version" | sort -V | head -n1)" != "$required_version" ]]; then
    echo "This client doesn't support wait --for=create Waiting for 60 seconds instead."
    sleep 60
else
    kubectl wait --for=create pod -l k8s-app=kube-dns -n $namespace --timeout=$timeout
    kubectl wait --for=create pod -l k8s-app=metrics-server -n $namespace --timeout=$timeout
    kubectl wait --for=create pod -l app=local-path-provisioner -n $namespace --timeout=$timeout
fi


kubectl wait --for=condition=ready pod -l k8s-app=kube-dns -n $namespace --timeout=$timeout
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n $namespace --timeout=$timeout
kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n $namespace --timeout=$timeout

set +exuo pipefail