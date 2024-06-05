#Install k3s, source the proxy_env file to set the proxy settings first
set -exuo pipefail

source ~/.env
source ~/proxy_env


echo "Installing k3s"
curl -sfL https://get.k3s.io | sh -

# Copy the kubeconfig file to the host
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
chmod  0600 ~/.kube/config
export KUBECONFIG=~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc

cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
cat /proc/sys/fs/file-max

echo fs.inotify.max_user_instances=8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
echo fs.file-max = 100000 | sudo tee -a /etc/sysctl.conf
 
sudo sysctl -p
    
cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
cat /proc/sys/fs/file-max

set +exuo pipefail