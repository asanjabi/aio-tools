using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
)

ReadVariablesFromFile ".env"

$vmName = $client_VmName
code --remote ssh-remote+$ubuntu@$vmName.mshome.net /home/ubuntu



Remove-Module -name tools