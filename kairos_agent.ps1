Param(
    [switch]$debug,
    [switch]$reconfigure
)

<# Define Kairós Path and main variables #>
$kairosPath = $PSScriptRoot
$logsPath = "$kairosPath\logs"
if (! (Test-Path $logsPath )){ mkdir $logsPath | Out-Null }
$logfilename = "{0}\{1}.log" -f $logsPath, (Get-Date).ToString("yyyyMMdd")
$confPath = "$kairosPath\config"
$pluginsPath = "$confPath\plugins"
if (! (Test-Path $pluginsPath )){ mkdir $pluginsPath | Out-Null }

$ErrorActionPreference = 'Stop'

<# Load Functions #>
. "$kairosPath\functions.ps1"
. "$kairosPath\executors.ps1"

LogInfo ("~KAIRÓS execution started, debug option is $debug")

<# Load Hard Classes #>
$classes = (& "$kairosPath\classes.ps1") | % { $_.ToLower().Replace(' ','_').Replace('-','_').Replace('.','_') }
LogInfo "Hard Classes: $classes"

<# Validate ServerTypes on Classes and collect avaliable configuration #>
$config = $classes | %{
    $main = "$confPath\$_.ps1"
    if (Test-Path $main){ 
        & $main
        LogInfo ("File found to use as ServerType: $_")
    }
}
LogInfo ("Configurations found: $($config.Keys)")


<# Validate and execute available configurations scheduled to run #>
if ($config -ne $null){
    $config.Keys | %{
        LogInfo ("-- Starting validation of: $_")
        ExecuteScheduledTask $config.$_
    }
}
else {
    "There is no configuration to load this time."
}

LogInfo ("~KAIRÓS execution stopped")