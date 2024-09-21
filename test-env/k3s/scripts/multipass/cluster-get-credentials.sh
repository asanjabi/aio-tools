#!/bin/bash
set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

#get script directory
script_dir=$(dirname $0)
source $script_dir/utilities.sh

multipass_path=$(get_multipass_path)

execute $multipass_path exec $aio_vmName -- mkdir -p /home/ubuntu/.kube
execute $multipass_path exec $aio_vmName -- sudo cp -f /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
execute $multipass_path exec $aio_vmName -- sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
execute $multipass_path exec $aio_vmName -- chmod 0600 /home/ubuntu/.kube/config
execute $multipass_path exec $aio_vmName -- export KUBECONFIG=/home/ubuntu/.kube/config

kube_config_path=$(get_project_cube_config_Path)
kube_config_directory=$(dirname $kube_config_path)

execute mkdir -p $kube_config_directory
execute rm -f $kube_config_path

execute $multipass_path transfer $aio_vmName:/home/ubuntu/.kube/config $kube_config_path

execute sudo chown $USER:$USER $kube_config_path
execute chmod 0600 $kube_config_path
set_project_cube_config_environment_var

execute kubectl config set-cluster default --server=https://$aio_vmName.mshome.net:6443
execute kubectl config view

#update the line in .env file that starts with export KUBECONFIG= to the new value
if grep -q "export KUBECONFIG=" $project_dir/.env; then
    sed -i "s|export KUBECONFIG=.*|export KUBECONFIG=$KUBECONFIG|g" $project_dir/.env
else
    echo "export KUBECONFIG=$KUBECONFIG" >>$project_dir/.env
fi


set +euo pipefail
