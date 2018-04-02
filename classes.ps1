<# Starting Configuration Definitions #>

<# Computer Details #>

$os = gwmi win32_operatingsystem
$cs = gwmi win32_computersystem

$cs.Name
$cs.Domain

$cs.Manufacturer
$os.OSArchitecture
$os.Caption
"windows_$($os.Version)"

<# Getting OU attributes #>

$filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$env:COMPUTERNAME))"
$serverAttr = ([adsisearcher]$filter).FindOne().Properties
$serverAttr.distinguishedname -split ',' | %{ if($_ -match 'OU=*'){ $_.Split('=')[1] } }


<# Getting Datetime attributes #>

$date = (Get-Date)
$fdate = $date.ToString("{1}yyyy,MMMM,{0}d,dddd,{2}HH,{3}mm",[System.Globalization.CultureInfo]::InvariantCulture)
[String]::Format($fdate,"Day","Year","Hour","Min").Split(',')

if ($date.Minute -ge 0 -and $date.Minute -lt 30) { "Min0_30" }
else { if ($date.Minute -ge 30) { "Min30_60" }}
