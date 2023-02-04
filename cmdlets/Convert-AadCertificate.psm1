function Convert-AadCertificate {
    <#
    .SYNOPSIS
    Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability

    .DESCRIPTION
    Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability


    .PARAMETER Base64String
    The Base64Encoded Certificate

    .EXAMPLE
    Convert-AadCertificate -Base64String "MIIHkDCCBnigAwIBAgIRALENqydLHXg/u+VM04+dg2QwDQYJKoZIhvcNAQELBQAwgZ..."

    .NOTES
    General notes
    #>
    [cmdletbinding(DefaultParameterSetName="Base64")]
    param(
        [parameter(Mandatory=$true,ParameterSetName="Base64")]
        [String]
        $Base64String,

        [parameter(Mandatory=$true,ParameterSetName="Path")]
        [String]
        $Path,

        [parameter(Mandatory=$true,ParameterSetName="Certificate")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate,

        [String]$Password,

	  [parameter(ParameterSetName="Path")]
	  [parameter(ParameterSetName="ToCertificate")]
	  [parameter(ParameterSetName="ToBase64")]
        [Switch]$ToBase64,

	  [parameter(ParameterSetName="Base64")]
      [parameter(ParameterSetName="Path")]
	  [parameter(ParameterSetName="ToCertificate")]
        [Switch]$ToCertificate
    )

    # Ensure default switch if none is used
    If (!$ToBase64) {
        $ToCertificate = $true
    }

    # Format path
    if($Path -and ![System.IO.Path]::IsPathRooted($Path))
    {
        $LocalPath = Get-Location
        $Path = "$LocalPath\$Path"
    }

    if($Path)
    {
        $bytes = [System.IO.File]::ReadAllBytes("$path")
    }

    if($Base64String)
    {
        # Sometimes a Base64Encoded Cert has been Base64Encoded again (Chained Certs)
        if(-not $Base64String.StartsWith("MII") -and -not $Base64String.StartsWith("-----BEGIN"))
        {
            $Base64String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String));
        }

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Base64String)
    }

    if($Certificate) {
        $bytes = $certificate.RawData
    }
    
    
    
    if($ToCertificate) {
        $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($bytes,$Password)
        $kid = Convert-AadThumbprint -Thumbprint $cert.Thumbprint
        $Properties = @{ 
            Kid = $kid; 
            Thumbprint = $cert.Thumbprint;
            NotAfter = $cert.NotAfter;
            NotBefore = $cert.NotBefore; 
            Subject = $cert.Subject;
            Issuer = $cert.Issuer;
            Certificate = $cert;
        }
    
        $Object = new-object PSObject -Property $Properties
    
        return $Object
    }

    if($ToBase64) {
        return [System.Convert]::ToBase64String($bytes);
    }

}
