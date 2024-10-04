# Overview

This tutorial will walk you through creating a local instance of [Azure IoT operations](https://learn.microsoft.com/en-us/azure/iot-operations/overview-iot-operations) including scripts and configuration files you need to create a repeatable process.

**Note that these documents are executable, you can use either [Runme](https://marketplace.visualstudio.com/items?itemName=stateful.runme) VS Code extension or [InnovatioEngine](https://github.com/Azure/InnovationEngine) to execute them**

1. Create and update your work environment

   - If you are using Linux or WSL use [this script](linux/configure_local_environment/configure_local_environment_linux.md)
   - If you are using PowerShell use [this script](pwsh/configure_local_environment/setup_local_environment_pwsh.md)

2. Gather environment variables we are going to need use [this script](linux/gather_required_values.md)
3. Prepare your Azure subscription use [this script](/linux/configure_azure_subscription/configure_azure_subscription.md)
4. [Create a Kubernetes cluster](linux/create_cluster/create_kubernetes_cluster_linux.md)  
   **IMPORTANT**
   If you are using hyper-v for your cluster you need to enable routing between your WSL network and your Kubernetes VM.  To do this open a Administrator PowerShell instance and run 
   You can get the name of the switches by running Get-NetIPInterface or looking in hyper-v manager's configuration.  
   If you don't do this you'll not have a good time configuring this.
   ```
   Set-NetIPInterface -ifAlias "vEthernet (Default Switch)" -Forwarding Enabled  
   Set-NetIPInterface -ifAlias "vEthernet (WSL (Hyper-V firewall))" -Forwarding Enabled
   ```

5. [Arc enable your cluster](linux/connect_cluster_to_arc.md)
6. Install Azure IoT Operations extensions