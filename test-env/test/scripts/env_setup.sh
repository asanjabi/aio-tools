set -exuo pipefail

source ~/.env

############################################
# Updates
############################################
sudo apt-get update
sudo apt-get upgrade -y

############################################
# Install kubectl
############################################
if ! command -v kubectl &> /dev/null; then
    sudo snap install kubectl --classic
fi

############################################
# Install k9s
############################################
if ! command -v k9s &> /dev/null; then
    sudo snap install k9s
    #bug in installer
    sudo ln -s /snap/k9s/current/bin/k9s /usr/bin
fi

############################################
## Update the system to some recommended settings
############################################
# Take a snapshot of the current inotify and file-max settings
cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
cat /proc/sys/fs/file-max

# update the inotify and file-max settings to recommended values
echo fs.inotify.max_user_instances=8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
echo fs.file-max = 100000 | sudo tee -a /etc/sysctl.conf

# Apply the changes
sudo sysctl -p

# Take a snapshot after update    
cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
cat /proc/sys/fs/file-max


############################################
# Cutomize .bashrc
############################################
if ! grep -q "# Kubernetes config" ~/.bashrc; then
cat << EOF >> ~/.bashrc

# Kubernetes config
if command -v kubectl &> /dev/null; then
    alias k=$(command -v kubectl)
    source <(kubectl completion bash)
    source <(kubectl completion bash | sed s/kubectl/k/g)

    alias kcd='kubectl config set-context $(kubectl config current-context) --namespace '
    #export KUBE_EDITOR='code --wait'
    export KUBE_EDITOR='nano'
fi
EOF
fi
vim ~/.bashrc -c "set ff=unix" -c ":wq"

set +exuo pipefail