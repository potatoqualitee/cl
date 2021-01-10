function Edit-PSCLConfigFile {
    <#
    .SYNOPSIS
        Gets configuration values

    .DESCRIPTION
        Gets configuration values

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param (
        [string]$Editor
    )
    process {
        # try to use an editor or else it adds an extra space to the output https://github.com/PowerShell/PowerShell/issues/13094
        if (-not $Editor) {
            if ($result = Get-Command -ErrorAction SilentlyContinue code) {
                $Editor = $result.Path
            } elseif ($result = Get-Command -ErrorAction SilentlyContinue notepad) {
                $Editor = $result.Path
            } elseif ($result = Get-Command -ErrorAction SilentlyContinue vi) {
                $Editor = $result.Path
            } else {
                Invoke-Item -Path $script:configfile
            }
        }
        # no idea if this will be supported on Linux
        if ($Editor) {
            $null = Start-Process -FilePath $Editor -ArgumentList $script:configfile -PassThru -NoNewWindow
        } else {
            $null = Start-Process $script:configfile -PassThru
        }
    }
}