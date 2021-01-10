function Get-PSLConfigFile {
    [CmdletBinding()]
    param(
        [string]$Module = (Get-PSLCallingModule)
    )
    Get-process {
        switch ($PSVersionTable.Platform) {
            "Unix" { $script:configfile = "$home/$Module/config.json" }
            default { $script:configfile = "$env:APPDATA\$Module\config.json" }
        }

        if (-not (Test-Path -Path $script:configfile)) {
            $null = New-ConfigFile
        }
    }
}