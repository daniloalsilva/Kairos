
function ExecuteScheduledTask ([psobject]$singleConf){
    
    LogInfo ("Starting Schedule validation of {0}" -f $singleConf.Name)

    $config = LoadPluginConf $singleConf

    <# if its impossible to find configfile, $config will be null #>
    if ($config -ne $null){

        <# executionTime was created that way to compare date and hour, but not minutes #>
        $startdate = (Get-Date)
        $fstartdate = $startdate.ToString("yyyyMMddHH")
        $executionTime = $config.ExecutionTime
        $fexecutionTime = $executionTime.ToString("yyyyMMddHH")

        
        <# Note that in first, formated time was compared, not datetime objs #>
        if ($fexecutionTime -eq $fstartdate -or 
           ($executionTime -lt $startdate -and $singleConf.runifmissed)){
        
            LogInfo ("Scheduled ExecutionTime considered is {0}, starting execution..." -f $config.ExecutionTime.ToString("yyyy-MM-dd HH"))
            LogInfo ("Execution of " + $singleConf.Name + " started")
        
            <# Here is where execution will start #>
            Write-Host "Starting execution of $($singleConf.Name)"
            [string]$result = (RunPlugin $singleConf)
            LogInfo ("Execution of {0} was finished. The result was: {1}" -f $singleConf.Name, $result)

            <# Schedule next run #>
            ScheduleNextRun $singleConf
        }

        elseif($executionTime -gt $startdate) {
            LogInfo ("Scheduled ExecutionTime is {0} (any execution within this hour)" -f $config.ExecutionTime.ToString("yyyy-MM-dd HH:00"))
        }

        elseif($executionTime -lt $startdate) {
            LogInfo ("Scheduled execution of {0} was missed and will not run." -f $singleConf.Name)
            LogInfo ("Reconfiguring schedule of {0}." -f $singleConf.Name)
            $reconfigure = $true
            ExecuteScheduledTask $singleConf
            $reconfigure = $false
            LogInfo ("Reconfiguration finished of schedule {0}." -f $singleConf.Name)
        }
    }
    else {
        <# Probably classes does not match, do nothing #>
    } 
    
    LogInfo ("Ended Schedule of {0}" -f $singleConf.Name)
}

<# Function used to load and run specified commandline #>
function RunPlugin ([psobject]$singleConf){
    # temporary disable of stopping through exception
    $ErrorActionPreference = 'Continue'
    & $singleConf.command $singleConf.args
    $ErrorActionPreference = 'Stop'
}

function ScheduleNextRun ([psobject]$singleConf){
    
    <# 
    Create a schedule, only if a random delay was used
    This type of schedule is only needed with random, 
    else the schedule must be created with ifclasses and orclasses 
    #>
    $randomDelay = [timespan]'0:00:00'
    if([timespan]::TryParse($singleConf.randomDelay, [ref]$randomDelay)){
        
        # loading delay of next run
        $delaynextrun = [timespan]'1'
        if([timespan]::TryParse($singleConf.delaynextrun, [ref]$delaynextrun)){
            LogInfo ("Custom delay applied of {0} hours" -f $delaynextrun.TotalHours)
        }
        else {
            LogInfo ("There is no custom delay applied, default is {0} hours" -f $delaynextrun.TotalHours)
        }
        
        LogInfo ("Scheduling next execution of {0}" -f $singleConf.Name)
        $date = (Get-Date).Date
        $file = GetConfigLocation $singleConf.name
        $config = LoadCache $file
        
        # adding delay of next run
        $config.ExecutionTime = $config.ExecutionTime.Add($delaynextrun)

        Export-Clixml -Path $file -InputObject $config
        LogInfo ("Next execution of {0} was scheduled and will run, if classes still match" -f $singleConf.Name)
    }
    else{
        LogInfo ("No new schedule will be created to {0};" -f $singleConf.Name)
    }

}

function ValidateSchedule ([psobject]$singleConf){
    
    $startTime = [datetime](Get-Date)

    # if delay is null, define delay as 0:00:00
    $randomDelay = [timespan]"0:00:00"
    $boolDelay = [timespan]::TryParse($singleConf.randomDelay, [ref]$randomDelay)
    

    # validate if some delay exists and apply it
    if ($singleConf.randomDelay -ne $null -and $randomDelay.TotalMinutes -ne 0){

        [int]$randomMinutes = Get-Random $randomDelay.TotalMinutes
        LogInfo ("Random delay is $randomMinutes minutes")
        LogInfo ("Pre-defined startTime is {0}" -f $startTime.ToString("yyyy-MM-dd HH:mm:ss"))
        
        # define a valid startTime, considering actual execution and according with delay
        $executionTime = $startTime.AddMinutes($randomMinutes)
        LogInfo ("After apply delay, startTime is defined to {0}" -f $executionTime.ToString("yyyy-MM-dd HH:mm:ss"))
    }
    else { 
        $executionTime = $startTime
    }

    # define a new config for the pluginstartTime
    $config = New-Object psobject -Property @{
        ExecutionTime = $executionTime
        SoftClasses = ""
    }

    # serialize object and return it
    if($boolDelay){
        Export-Clixml -Path $file -InputObject $config
        LogInfo ("Cache loaded and serialized on $file")
    }
    return $config
}

function ValidateIfClasses ([string]$ifclasses){
    
    LogInfo ("Validating defined 'ifclasses' to determine if execution must proceed.")
    $validator = $true
    # compare validator and change flag for execution if class dont exists
    $ifclasses.Split('.') | %{
        if (! ($classes -contains $_ )){
            $validator = $false
        }
    }
    return $validator
}

function ValidateOrClasses ([string]$orclasses){
    
    LogInfo ("Validating defined 'orclasses' to determine if execution must proceed.")

    if ($orclasses -ne [String]::Empty){
        
        $validator = $false
        
        # compare validator and change flag for execution if class dont exists
        $orclasses.Split('.') | %{
            if ($classes.Contains($_)){
                $validator = $true
            }
        }
    }
    else {
        $validator = $true
    }

    return $validator
}

function ValidateDeniedClasses ([string]$deniedclasses){
    
    LogInfo ("Validating defined 'deniedclasses' to determine if execution must proceed.")

    if ($deniedclasses -ne [String]::Empty){
        
        $validator = $true
        
        # compare validator and change flag for execution if class dont exists
        $deniedclasses.Split('.') | %{
            if ($classes.Contains($_)){
                $validator = $false
            }
        }
    }
    else {
        $validator = $true
    }

    return $validator
}