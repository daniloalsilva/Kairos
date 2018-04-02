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
        randomDelay = '8:00:00'
        runifmissed = $true
        delaynextrun = '3'
    }

    <# Plesk Panel Access Restriction #>
    plesk_panel_access_restriction = new-object psobject -Property @{
        name = 'plesk_panel_access_restriction'
        command = 'C:\Program Files\Schedules\Panel_Access_Restriction\Set-AllowedIps.ps1'
        args =  @()
        ifclasses = 'sharedplesk12.w2k12r2'
    }
    
    <# Plesk Panel Domain Restriction #>
    plesk_panel_domain_restriction = new-object psobject -Property @{
        name = 'plesk_panel_domain_restriction'
        command = 'C:\Program Files\Schedules\Restricted_Domains\Restrict-DomainList.ps1'
        args =  @()
        ifclasses = 'sharedplesk12.w2k12r2'
    }

    <# nxlog Config #>
    nxlog_conf = new-object psobject -Property @{
        name = 'nxlog_conf'
        command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        args =  @(
            '-File', 'C:\Program Files\Kairos\config\plugins\UpdateServiceConfigFile.ps1',
            '-serviceName', 'nxlog',
            '-cachedFile', 'C:\Program Files\CacheConfigFiles\nxlog.conf',
            '-prodFile', 'C:\Program Files (x86)\nxlog\conf\nxlog.conf' 
            )
        ifclasses = 'sharedplesk12.w2k12r2'
    }

    <# check_mk Config #>
    check_mk_config = new-object psobject -Property @{
        name = 'check_mk_config'
        command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        args =  @(
            '-File', 'C:\Program Files\Kairos\config\plugins\UpdateServiceConfigFile.ps1',
            '-serviceName', 'check_mk_agent',
            '-cachedFile', 'C:\Program Files\CacheConfigFiles\check_mk.ini',
            '-prodFile', 'C:\Program Files\check_mk\check_mk.ini' 
            )
        ifclasses = 'sharedplesk12.w2k12r2'
    }

    <# Plesk Hash Config #>
    pleskhash_config = new-object psobject -Property @{
        name = 'pleskhash_config'
        command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        args =  @(
            '-File', 'C:\Program Files\Kairos\config\plugins\UpdateServiceConfigFile.ps1',
            '-serviceName', 'PleskHashWebService',
            '-cachedFile', 'C:\Program Files\CacheConfigFiles\PleskHash.Web.Console.exe.config',
            '-prodFile', 'C:\Program Files (x86)\Plesk Hash\PleskHash.Web.Console.exe.config' 
            )
        ifclasses = 'sharedplesk12.w2k12r2'
    }

    <# Windows BareMetal Backup #>
    baremetal_sharedplesk12_w2k8r2 = new-object psobject -Property @{
        name = 'baremetal'
        
        command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        args =  @(
            '-File ', 'C:\Program Files\SCHEDULES\WindowsBackupBareMetal.ps1',
            '-WBKeptCount', '10',
            '-WBTargetDrive','M:'
        )
        ifclasses = 'sharedplesk12.w2k8r2'
        orclasses = 'hour22'
        randomDelay = '8:00:00'
        runifmissed = $true
        delaynextrun = '3'
    }
    
    <# nxlog Configuration #>
    nxlog_conf_sharedplesk12_w2k8r2 = new-object psobject -Property @{
        name = 'nxlog_conf'
        
        command = 'powershell.exe'
        args =  @(
            '-File', 'C:\Program Files\Kairos\config\plugins\UpdateServiceConfigFile.ps1', 
            '-serviceName', 'nxlog',
            '-cachedFile', '\\domain.local\sysvol\domain.local\scripts\GroupPoliciesFiles\ConfigurationManager\W2K8R2\SharedPlesk11_5\CONFIG\nxlog.conf', 
            '-prodFile', 'C:\Program Files (x86)\nxlog\conf\nxlog.conf' 
            )
        ifclasses = 'sharedplesk12.w2k8r2'
        randomDelay = ''
        runifmissed = $false
    }
}
<# End Configuration Definitions #>