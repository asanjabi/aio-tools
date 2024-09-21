#!/bin/bash
set -euo pipefail

cmd.exe /c start cmd.exe /c multipass.exe shell $aio_vmName

set +euo pipefail