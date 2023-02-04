function Get-AadServicePrincipal {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,ParameterSetName="ClientId")]
        [string] $ClientId,

        [parameter(Mandatory=$true,ParameterSetName="ServicePrincipalName")]
        [string]$ServicePrincipalName
    )

    if($ClientId) {
        if(IsGuid($ClientId)) {
            $sp = Get-MgServicePrincipal -Filter "appId eq '$ClientId' or id eq '$ClientId'"
        }
        else {
            $sp = Get-MgServicePrincipal -Filter "displayName eq '$ClientId'"
        }
    }

    if($ServicePrincipalName) {
        $sp = Get-MgServicePrincipal -Filter "servicePrincipalNames/any(x:x eq '$ServicePrincipalName')"
    }

    return $sp
}