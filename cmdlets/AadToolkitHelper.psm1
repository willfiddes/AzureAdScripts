
function Add-AadConsentApplicationPermission {
    # REQUIRED FUNCTIONS IN THIS MODULE
    # IsGuid

    [cmdletbinding()]
    param(
        $TenantId,

        [parameter(Mandatory=$true)]
        $ClientId,
        
        $ResourceId = "00000003-0000-0000-c000-000000000000",
        
        [parameter(Mandatory=$true)]
        $Permissions
    )

    # Connect to Microsoft Graph
    # Uncomment the next line if you need to Install the module (You need admin on the machine)
    # Install-Module AzureAD
    Connect-MgGraph -TenantId $TenantID -Scopes User.Read,Application.Read.All,AppRoleAssignment.ReadWrite.All

    # Create proper collection of permissions to be added
    $Permissions = $Permissions.Replace(" ","").Replace(",", " ").Split(" ")

    # First: Lets find the client app
    if(IsGuid($ClientId)) {
        $spClient = Get-MgServicePrincipal -Filter "appId eq '$ClientId' or id eq '$ClientId'"
    }
    else {
        $spClient = Get-MgServicePrincipal -Filter "displayName eq '$ClientId'"
    }

    # Second: Lets find the resource app
    if(IsGuid($ResourceId)) {
        $spResource = Get-MgServicePrincipal -Filter "appId eq '$ResourceId' or id eq '$ResourceId'"
    }
    else {
        $spResource = Get-MgServicePrincipal -Filter "displayName eq '$ResourceId'"
    }

    # Add permissions
    foreach($permission in $Permissions)
    {
        $AppRole = $spResource.AppRoles | Where-Object {$_.Value -eq $permission -and $_.AllowedMemberTypes -contains "Application"}

        $BodyParameters = @{
            principalId = $spClient.Id
            resourceId = $spResource.Id
            appRoleId = $AppRole.Id
        }

        New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $spClient.Id -BodyParameter $BodyParameters | Out-Null
    }

    Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $spClient.Id
}



Function Get-AadAccessToken() {
    [cmdletbinding()]
    param(
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $Instance = "https://login.microsoftonline.com",

        [parameter(Mandatory=$true)]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $ClientId,

        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $TenantId = "organizations",

        [parameter(ParameterSetName="ClientCredential")]
        [string] $ClientSecret,

        [parameter(ParameterSetName="ClientCredential")]
        [string] $ClientAssertion,

        [parameter(Mandatory=$true)]
        [parameter(ParameterSetName="ROPC")]
        [string] $Username,

        [parameter(Mandatory=$true)]
        [parameter(ParameterSetName="ROPC")]
        [string] $Password,

        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        $Scopes = ".default",

        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $Resource = "https://graph.microsoft.com",

        [switch] $ForceRefresh
    )   

    if($ForceRefresh) {
        $Global:AadToken = $null
    }

    if($ClientSecret -and $ClientAssertion) {
        throw "Run command with either ClientSecret or ClientAssertion"
    }

    if($Global:AadToken)
    {
        if((Get-Date) -lt $Global:AadToken.Expires)
        {
            return $Global:AadToken.AccessToken
        }
    }
    
    # Build Scopes
    $ListScopes = @()
    $Scopes = $Scopes.Split(" ").Split(",")
    foreach($scope in $Scopes) {
        $ListScopes += "$Resource/$scope"
    }
    $Scopes = $ListScopes -Join " "

    # Construct Body
    if ($ClientSecret) {
        $body = @{
            client_id = $clientId
            client_secret = $clientSecret
            scope = $Scopes
            grant_type = 'client_credentials'
        }
    }
    elseif ($ClientAssertion) {
        $body = @{
            client_id = $clientId
            client_assertion = $ClientAssertion
            scope = $Scopes
            grant_type = 'client_credentials'
        }
    } else {
        $body = @{
            client_id = $ClientId
            username = $Username
            password = $Password
            scope = "$Resource/.default"
            grant_type = 'password'
        }
    }

    # Construct URI
    $uri = "$Instance/$TenantId/oauth2/v2.0/token"

 
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


Function Get-AadTokenUsingMsal() {
    [cmdletbinding(DefaultParameterSetName="Interactive")]
    param(
        [parameter(ParameterSetName="Interactive")]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $Instance = "https://login.microsoftonline.com",

        [parameter(Mandatory=$true)]
        [parameter(ParameterSetName="Interactive")]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $ClientId,

        [parameter(ParameterSetName="Interactive")]
        [string] $RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient",

        [parameter(ParameterSetName="Interactive")]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $TenantId = "organizations",

        [parameter(ParameterSetName="ClientCredential")]
        [string] $ClientSecret,

        [parameter(ParameterSetName="ClientCredential")]
        [string] $ClientAssertion,

        [parameter(Mandatory=$true, ParameterSetName="ROPC")]
        [parameter()]
        [string] $Username,

        [parameter(Mandatory=$true, ParameterSetName="ROPC")]
        [string] $Password,

        [parameter(ParameterSetName="Interactive")]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        $Scopes = ".default",

        [parameter(ParameterSetName="Interactive")]
        [parameter(ParameterSetName="ClientCredential")]
        [parameter(ParameterSetName="ROPC")]
        [string] $Resource = "https://graph.microsoft.com",

        [switch] $ForceRefresh
    ) 

    if($ForceRefresh) {
        $global:app = $null
    }

    # Build Scopes
    [string[]]$ListedScopes = @()
    $Scopes = $Scopes.Split(" ").Split(",")
    foreach($scope in $Scopes) {
        $ListedScopes += "$Resource/$scope"
    }

    [Microsoft.Identity.Client.AuthenticationResult] $authResult  = $null

    if(!$global:app) {
        if($ClientSecret -or $ClientAssertion) {
            $ClientApplicationBuilder = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($ClientID)
            [void]$ClientApplicationBuilder.WithAuthority($("$Instance/$TenantId"))
    
            if($ClientSecret) {
                [void]$ClientApplicationBuilder.WithClientSecret($("$ClientSecret"))
            }
            if($ClientAssertion) {
                [void]$ClientApplicationBuilder.WithClientAssertion($("$ClientAssertion"))
            }
    
            $global:app = $ClientApplicationBuilder.Build()
        } else {
            $ClientApplicationBuilder = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($ClientID)
            [void]$ClientApplicationBuilder.WithAuthority($("$Instance/$TenantId"))
            [void]$ClientApplicationBuilder.WithRedirectUri($RedirectUri)
            $global:app = $ClientApplicationBuilder.Build()
        }
    }


    # Using Client Credential flow
    if($ClientSecret) {
        $AquireTokenParameters = $global:app.AcquireTokenForClient($ListedScopes)
        try {
            $authResult = $AquireTokenParameters.ExecuteAsync().GetAwaiter().GetResult()
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage
        }
    }

    # Using Resource Owner Password Credential flow
    if($Password) {
        try {
            $accounts = $global:app.GetAccountsAsync().GetAwaiter().GetResult()
            $account = $accounts.FirstOrDefault();
            $AquireTokenParameters = $global:app.AcquireTokenSilent($ListedScopes, $account)
            $authResult = $AquireTokenParameters.ExecuteAsync().GetAwaiter().GetResult()
        }
        catch {
            try {
                $SecuredPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
                $AquireTokenParameters = $global:app.AcquireTokenByUsernamePassword($ListedScopes, $Username, $SecuredPassword)
                $authResult = $AquireTokenParameters.ExecuteAsync().GetAwaiter().GetResult()
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host $ErrorMessage
            }
        }
    }

    # Using Interactive flow i.e. Authorization Code flow
    if(!$ClientSecret -and !$Password) {
        try {
            $accounts = $global:app.GetAccountsAsync().GetAwaiter().GetResult()
            $account = $accounts.FirstOrDefault();
            $AquireTokenParameters = $global:app.AcquireTokenSilent($ListedScopes, $account)
            $authResult = $AquireTokenParameters.ExecuteAsync().GetAwaiter().GetResult()
        }
        catch {
            try {
                $AquireTokenParameters = $global:app.AcquireTokenInteractive($ListedScopes)
                $authResult = $AquireTokenParameters.ExecuteAsync().GetAwaiter().GetResult()
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host $ErrorMessage
            }
        }
    }

    return $authResult.AccessToken
}




# ++++++++++++++++++++++++++++++++++++++++++++++
# HELPER FUNCTIONS
# ++++++++++++++++++++++++++++++++++++++++++++++
function Base64UrlEncode($Value){
    return $Value.Replace("=", [String]::Empty).Replace('+', '-').Replace('/', '_')
}

function Base64UrlDecode($Value){
    while($Value.Length % 4 -ne 0)
    {
        $Value += "="
    }
    
    return $Value.Replace('-', '+').Replace('_', '/')
}

function IsGuid($GuidString) {
    $ObjectGuid = [System.Guid]::empty
    # Returns True if successfully parsed, otherwise returns False.
    return [System.Guid]::TryParse($GuidString,[System.Management.Automation.PSReference]$ObjectGuid)
}