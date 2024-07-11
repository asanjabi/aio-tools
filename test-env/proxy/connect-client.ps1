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

$vmName = $client_VmName
multipass shell $vmName


Remove-Module -name tools