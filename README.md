# KAIRÓS

Kairós it's a flexible task scheduler, that can be used to manage configurations of Windows servers.
By defining and combining classes, you can schedule tasks based on your environment.

# Downloading KAIRÓS

Just download or clone the repository.
```sh
git clone "https://github.com/daniloalsilva/Kairos"
```
It is preferable to use files in "C:\Program Files\Kairos", but you can use in any folder you like.

# Executing KAIRÓS

- Execute the commandline:
```powershell
    .\kairos_agent.ps1
```
## Optional parameters:

| Parameter    | Description |
|--------------|-------------|
| -debug       | Show debug information |
| -reconfigure | Reconfigure random schedules |
```powershell
    .\kairos_agent.ps1
```

# About Configurations

Configurations is to KAIRÓS like bundles in **CFEngine** or like manifests in **Puppet**.
KAIRÓS doesn't has it's own DSL, so to execute a plugin/script, you must define the command and it's args.

## Writting a configuration

Kairós configurations are based on powershell objects, pretty much like hash tables. The name of a new configuration file must match the name of a class.

This is the basic structure of a Kairós configuration file:
```powershell
<# Starting Configuration Definitions #>
@{ 
    <# Configuration Description #>
    configuration_name = new-object psobject -Property @{
        name = 'configuration_name'
        command = 'executable_path'
        args =  @( 'arg0', 'arg2' )
        ifclasses = 'class1.class2'
        orclasses = 'class3'
        deniedclasses = 'deniedclass1.deniedclass2'
        randomDelay = '8:00:00'
        runifmissed = {bool}
        delaynextrun = 'delayindays'
    }
    other_configuration_name = new-object psobject -Property @{...}
}
```
| Name | Description |
|------|-------------|
| configuration_name | Name of configuration definition |
| name | Same as configuration name. |
| command | Path of an executable to execute. |
| args | arguments to use with command. |
| ifclasses | classes that must match in order to run executable - classes must be separated by "." character (if more than one)  and all classes must match. |
| orclasses | class that must match in order to run the command - classes must be separated by "." character (if more than one)  and even one class must match. |
| deniedclasses | list of classes who can be used to deny a execution (you can insert a time range in class format to avoid executions in specific time or even a hostname to avoid execution in a specific machine) |
| randomDelay | timespan format, when a command match the needed classes to run, if the randomDelay is used, a random will be calculated and the execution will be scheduled to it's new date/time. |
| runifmissed | if a scheduled command had been missed (machine turned off, etc), run the missed executable in next execution. Works only with "randomDelay". |
| delaynextrun | If this field contains only a numeric value, it will be converted to days. If contains a time value, it will be converted to a time of timespan, with a limit of 23:59:59. After a execution, kairós will schedule a new execution using the current date/time + the time passed in this parameter. |

## Configuration Example:

```powershell
<# Starting Configuration Definitions #>
@{ 
    <# Windows BareMetal Backup #>
    baremetal = new-object psobject -Property @{
        name = 'baremetal'
        
        command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        args =  @(
            '-File ', 'C:\Program Files\SCHEDULES\WindowsBackupBareMetal.ps1',
            '-WBKeptCount', '10',
            '-WBTargetDrive','F:'
        )
        ifclasses = 'sharedplesk12.w2k12r2'
        orclasses = 'hour22'
        deniedclasses = 'host0001'
        randomDelay = '8:00:00'
        runifmissed = $true
        delaynextrun = '3'
    }
}
```