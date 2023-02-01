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

    if($Global:AadToken)
    {
        if((Get-Date) -lt $Global:AadToken.Expires)
        {
            return $Global:AadToken
        }
    }
 
    # Construct URI
    $uri = " https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
 
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
    
    $Global:AadToken = $ReturnObject
 
# Return the access token
    return $ReturnObject.AccessToken

}