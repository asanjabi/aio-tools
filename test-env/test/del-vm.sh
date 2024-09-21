#!/bin/bash
set -exuo pipefail

source .env

multipass.exe delete --purge $aio_vmName
multipass.exe purge

set +exuo pipefail