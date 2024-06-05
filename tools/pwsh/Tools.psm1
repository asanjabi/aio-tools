
<#
.SYNOPSIS
    Source a file with key=value pairs into the environment.
.DESCRIPTION
    This function reads a file with key=value pairs and sets the environment variables accordingly.
.PARAMETER path
    The path to the file to source.
.EXAMPLE    
    source .env
    This will read the file .env and set the environment variables accordingly.
#>
function ReadEnvFromFile {
    param(
        [string]$path
    )

    Get-Content $path | ForEach-Object {
        $name, $value = $_.replace('export ', '').split('=')
        if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
          continue
        }
        Set-Content env:\$name $value
      }
}

<#
.SYNOPSIS
    Source a file with key=value pairs into the environment.
.DESCRIPTION
    This function reads a file with key=value pairs and sets the environment variables accordingly.
.PARAMETER path
    The path to the file to source.
.EXAMPLE
    source .env
    This will read the file .env and set the environment variables accordingly.
#>
function ReadVariablesFromFile {
    param(
        [string]$path
    )

    Get-Content $path | ForEach-Object {
        $name, $value = $_.replace('export ', '').split('=')
        if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
            return
        }

        $expandedValue = $ExecutionContext.InvokeCommand.ExpandString($value)
        Set-Variable -Name Global:$name -Value $expandedValue
        # Set-Variable -Name Global:$name -Value $value
    }
}