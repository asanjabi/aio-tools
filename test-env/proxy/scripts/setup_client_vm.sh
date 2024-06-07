set -exuo pipefail

source ~/.env

proxyUrl="http://$proxy_VmName.mshome.net:3128"
echo $proxyUrl

echo "Updating $proxy_VmName"
sudo apt update
sudo NEEDRESTART_MODE=a apt upgrade -y


echo "setting password"
(echo "password"; echo "password") | sudo passwd ubuntu



# Convert to pem format and import into the client trust store
sudo openssl x509 -inform der -outform pem -in $certfile_der -out $certfile_crt
sudo apt-get install -y ca-certificates
sudo cp $certfile_crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# lock down everything to force proxy use
# Allow 22 so we can still connect to the VM
sudo ufw allow in 22/tcp
sudo ufw --force enable 
# Allow DNS and proxy
sudo ufw allow out 53/udp
sudo ufw allow out 3128/tcp
#deny all other traffic
sudo ufw deny out on eth0

# Set the proxy settings
sh -c "echo export http_proxy=$proxyUrl >> ~/proxy_env"
sh -c "echo export https_proxy=$proxyUrl >> ~/proxy_env"
sh -c "echo export proxy_cert=/usr/local/share/ca-certificates/$certfile_crt >> ~/proxy_env"

# Set the proxy settings for apt
echo Acquire::http::Proxy "\"$proxyUrl\""\; | sudo tee -a  /etc/apt/apt.conf
echo Acquire::https:Proxy "\"$proxyUrl\""\; | sudo tee -a  /etc/apt/apt.conf

# Create a shell script to prepare the certificate bundle for Azure CLI after it is installed
# Run this script after Azure CLI is installed to setup the new certificate bundle
# This script will find a file named cacert.pem in the Azure CLI installation 
# Copies it locally and and appends the proxy's certificate to it
rm -f setup_az_cli_cert.sh
echo 'find /opt/az/lib/*/site-packages/certifi -name cacert.pem -exec cp ""{}"" ~/ \;' >> ~/setup_az_cli_cert.sh
echo 'cat $certfile_crt >> ~/cacert.pem' >> ~/setup_az_cli_cert.sh

# Add the new certificate bundle for Azure CLI to use
echo export REQUESTS_CA_BUNDLE=~/cacert.pem >> ~/proxy_env
chmod +x setup_az_cli_cert.sh
#cat setup_az_cli_cert.sh

set +exuo pipefail