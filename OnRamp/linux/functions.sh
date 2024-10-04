login_azure_cli_device_code() {
    # Check if parameters were passed in
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please provide the tenant ID and subscription ID"
        return
    fi

    # Check if user is already logged in and has access to the subscription ID
    if az account show &>/dev/null; then
        echo "User is already logged in"
        current_tenant=$(az account show --query 'tenantId' -o tsv)
        if [ "$current_tenant" == "$1" ]; then
            echo "User has access to the specified tenant ID"
        else
            echo "Lets login again"
            az login --use-device-code --tenant "$1"
        fi
    else
        echo "User is not logged in"
        az login --use-device-code --tenant "$1"
    fi

    az account set --subscription "$2"
    echo "setting current subscription to $2"
}
