
is_wsl(){
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
}


get_multipass_path() {
    if [ $(is_wsl) == "true" ]; then
        echo "multipass.exe"
    else
        echo "multipass"
    fi
}

convert_path() {
    if [ $(is_wsl) == "true" ]; then
        echo $(wslpath -w $1)
    else
        echo $1
    fi
}

create_vm(){
    local vm_name=$1
    local vm_image=$2
    local vm_cpus=$3
    local vm_memory=$4
    local vm_disk=$5
    local vm_cloud_init=$6

    local multipass_path=$(get_multipass_path)
    local cloud_init_path=$(convert_path $vm_cloud_init)

    $multipass_path launch $vm_image --name $vm_name --cpus $vm_cpus --memory $vm_memory --disk $vm_disk --cloud-init $cloud_init_path
}