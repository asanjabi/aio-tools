using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
)

ReadVariablesFromFile ".env"

$vmName = $client_VmName
multipass transfer -r ..\..\ ${vmName}:/home/ubuntu/aio


Remove-Module -name tools