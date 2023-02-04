
#function Import-AadToolkit {
    Get-Module | where-object {$_.Version -eq "0.0" -and $_.Name -match "aad"} | Remove-Module

    # Get the current Script path
    $Path = $PSScriptRoot
    if(!$Path) {
        $Path = Get-Location
    }

    # Import AadToolkit scripts
    $scripts = Get-ChildItem -Path $Path/cmdlets | where-object {$_.name -match ".psm1" }
    foreach($script in $scripts) {
        Import-Module $($script.fullname) -Global -Force -PassThru | Select-Object Name
    }

    # If Error; Stop import and throw error
    if($err) {
        throw $err
    }
#}