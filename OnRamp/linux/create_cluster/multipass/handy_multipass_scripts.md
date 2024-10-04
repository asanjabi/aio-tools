### Connect to your VM

This will launch a new terminal window connected to your VM.

```sh
source ../../../.env
echo "Starting VM $VM_NAME"
cmd.exe /c start cmd.exe /c multipass.exe shell $VM_NAME
```

### Delete your VM

```sh
source ../../../.env
source ./utilities.sh

multipass_path=$(get_multipass_path)

echo "Deleting VM $VM_NAME"
($multipass_path delete $VM_NAME)
echo "Purging VM $VM_NAME"
($multipass_path purge)
```