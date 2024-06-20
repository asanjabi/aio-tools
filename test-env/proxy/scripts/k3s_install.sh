#Install k3s, source the additional_env file to set the proxy settings first
set -exuo pipefail

source ~/.env
source ~/additional_env

# Set the no_proxy environment variable so that the k3s installation will pick it up.
export no_proxy=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

#also add the no_proxy to the .bashrc file and the additional_env file
echo no_proxy=$no_proxy >> ~/.bashrc
echo no_proxy=$no_proxy >> ~/additional_env

echo "Installing k3s using quick install script"
curl -sfL https://get.k3s.io | sh -

# write this to logs so that we can see the environment variables that were set
sudo cat /etc/systemd/system/k3s.service.env

# Copy the kubeconfig file to the user's home directory
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

# Install k9s
sudo snap install k9s
#bun in installer
sudo ln -s /snap/k9s/current/bin/k9s /usr/bin


set +exuo pipefail