To create our Kubernetes cluster we are going to use a cloud-init file and Multipass to create a local VM. Alternate option is to use the same could-init file to configure VMs in other locations.

**This is a temporary for the current lab. Eventual plan is to help the user create a series of userdata.yaml file with required configuration that they can use to deploy the nodes in their cluster to create a repeatable process for replication, HW failure recovery etc.**

## 1. Installing Multipass

If you haven't done so, download Multipass from https://multipass.run/install and install it on your computer.

## 2. Create the userdata.yaml file to use for each node

Eventually we'll walk the user in create one per node to be deployed, but for now take a look at the [userdata.yaml](../../userdata.yaml) file and make any changes you need to make.

__Important__
if you change your VM name from aio search the userdata.yaml file for line `--tls-san aio.mshome.net` and change the value to match your host name for example `--tls-san my_very_special_host_name.mshome.net`

## 3. Create the VM using the script below.

* Make sure to change the cloudInit_path if you are using a different file.
* Make other adjustments to the vm configuration as needed
* Recommended values are:
   * vm_cores=8
   * vm_memory=16G
   * vm_disk=20G

```bash
source ./multipass/utilities.sh
source ../../.env

cloudInit_path="../../userdata.yaml"
vm_image=22.04
vm_cores=8
vm_memory=16G
vm_disk=20G

create_vm $VM_NAME $vm_image $vm_cores $vm_memory $vm_disk $cloudInit_path

```

To connect to your VM you can run this command

```bash {"excludeFromRunAll":"true"}
source ../../.env
echo "Starting VM $VM_NAME"
cmd.exe /c start cmd.exe /c multipass.exe shell $VM_NAME
```

Now lets copy the Kubernetes config file locally so we can interact with the cluster

```bash
source ./multipass/utilities.sh
source ../../.env
env_file_path="../../.env"

multipass_path=$(get_multipass_path)
($multipass_path exec $VM_NAME -- mkdir -p /home/ubuntu/.kube)
($multipass_path exec $VM_NAME -- sudo cp -f /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config)
($multipass_path exec $VM_NAME -- sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config)
($multipass_path exec $VM_NAME -- chmod 0600 /home/ubuntu/.kube/config)
($multipass_path exec $VM_NAME -- export KUBECONFIG=/home/ubuntu/.kube/config)

kube_config_path=$(realpath "../../kube/config")
kube_config_directory=$(dirname $kube_config_path)

mkdir -p $kube_config_directory
rm -f $kube_config_path

($multipass_path transfer $VM_NAME:/home/ubuntu/.kube/config $kube_config_path)

sudo chown $USER:$USER $kube_config_path
chmod 0600 $kube_config_path
export KUBECONFIG=$kube_config_path

kubectl config set-cluster default --server=https://$VM_NAME.mshome.net:6443
kubectl config view

#update the line in .env file that starts with export KUBECONFIG= to the new value
if grep -q "export KUBECONFIG=" $env_file_path; then
    sed -i "s|export KUBECONFIG=.*|export KUBECONFIG=$KUBECONFIG|g" $env_file_path
else
    echo "export KUBECONFIG=$KUBECONFIG" >>$env_file_path
fi
```

Make sure you can connect to the cluster by running the following command:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```