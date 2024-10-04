# In this work book we will walk through making sure the subscriptions we are deploying to is setup correctly

Make sure you have made a copy of the env.sample file and updated all the values.
To check the values run the script below. If you haven't done this already you can use [this script](../gather_required_values.md)

```bash
cat ../../.env
```

Login to your azure subscription

```bash
source ../../.env
source ../functions.sh
login_azure_cli_device_code $TENANT_ID $SUBSCRIPTION_ID
az account show
```

This function will register the required resource providers.
This process can take a while, to speed things up we'll do we'll do this in two passes so registrations can happen in parallel.
First start the registration process for each one of the providers, without waiting for completion.
Then in another loop wait for each one to complete before exiting the function.

```bash
resource_providers=(
    "Microsoft.Compute"
    "Microsoft.Keyvault"
    "Microsoft.Network"
    "Microsoft.ExtendedLocation"
    "Microsoft.Kubernetes"
    "Microsoft.KubernetesConfiguration"
    "Microsoft.IoTOperationsOrchestrator"
    "Microsoft.IoTOperations"
    "Microsoft.DeviceRegistry")

register_resource_providers() {
    # Check if az is installed
    if ! command -v az &>/dev/null; then
        echo "az command not found, please install Azure CLI first"
        return
    fi

    providers=("$@")

    # Check if resource providers array is empty
    if [ ${#providers[@]} -eq 0 ]; then
        echo "No resource providers specified"
        return
    fi

    # Loop through the resource providers array and start registering them
    for provider in "${providers[@]}"; do
        echo "Registering resource provider: $provider"
        az provider register --namespace "$provider"
    done

    # Now wait for all the resource providers to be registered
    for provider in "${providers[@]}"; do
        echo  "Waiting for $provider to register"
        az provider register --namespace "$provider" --wait
    done
    echo "All resource providers registered successfully"
}

register_resource_providers "${resource_providers[@]}"
```