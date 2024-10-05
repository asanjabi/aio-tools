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
* Azure CLI install in WSL will require restart for path
* Look into Snap --classic and why snap bin is not in the path, what is the right thing to do about this


* Add validation step at the end of each section to make sure everything is fine

* Links to non md fils might not be obvious to users when they need to edit them
* Multiple users ran into login issues
    * Had to login twice if not logged in
    * If logged in, in one occasion required to redo MFA
    * Potentially log out and login at the beginning to make sure things go smoothly

* Include notes about cloud-init why and how 
* Document cloud-init files