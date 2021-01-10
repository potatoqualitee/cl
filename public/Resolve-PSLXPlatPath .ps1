function Resolve-XPlatPath {
    [CmdletBinding()]
    param (
        [string]$Path
    )
    process {
        if ($env:OS -eq "Windows_NT") {
            $Path
        } else {
            $Path.Replace("\","/")
        }
    }
}