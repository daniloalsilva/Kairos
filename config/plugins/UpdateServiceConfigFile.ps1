Param(
    [Parameter(Mandatory=$True)]
    [string]$serviceName,
    
    [Parameter(Mandatory=$True)]
    [string]$cachedFile,
    
    [Parameter(Mandatory=$True)]
    [string]$prodFile
)

function CompareFileDate ($file1, $file2){

    # Verify if $file1 exists. If not, return $true and do nothing
    if (Test-Path $file1){

        $file1 = (Get-ItemProperty $file1)

        # Verify if $file2 exists. If not, return $false and proceed file copy
        if(Test-Path $file2){

            $file2 = (Get-ItemProperty $file2)
            
            # If Last Write Time is equal between files, return $true and do nothing
            if ($file1.LastWriteTime -eq $file2.LastWriteTime){
            
                return $true
            
            }
            else { return $false }
        }
        else { return $false }
    }
    else { $true }
}

if (!(CompareFileDate $cachedFile $prodFile)){
    
    $name = (Get-ItemProperty $cachedFile).Name
    "Files $name are diferent in cached path, overwriting..."
    Copy-Item -Path $cachedFile -Destination $prodFile -Force
    
    if (CompareFileDate $cachedFile $prodFile){
        "Files overwrited. Restarting service $serviceName"
        Restart-Service $serviceName -Force
        "Done"
    }
    else { "Files can't be overwrited." }
}
else { <#do nothing#> }