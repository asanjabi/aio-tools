set -euo pipefail
source $tools_dir/functions.sh
source $tools_dir/console.sh

execute az login --use-device-code
execute az account set --subscription $SUBSCRIPTION_ID

set +euo pipefail