#!/bin/bash
source .env
source $tools_dir/functions.sh
source $tools_dir/console.sh

export project_dir=$(pwd)
export root_dir=$(dirname $0)

setup_debug


main_menu() {

    local menu=()
    
    declare -A connect_to_vm=(
        [title]="Connect to VM"
        [command]="$tools_dir/$vm_source/connect.sh")
    add_menu_item menu connect_to_vm

    add_divider_menu_item menu
    add_blank_menu_item menu
    
    declare -A machin_config=(
        [title]="Configure Local Environment"
        [command]="local_config")
    add_menu_item menu machin_config

    declare -A azure_config=(
        [title]="Configure Azure Environment"
        [command]="azure_config")
    add_menu_item menu azure_config

    declare -A cluster_config=(
        [title]="Configure Cluster"
        [command]="cluster_config")
    add_menu_item menu cluster_config

    declare -A setup_aio=(
        [title]="Setup AIO"
        [command]="setup_aio")
    add_menu_item menu setup_aio

    execute_menu menu
}

local_config() {

    local menu=()

    declare -A install_tools=(
        [title]="Install required tools"
        [command]="$tools_dir/machine-config.sh")
    add_menu_item menu install_tools

    add_menu_item menu back_menu_item
    execute_menu menu
}

azure_config() {

    local menu=()

    declare -A login=(
        [title]="Login to Azure"
        [command]="$tools_dir/azure_login_device_code.sh")
    add_menu_item menu login

    declare -A configure_subscription=(
        [title]="Configure Subscription"
        [command]="$tools_dir/subscription_config.sh")
    add_menu_item menu configure_subscription

    declare -A create_azure_resources=(
        [title]="Create Azure Resources"
        [command]="$tools_dir/azure_create_resources.sh")
    add_menu_item menu create_azure_resources

    add_menu_item menu back_menu_item
    execute_menu menu
}

cluster_config() {

    local menu=()

    declare -A create_cluster=(
        [title]="Create Cluster"
        [command]="$tools_dir/multipass/cluster-create.sh")
    add_menu_item menu create_cluster

    declare -A get_credentials=(
        [title]="Get Cluster Credentials"
        [command]="$tools_dir/multipass/cluster-get-credentials.sh")
    add_menu_item menu get_credentials

    add_blank_menu_item menu
    add_divider_menu_item menu
    
    declare -A connect_to_vm=(
        [title]="Connect to VM"
        [command]="$tools_dir/$vm_source/connect.sh")
    add_menu_item menu connect_to_vm

    declare -A delete_cluster=(
        [title]="Delete Cluster"
        [command]="$tools_dir/multipass/cluster-delete.sh")
    add_menu_item menu delete_cluster

    add_menu_item menu back_menu_item
    execute_menu menu
}

setup_aio() {
    write-debug "Setting up AIO"

    local menu=()

    declare -A connect_to_arc=(
        [title]="Connect cluster to Arc"
        [command]="$tools_dir/arc_connect_cluster.sh")
    add_menu_item menu connect_to_arc

    declare -A setup_aio=(
        [title]="Setup AIO"
        [command]="$tools_dir/aio_install.sh")
    add_menu_item menu setup_aio

    execute_menu menu
}      

main_menu

exit 0

set +exuo pipefail
