using module "../../tools/pwsh/Tools.psm1"
using module "../../tools/pwsh/Download.psm1"

param(
    [string]$dataPath = $null
)

# Install Multipass
Write-Information "Installing Multipass"
$downloadDir = Get-Location
$fileName = Get-FileFromUrl -Url "https://multipass.run/download/windows" -DestinationDirectory $downloadDir
# Start the process and wait for it to finish
$process = Start-Process -FilePath $fileName -PassThru
$process.WaitForExit()

if ($dataPath -ne $null) {
    Stop-Service Multipass
    mkdir $dataPath -Force

    Set-ItemProperty -Path "HKLM:System\CurrentControlSet\Control\Session Manager\Environment" -Name MULTIPASS_STORAGE -Value $dataPath

    Copy-Item -Path "C:\ProgramData\Multipass\*" -Destination $dataPath -Recurse -Force

    Remove-Item -Path "C:\ProgramData\Multipass\*" -Recurse -Force
    Start-Service Multipass
}