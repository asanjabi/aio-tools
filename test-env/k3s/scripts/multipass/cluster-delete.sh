  
#!/bin/bash
set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

#get script directory
script_dir=$(dirname $0)
source $script_dir/utilities.sh

multipass_path=$(get_multipass_path)

write-info "Deleting VM $aio_vmName"
execute $multipass_path delete $aio_vmName

write-info $multipass_path purge
execute $multipass_path purge

set +euo pipefail

