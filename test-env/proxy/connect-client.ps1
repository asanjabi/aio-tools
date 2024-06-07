using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
)

ReadVariablesFromFile ".env"

$vmName = $client_VmName
multipass shell $vmName


Remove-Module -name tools