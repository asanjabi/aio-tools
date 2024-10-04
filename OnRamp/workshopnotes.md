DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V /NoRestart

* Figure out exact step sto install runme on a clean machine and enable the UI
* There is a pop-up for installing recommended extensions users might miss that
    * Document how to use @recommended in extensions section to install them

* There might be issues with Snap being available for customers
    * sudo systemctl status snapd
    * sudo systemctl start snapd

* Instructions on how to reset/install WSL

* Getting started 
    * Clone repository in WSL / powershell
    * Start vscode: ```code .``` from the folder

* Add resources for WSL https://learn.microsoft.com/en-us/windows/wsl/
* Make sure Azure CLI is installed before running the commands
* Update Azure CLI section fails in a fresh install of WSL if you run all the scripts

* Add more navigation links to the docs