<#
.SYNOPSIS
Gets the file name from a given URL.

.DESCRIPTION
The Get-FileNameFromUrl function retrieves the file name from a specified URL by sending a HEAD request and extracting the file name from the 'Content-Disposition' header.

.PARAMETER Url
The URL from which to retrieve the file name.

.EXAMPLE
$fileName = Get-FileNameFromUrl -Url "https://example.com/files/document.pdf"
This example retrieves the file name from the specified URL and assigns it to the $fileName variable.

.INPUTS
[string]
The function accepts a string parameter representing the URL.

.OUTPUTS
[string]
The function returns a string representing the file name extracted from the URL.

.NOTES
This function requires an internet connection to send the HTTP request and retrieve the file name.

.LINK
https://example.com/documentation/Get-FileNameFromUrl

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


<#
.SYNOPSIS
Downloads a file from a specified URL to a destination directory.

.DESCRIPTION
The Get-FileFromUrl function downloads a file from a specified URL to a destination directory. If the destination directory does not exist, it will be created. 
The function also supports optional parameters for force downloading and specifying a custom file name.

.PARAMETER Url
The URL of the file to download.

.PARAMETER DestinationDirectory
The directory where the downloaded file will be saved.

.PARAMETER ForceDownload
Specifies whether to force download the file even if it already exists in the destination directory. The default value is False.

.PARAMETER FileName
The custom file name to use for the downloaded file. If not specified, the function will attempt to extract the file name from the URL.

.EXAMPLE
PS> Get-FileFromUrl -Url "https://example.com/file.txt" -DestinationDirectory "C:\Downloads"

This example downloads the file "file.txt" from the specified URL and saves it to the "C:\Downloads" directory.

.EXAMPLE
PS> Get-FileFromUrl -Url "https://example.com/file.txt" -DestinationDirectory "C:\Downloads" -ForceDownload $true

This example downloads the file "file.txt" from the specified URL and saves it to the "C:\Downloads" directory, even if the file already exists in the destination directory.

#>
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