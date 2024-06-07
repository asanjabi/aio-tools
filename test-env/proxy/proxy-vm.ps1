using module "../../tools/pwsh/Tools.psm1"
[CmdletBinding()]
param (
    [switch]$Create,
    [switch]$ConfigureCerts,
    [switch]$Configure,
    [switch]$Delete,
    [switch]$Rebuild,
    [switch]$Check
)

Write-Output "Create: $Create"
Write-Output "Configure: $Configure"
Write-Output "Delete: $Delete"
Write-Output "Rebuild: $Rebuild"


$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path -Parent $scriptPath
Write-Output "Script Path: $scriptPath"
Write-Output "Script Directory: $scriptDirectory"

ReadVariablesFromFile -path ".env"
$squidCert_pem = "${squidCert_dir}/${certfile_pem}"
$squidCert_der = "${squidCert_dir}/${certfile_der}"
$squidCert_subcject = "/C=US/ST=CA/L=LA/O=IT/CN=${proxy_VmName}.mshome.net"

Write-Verbose "squidCert_pem: $squidCert_pem"
Write-Verbose "squidCert_der: $squidCert_der"
Write-Verbose "squidCert_subcject: $squidCert_subcject"

function CreateVm {
    Write-Output "Creating VM $proxy_VmName"
    multipass launch --name $proxy_VmName

    Write-Output "Updating $proxy_VmName"
    multipass exec $proxy_VmName -- sudo apt update
    multipass exec $proxy_VmName -- sudo apt upgrade -y


    Write-Output "setting password"
    multipass exec $proxy_VmName -- sh -c '(echo "password"; echo "password") | sudo passwd ubuntu'

    Write-Output "Installing Squid"
    multipass exec $proxy_VmName -- sudo apt install squid-openssl -y

    Write-Output "Installing net-tools"
    multipass exec $proxy_VmName -- sudo apt install net-tools -y

    Write-Output "Protecting the original configuration file"
    multipass exec $proxy_VmName -- sudo cp -n /etc/squid/squid.conf /etc/squid/squid.conf.original
    multipass exec $proxy_VmName -- sudo chmod a-w /etc/squid/squid.conf.original
}

function ConfigureCerts {

    Write-Host "Configuring Certs"
   

    Write-Output "Creating a self-signed certificate"
    multipass exec $proxy_VmName -- sudo rm -rf $squidCert_dir
    multipass exec $proxy_VmName -- sudo mkdir $squidCert_dir

    $sslConfig = @(
        "[ v3_req ]",
        "basicConstraints = CA:FALSE",
        "keyUsage = nonRepudiation, digitalSignature, keyEncipherment",
        "[ v3_ca ]",
        "keyUsage = cRLSign, keyCertSign"
    )
    
    foreach ($line in $sslConfig) {
        Write-Output "Adding configuration: $line"
        multipass exec $proxy_VmName -- sudo sh -c "echo '$line' >> ${openssl_cfg_file}"
    }
    multipass exec $proxy_VmName -- sudo openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -subj ${squidCert_subcject} -extensions v3_ca -keyout $squidCert_pem -out $squidCert_pem -config ${openssl_cfg_file}
    multipass exec $proxy_VmName -- sudo openssl x509 -in $squidCert_pem -outform DER -out ${squidCert_der}

    # multipass transfer ${proxy_VmName}:$squidCert_pem .
    multipass transfer ${proxy_VmName}:$squidCert_der .

    multipass exec $proxy_VmName -- sudo chown -R $squidCert_owner $squidCert_dir
    multipass exec $proxy_VmName -- sudo chmod -R 755 $squidCert_dir
    multipass exec $proxy_VmName -- sudo ls -al $squidCert_dir

    Write-Output "create certs on the fly"
    multipass exec $proxy_VmName -- sudo rm -rf ${ssl_db_dir}
    multipass exec $proxy_VmName -- sudo /usr/lib/squid/security_file_certgen -c -s ${ssl_db_dir} -M 4MB
    multipass exec $proxy_VmName -- sudo chown -R $squidCert_owner ${ssl_db_dir}
    multipass exec $proxy_VmName -- sudo chmod -R 755 ${ssl_db_dir}
    multipass exec $proxy_VmName -- sudo ls -al ${ssl_db_dir}
}

function ConfigureSquid {
    Write-Output "Configuring Squid"

    multipass exec $proxy_VmName -- sudo rm -rf /etc/squid/squid.conf

    $configuration = @(
        "acl localnet src 0.0.0.1-0.255.255.255  # RFC 1122 ""this"" network (LAN)",
        "acl localnet src 10.0.0.0/8             # RFC 1918 local private network (LAN)",
        "acl localnet src 100.64.0.0/10          # RFC 6598 shared address space (CGN)",
        "acl localnet src 169.254.0.0/16         # RFC 3927 link-local (directly plugged) machines",
        "acl localnet src 172.16.0.0/12          # RFC 1918 local private network (LAN)",
        "acl localnet src 192.168.0.0/16         # RFC 1918 local private network (LAN)",
        "acl localnet src fc00::/7                # RFC 4193 local private network range",
        "acl localnet src fe80::/10              # RFC 4291 link-local (directly plugged) machines",

        "acl SSL_ports port 443",
        "acl Safe_ports port 80          # http",
        "acl Safe_ports port 21          # ftp",
        "acl Safe_ports port 443         # https",
        "acl Safe_ports port 70          # gopher",
        "acl Safe_ports port 210         # wais",
        "acl Safe_ports port 1025-65535  # unregistered ports",
        "acl Safe_ports port 280         # http-mgmt",
        "acl Safe_ports port 488         # gss-http",
        "acl Safe_ports port 591         # filemaker",
        "acl Safe_ports port 777         # multiling http",
        "acl CONNECT method CONNECT",
        "acl QUERY urlpath_regex cgi-bin \? asp aspx jsp",
        "acl step1 at_step SslBump1",
        "acl step2 at_step SslBump2",
        "acl step3 at_step SslBump3",

        ## Prevent caching jsp, cgi-bin etc
        "cache deny QUERY",

        # Deny requests to certain unsafe ports
        "http_access deny !Safe_ports",

        # Deny CONNECT to other than secure SSL ports
        "http_access deny CONNECT !SSL_ports",

        # Only allow cachemgr access from localhost
        "http_access allow localhost manager",
        "http_access deny manager",

        # This default configuration only allows localhost requests because a more
        # permissive Squid installation could introduce new attack vectors into the
        # network by proxying external TCP connections to unprotected services.
        "http_access allow localhost",

        # The two deny rules below are unnecessary in this default configuration
        # because they are followed by a "deny all" rule. However, they may become
        # critically important when you start allowing external requests below them.

        # Protect web applications running on the same server as Squid. They often
        # assume that only local users can access them at "localhost" ports.
        "http_access deny to_localhost",

        # Protect cloud servers that provide local users with sensitive info about
        # their server via certain well-known link-local (a.k.a. APIPA) addresses.
        "http_access deny to_linklocal",

        #
        # INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
        #
        "include /etc/squid/conf.d/*.conf",

        # For example, to allow access from your local networks, you may uncomment the
        # following rule (and/or add rules that match your definition of "local"):
        "http_access allow localnet",
        "http_access allow localhost",


        ######### SSL Interception Configuration #########
        # "http_port 3128",
        "http_port 3128 ssl-bump cert=${squidCert_pem} generate-host-certificates=on dynamic_cert_mem_cache_size=4MB",      
        "sslcrtd_program /usr/lib/squid/security_file_certgen -s ${ssl_db_dir} -M 4MB",
        "sslcrtd_children 3 startup=1 idle=1",
        "acl step1 at_step SslBump1",
        "ssl_bump peek step1",
        "ssl_bump bump all",
        # ######### End SSL Interception Configuration #########


        # And finally deny all other access to this proxy
        "http_access deny all",

        # Leave coredumps in the first cache dir
        "coredump_dir /var/spool/squid",

        # Where does Squid log to?
        "access_log /var/log/squid/access.log",
        # Use the below to turn off access logging
        #access_log none
        # When logging, web auditors want to see the full uri, even with the query terms
        "strip_query_terms off",
        # Keep 7 days of logs
        "logfile_rotate 7",

        # Use X-Forwarded-For header?
        # Some consider this a privacy/security risk so it is often disabled
        # However it can be useful to identify misbehaving/problematic clients
        #forwarded_for on 
        "forwarded_for delete",

        # Suppress sending squid version information
        "httpd_suppress_version_string on",

        # Replace the User Agent header.  Be sure to deny the header first, then replace it :)
        "request_header_access User-Agent deny all",
        "request_header_replace User-Agent Mozilla/5.0 (Windows; MSIE 9.0; Windows NT 9.0; en-US)",

        # What hostname to display? (defaults to system hostname)
        "visible_hostname a_proxy",

        #
        # Add any of your own refresh_pattern entries above these.
        #
        "refresh_pattern .               0       20%     4320"
    )

    foreach ($line in $configuration) {
        Write-Output "Adding configuration: $line"
        multipass exec $proxy_VmName -- sudo sh -c "echo '$line' >> /etc/squid/squid.conf"
    }

    Write-Output "Final Squid configuration"
    multipass exec $proxy_VmName -- grep -vE '^$|^#' /etc/squid/squid.conf
    multipass exec $proxy_VmName -- sudo squid -k reconfigure
    multipass exec $proxy_VmName -- sudo squid -k check
    multipass exec $proxy_VmName -- netstat -tl
    multipass exec $proxy_VmName -- sudo systemctl restart squid
}

function DeleteVm {
    Write-Output "Deleting VM $proxy_VmName"
    multipass delete $proxy_VmName
    multipass purge
}

function checkVm {
    Write-Output "Checking VM $proxy_VmName"
    multipass list
    multipass exec $proxy_VmName -- squid -k check
    multipass exec $proxy_VmName -- netstat -tl
}

if ($Delete) {
    Write-Output "Deleting VM $proxy_VmName"
    DeleteVm
}
elseif ($Create) {
    Write-Output "Creating VM $proxy_VmName"
    CreateVm
}
elseif ($ConfigureCerts) {
    Write-Output "Configuring Certs"
    ConfigureCerts
}
elseif ($Configure) {
    Write-Output "Configuring VM $proxy_VmName"
    ConfigureSquid
}
elseif ($Rebuild) {
    Write-Output "Rebuilding VM $proxy_VmName"
    DeleteVm
    CreateVm
    ConfigureCerts
    ConfigureSquid
}
else {
    Write-Output "Checking VM $proxy_VmName"
    checkVm
}

Remove-Module -name tools