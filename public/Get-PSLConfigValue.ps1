function Get-PSCLConfigValue {
    <#
    .SYNOPSIS
        Gets configuration values

    .DESCRIPTION
        Gets configuration values

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    process {
        Get-PSCLConfig -Name $Name | Select-Object -ExpandProperty $Name
    }
}