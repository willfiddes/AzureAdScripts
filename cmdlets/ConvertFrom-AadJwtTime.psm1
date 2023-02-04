function ConvertFrom-AadJwtTime {
    <#
    .SYNOPSIS
    Convert the NumericDate format from JWT tokens to a friendly date format in UTC
    
    .DESCRIPTION
    Convert the long number format from JWT tokens to UTC
    For example convert '1557162946' to '2019-05-06T22:15:46.0000000Z'

    What is NumericDate?  A JSON numeric value representing the number of seconds from
    1970-01-01T00:00:00Z UTC until the specified UTC date/time, ignoring leap seconds.  
    See RFC 3339 [RFC3339] for details 

    .PARAMETER JwtNumberDateTime
    This is the JWT number format (i.e. 1557162946)
    
    .EXAMPLE
    ConvertFrom-AadJwtTime 1557162946
    
    .NOTES
    General notes
    #>
        Param (
            [Parameter(ValueFromPipeline = $true,Mandatory=$true)]
            [string]
            $JwtDateTime
        )
        
        $date = (Get-Date -Date "1/1/1970").AddSeconds($JwtDateTime)
        return $date
}