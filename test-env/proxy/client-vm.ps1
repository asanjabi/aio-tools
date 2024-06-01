using module "../../tools/pwsh/Tools.psm1"

param (
    [switch]$Create,
    [switch]$Delete,
    [switch]$Rebuild
)

ReadVariablesFromFile ".env"


$proxyUrl = "http://$proxy_VmName.mshome.net:3128"


function CreateVm {
    Write-Output "Creating VM $client_VmName"
    multipass launch 22.04 --name $client_VmName


    Write-Output "Updating $client_VmName"
    multipass exec $client_VmName -- sudo apt update
    multipass exec $client_VmName -- sudo apt upgrade -y


    Write-Output "setting password"
    multipass exec $client_VmName -- sh -c '(echo "password"; echo "password") | sudo passwd ubuntu'

    # copy the proxy certificate over to the client
    multipass transfer ${certfile_der} ${vmName}:.
    
    # Convert to pem format and import into the client trust store
    multipass exec $client_VmName -- sudo openssl x509 -inform der -outform pem -in ${certfile_der} -out ${certfile_crt}
    multipass exec $client_VmName -- sudo apt-get install -y ca-certificates
    multipass exec $client_VmName -- sudo cp ${certfile_crt} /usr/local/share/ca-certificates
    multipass exec $client_VmName -- sudo update-ca-certificates
    
    # lock down everything to force proxy use
    # Allow 22 so we can still connect to the VM
    multipass exec $client_VmName -- sudo ufw allow in 22/tcp
    multipass exec $client_VmName -- sudo ufw enable
    # Allow DNS and proxy
    multipass exec $client_VmName -- sudo ufw allow out 53/udp
    multipass exec $client_VmName -- sudo ufw allow out 3128/tcp
    #deny all other traffic
    multipass exec $client_VmName -- sudo ufw deny out on eth0

    # Set the proxy settings
    multipass exec $client_VmName -- sh -c "echo export http_proxy=${proxyUrl} >> ~/proxy"
    multipass exec $client_VmName -- sh -c "echo export https_proxy=${proxyUrl} >> ~/proxy"

    # Set the proxy settings for apt
    multipass exec $client_VmName -- sudo sh -c "echo 'Acquire::http::Proxy ""$proxyUrl"";' >> /etc/apt/apt.conf"
    multipass exec $client_VmName -- sudo sh -c "echo 'Acquire::https::Proxy ""$proxyUrl"";' >> /etc/apt/apt.conf"

    multipass exec $client_VmName -- rm setup_az_cli_cert.sh
    multipass exec $client_VmName -- sh -c "echo 'find /opt/az/lib/*/site-packages/certifi -name cacert.pem -exec cp ""{}"" ~/ \;' >> ~/setup_az_cli_cert.sh"
    multipass exec $client_VmName -- sh -c "echo 'cat ${certfile_crt} >> ~/cacert.pem' >> ~/setup_az_cli_cert.sh"
    multipass exec $client_VmName -- sh -c "echo REQUESTS_CA_BUNDLE=~/cacert.pem >> ~/proxy"
    multipass exec $client_VmName -- chmod +x setup_az_cli_cert.sh
    multipass exec $client_VmName -- cat setup_az_cli_cert.sh

}

function DeleteVm {
    Write-Output "Deleting VM $client_VmName"
    multipass delete $client_VmName
    multipass purge
}

function RebuildVm {
    Write-Output "Rebuilding VM $client_VmName"
    DeleteVm
    CreateVm
}

if ($Create) {
    CreateVm
}
elseif ($Delete) {
    DeleteVm
}
elseif ($Rebuild) {
    RebuildVm
}
else {
    Write-Output "Usage: client.ps1 -Create | -Delete | -Rebuild"
}


Remove-Module -name tools