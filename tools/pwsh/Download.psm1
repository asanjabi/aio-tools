
<#
.SYNOPSIS
Downloads a file from a specified URL.

.DESCRIPTION
The Get-FileFromUrl function downloads a file from a specified URL and saves it to the local machine.

.PARAMETER Url
The URL of the file to download.

.PARAMETER Destination
The local path where the downloaded file will be saved.

.EXAMPLE
Get-FileFromUrl -Url "https://example.com/file.txt" -Destination "C:\Downloads\file.txt"
Downloads the file from the specified URL and saves it to the specified destination.

#>

function Get-FileNameFromUrl {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Url
    )

    try {
        Write-Verbose "Getting file name from $Url"
        
        # Create a web request
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Method = "HEAD"
        
        # Get the response from the request
        $response = $request.GetResponse()

        # Get the file name from the 'Content-Disposition' header
        $fileName = $response.Headers["Content-Disposition"] -replace '.*filename=([^;]+).*', '$1'
        Write-Verbose "File name: $fileName"

        return $fileName
    }
    catch {
        throw $_.Exception.Message
    }
}

function Get-FileFromUrl {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Url,

        [Parameter(Mandatory = $True)]
        [string]$DestinationDirectory,

        [Parameter(Mandatory = $False)]
        [bool]$ForceDownload = $False,

        [Parameter(Mandatory = $False)]
        [string]$FileName = $null
    )

    try {
        Write-Verbose "Downloading file from $Url to $DestinationDirectory"
        if (-not (Test-Path $DestinationDirectory)) {
            Write-Verbose "Creating directory $DestinationDirectory"
            New-Item -ItemType Directory -Path $DestinationDirectory
        }
        
        if ($null -eq $FileName -or $FileName -eq "") {
            write-verbose "Getting file name from $Url"
            $fileName = Get-FileNameFromUrl -Url $Url
            Write-Verbose "File name: $fileName"
        }
        
        # Full path for the output file
        $fullPath = Join-Path -Path $DestinationDirectory -ChildPath $fileName
        Write-Verbose "Full path: $fullPath"


        if ($ForceDownload -or (-not (Test-Path $fullPath))) {
            Write-Information "Downloading file from $Url to $fullPath"
            Invoke-WebRequest -Uri $Url -OutFile $fullPath
        }
        else {
            Write-Information "File already exists at $fullPath"
        }

        return $fullPath
    }
    catch {
        throw $_.Exception.Message
    }
}