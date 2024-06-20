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
sh -c "echo export http_proxy=$proxyUrl >> ~/additional_env"
sh -c "echo export https_proxy=$proxyUrl >> ~/additional_env"
sh -c "echo export proxy_cert=/usr/local/share/ca-certificates/$certfile_crt >> ~/additional_env"

# Set the proxy settings for apt
echo Acquire::http::Proxy "\"$proxyUrl\""\; | sudo tee -a  /etc/apt/apt.conf
echo Acquire::https:Proxy "\"$proxyUrl\""\; | sudo tee -a  /etc/apt/apt.conf

# Configure snap to work behind proxy
sudo snap set system proxy.http="$proxyUrl"
sudo snap set system proxy.https="$proxyUrl"
sudo systemctl restart snapd

set +exuo pipefail