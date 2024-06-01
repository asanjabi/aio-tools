Steps to create the proxy VM and Client using multipass
1. If you don't have multipass installed install it using `..\..\tools\multipass\multipass-install.ps1`
   By default multipass sotres it's images in ProgramData\Multipass if you want to change this you can pass in an **existing** directory as command line parameter
   
2. Make a copy `env` file to `.env` and update the values accoringly
3. Create the proxy server by calling .\proxy-vm.ps1 -Rebuild
4. Create the proxy client by calling .\client-vm.ps1 -Rebuild

To connect to proxy added the environment variables in `proxy` file
`source proxy` after logging in or add it to your .bashrc file `cat proxy >> .bashrc`

To use Azure CLI with proxy, after installing the CLI run `sudo setup_az_cli_cert.sh` once.  This script will: 
   * Copy the certificate file to your home directory, this is for testing in real life it should be somwhere safer.
   * Merge the proxy's certificate with it
   * Environment variable to for configuring Azure CLI to use it is in the proxy file `REQUESTS_CA_BUNDLE=~/cacert.pem`
  * See https://learn.microsoft.com/en-us/cli/azure/use-azure-cli-successfully?tabs=bash%2Cbash2#work-behind-a-proxy for more details.


* If you run into timeout issues when installing extensions, you might need to increase the time out value for python for details see: https://pip.pypa.io/en/stable/topics/confguration/



proxy-vm.ps1
   -Create           Creates a new VM
   -ConfigureCerts   Creates and installs certificate
   -Delete           Deletes the VM
   -Rebuild          Runs Delete, Create, ConfigureCerts, Configure in order
   -Check            Checks the proxy

Client-vm.ps1
   -Create           Creates a new VM
   -Delete           Deletes the VM
   -Rebuild          Runs Delete, Create in order


tail-proxy-log.ps1   Watch the proxy logs
connect-client.ps1   SSh into the client VM