$script:ModuleRoot = $PSScriptRoot

# Import as fast as possible
function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )

    if ($doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

# Detect whether at some level dotsourcing was enforced
if ($C_dotsourcemodule) { $script:doDotSource }

# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

Register-ArgumentCompleter -ParameterName SubSound -CommandName Set-PSLConfig -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $script:sounds | Where-Object { $PSitem -match $wordToComplete } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}
Register-ArgumentCompleter -ParameterName FollowSound -CommandName Set-PSLConfig -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $script:sounds | Where-Object { $PSitem -match $wordToComplete } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}
Register-ArgumentCompleter -ParameterName Since -CommandName Get-PSLFollower -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    "StreamStart", "LastStream" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}

$config = Get-PSLConfig
if (-not $config.ClientId -and -not $config.Token) {
    Write-Warning "ClientId and Token not found. Please use Set-PSLConfig to set your ClientId and Token."
}


##################### Config setup #####################
$config = Get-PSLConfig
$dir = Split-Path -Path $config.ConfigFile
$params = @{}


$pics = "robo.png", "vibecat.gif", "bits.gif", "catparty.gif", "yay.gif",  "bot.ico"
foreach ($pic in $pics) {
    if (-not (Test-Path -Path "$dir\$pic")) {
        Copy-Item -Path "$script:ModuleRoot\images\$pic" -Destination "$dir\$pic"
    }
}

$settings = "BotIcon"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\bot.ico")
    }
}

$settings = "RaidIcon", "SubIcon", "SubGiftedIcon"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\yay.gif")
    }
}

$settings = "RaidImage", "SubImage", "SubGiftedImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\catparty.gif")
    }
}

if (-not $config.BitsIcon) {
    $params.BitsIcon = (Resolve-XPlatPath -Path "$dir\bits.gif")
}


$settings = "BitsImage", "FollowImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\vibecat.gif")
    }
}

######### Set variables and write to file
if ((Get-PSLSystemTheme).Theme -eq "dark") {
    $color = "White"
} else {
    $color = "Black"
}

$newparams = @{
    BitsSound        = "ms-winsoundevent:Notification.Mail"
    BitsText         = "Thanks so much for the <<bitcount>>, <<username>> 🤩"
    BitsTitle        = "<<username>> shared bits!"
    BotClientId      = $null # set to null to lets user know its available
    BotIconColor     = $color
    BotKey           = "!"
    BotOwner         = $null
    BotToken         = $null
    UsersToIgnore    = $null
    DefaultFont      = "Segoe UI"
    FollowIcon       = $null # gets icon from the net but can default to this
    FollowSound      = "ms-winsoundevent:Notification.Mail"
    FollowText       = "Thanks so much for the follow, <<username>>!"
    FollowTitle      = "New follower 🥳"
    NotifyColor      = $color
    NotifyType       = "none"
    RaidSound        = "ms-winsoundevent:Notification.IM"
    RaidText         = $null # disabled for now bc the raid info comes from twitch
    RaidTitle        = "IT'S A RAID!"
    Sound            = "Enabled"
    SubGiftedText    = "Thank you so very much for gifting a Tier <<tier>> sub, <<gifter>>!"
    SubGiftedTitle   = "<<gifter>> has gifted <<giftee>> a sub 🤯"
    SubGiftedSound   = "ms-winsoundevent:Notification.Mail"
    SubSound         = "ms-winsoundevent:Notification.Mail"
    SubText          = "Thank you so very much for the tier <<tier>> sub, <<username>> 🤗"
    SubTitle         = "AWESOME!!"
    ScriptsToProcess = $null
}

foreach ($key in $newparams.Keys) {
    if (-not $config.$key) {
        $params.$key = $newparams[$key]
    }
}

$config = Set-PSLConfig @params -Force
if (-not $config.BotClientId -and -not $config.BotToken) {
    Write-Warning "BotClientId and BotToken not found. Please use Set-PSLConfig to set your BotClientId and BotToken. If no BotChannel is set, the bot will join its own channel."
}


$script:logger = New-Logger