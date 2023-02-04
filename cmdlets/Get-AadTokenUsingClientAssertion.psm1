<#
.SYNOPSIS
.DESCRIPTION

.PARAMETER ClientId
.PARAMETER ClientAssertion
.PARAMETER TenantId
.PARAMETER Resource

.EXAMPLE

.NOTES
# Config.json:
@'
{
  "ClientId": "YOUR_CLIENT_ID"
  "CertificatePath": "PATH_TO_PFX"
  "CertificatePassword": "YOUR_CERT_PASSWORD"
  "TenantId": "YOUR_TENANT_ID"
}
'@ | out-file "config.json"

$settings = (Get-Content -path config.json) | ConvertFrom-Json

$Assertion = New-AadClientAssertion -ClientId $settings.ClientId -CertificatePath $settings.CertificatePath -CertificatePassword $settings.CertificatePassword -TenantId $settings.TenantId
Get-AadTokenUsingClientAssertion -ClientAssertion $Assertion -ClientId $settings.ClientId -TenantId $settings.TenantId -Resource "https://graph.microsoft.com"
#>

Function Get-AadTokenUsingClientAssertion {

    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(mandatory=$true)]
        $ClientId,

        [Parameter(mandatory=$true)]
        [string]$ClientAssertion,

        [Parameter(mandatory=$true)]
        [string]$TenantId,  

		[Parameter(mandatory=$true)]
        [string]$Resource

    )

    # Construct URI
    $uri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
 
    # Construct Body
    $body = @{
        client_id = $ClientId
        client_assertion = $ClientAssertion
        scope = "$resource/.default"
        grant_type = "client_credentials"
        client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    }
 
    # Get OAuth 2.0 Token
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType 'application/x-www-form-urlencoded' -Body $body -UseBasicParsing
 
    # Access Token
    $tokenJsonResponse = ($tokenRequest.Content | ConvertFrom-Json)
    # Write-Host "access_token = $($token)"
 
    $ReturnObject = @{
        AccessToken = $tokenJsonResponse.access_token
        Expires = (Get-Date).AddSeconds($tokenJsonResponse.expires_in)
    }
 
# Return the access token
    return $ReturnObject.AccessToken

}