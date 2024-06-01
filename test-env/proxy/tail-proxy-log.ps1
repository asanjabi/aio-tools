using module "../../tools/pwsh/Tools.psm1"

ReadVariablesFromFile ".env"


$vmName = $proxy_VmName
multipass exec $vmName -- sudo tail -f /var/log/squid/access.log


Remove-Module -name tools