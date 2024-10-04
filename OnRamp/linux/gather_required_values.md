Create a copy of the environment files and update with appropriate values

```bash
if [ ! -f ../.env ]; then
  cp ../env.sample ../.env
fi
```

Edit the [.env](../.env) file.  
Use the script below to make sure all values are configured

```bash
source ../.env
echo "Azaure Entra ID tenant id: $TENANT_ID"
echo "Azure Subscription id:     $SUBSCRIPTION_ID"
echo "Deployment location:      $LOCATION"
echo "Resource group:           $RESOURCE_GROUP"
echo "Cluster name:             $CLUSTER_NAME"
echo "Key vault name:           $KEYVAULT_NAME"


```