function Get-AadVerifiedIdClaimsHash {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(mandatory=$true)]
        $ClaimValue,

        [Parameter(mandatory=$true)]
        [string]$ContractId
    )

    Write-Verbose "ClaimValue: $ClaimValue"
    Write-Verbose "ContractId: $ContractId"

    [System.Security.Cryptography.SHA256]$sha256 = [System.Security.Cryptography.SHA256]::Create()
    
    $search = $contractid + $claimvalue
    $inputasbytes = [System.Text.Encoding]::UTF8.GetBytes($search)
    $hashedsearchclaimvalue = [System.Convert]::ToBase64String($sha256.ComputeHash($inputasbytes))
    
    Write-Verbose "Generated Hash"
    return [System.Web.HttpUtility]::UrlEncode($hashedsearchclaimvalue) 
}

