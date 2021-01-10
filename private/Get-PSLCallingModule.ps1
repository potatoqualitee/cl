function Get-PSLCallingModule {
    (Get-Command (Get-PSCallStack | Where-Object Command -ne "<ScriptBlock>" | Select-Object -Last 1 -ExpandProperty Command )).Module.Name
}