using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
)

ReadVariablesFromFile ".env"

$vmName = $client_VmName
$user  = $client_user_name
code --remote ssh-remote+$client_user_name@$vmName.mshome.net /home/$client_user_name



Remove-Module -name tools