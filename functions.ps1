function GetConfigLocation ([string]$pluginName){
    
    return ($pluginsPath + '\' + $pluginName + '.conf')
}

function LoadPluginConf ([psobject]$singleConf){
    
    $config = $null

    $file = GetConfigLocation $singleConf.name
    
    # validate plugin info, if it exists and create a new if not
    if (Test-Path $file){

        # delete cache if "reconfigure" option was used
        if($reconfigure){ 
            ClearCache $file
            LogInfo ("Cache deleted: $file")
            LoadPluginConf $singleConf
        }
        else {
            $config = LoadCache $file 
            LogInfo ("Loaded cache file: $file")
            return $config
        }
    }
    else { 

        LogInfo ("Cache file dont exists: $file")
        
        # load all defined classes on the config file and validates execution need
        if ((ValidateIfClasses $singleConf.ifclasses) -and
            (ValidateOrClasses $singleConf.orclasses) -and 
            (ValidateDeniedClasses $singleConf.deniedclasses)){
            LogInfo ("Defined classes match: $($singleConf.ifclasses,$singleConf.orclasses)")
            LogInfo ("Defined denied classes: $($singleConf.deniedclasses)")
            $config = ValidateSchedule $singleConf
            return $config
        }
        else {
            # if classes not match and config file dont exists, do nothing.
            LogInfo ("Classes dont match, validation will not proceed.")
            LogInfo ("Defined classes match: $($singleConf.ifclasses,$singleConf.orclasses)")
            LogInfo ("Defined denied classes: $($singleConf.deniedclasses)")
        }
    }
}

function LoadCache ([string]$file){
    Import-Clixml $file
}

function ClearCache ([string]$cachefile){
    del $cachefile -Force
}

function LogInfo ([string]$description){
    $logdate = Get-Date
    if ($debug){
        Write-Warning $description
    }
    Add-Content -Path $logfilename -Value ("{0} - {1}" -f $logdate.ToString("yyyy-MM-dd HH:mm:ss"), $description)
}