using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
    [switch]$NewWindow)

if ($NewWindow) {
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "`$ErrorActionPreference = 'Stop'; . $PSCommandPath"
    Remove-Module -name tools
    exit
}

ReadVariablesFromFile ".env"

$vmName = $proxy_VmName
multipass exec $vmName -- sudo tail -f /var/log/squid/access.log


Remove-Module -name tools