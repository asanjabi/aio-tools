# bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source $SCRIPT_DIR/console.sh

check-url() {
    #write-message "curl --head -L --max-time 20 $1 >/dev/null 2>&1"
    if curl --head -L --max-time 20 $1 >/dev/null 2>&1; then
        write-success "$1"
    else
        write-error "$1"
    fi
}
