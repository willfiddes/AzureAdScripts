Function New-AadCertificate {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [String] $Password,

        [parameter(Mandatory=$true)]
        [String] $ApplicationId,

        [Switch] $AddToApplication
    )

    $SecuredPassword = ConvertTo-SecureString $Password -AsPlainText -Force

    $notAfter = (Get-Date).AddYears(10)

    # Start creating Certificate file name format with the ApllicationId
    $FileName = $ApplicationId

    $cert = (New-SelfSignedCertificate -DnsName "$ApplicationId" -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter -KeyUsage DigitalSignature -KeySpec KeyExchange)
    
    $Thumbprint = $cert.Thumbprint

    # Concatenate the Thumbpring to the file name...
    $FileName += "-$Thumbprint"

    # Export cert as .cer (Public Cert)
    Export-Certificate -Cert $cert -FilePath "$FileName.cer" | Out-Null

    # Export cert as .pfx (Cert with Private Key)
    Export-PfxCertificate -Cert $cert -FilePath "$FileName.pfx" -Password $SecuredPassword | Out-Null

    if($AddToApplication) {

        Connect-MgGraph -scopes Application.ReadWrite.All

        $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
        #$KeyCredential = New-AzureADApplicationKeyCredential -ObjectId $app.ObjectId -CustomKeyIdentifier $keyid -Type AsymmetricX509Cert -Usage Verify -Value $keyValue


        $KeyCredential = @{
            Type = "AsymmetricX509Cert"
            Usage = "Verify"
            Key = [System.Text.Encoding]::ASCII.GetBytes($keyValue)
            displayName = "added using MS Graph "+(Get-Date)
        }

        $app = Get-MgApplication -Filter "appId eq '$ApplicationId'" -ErrorVariable err

        $KeyCredentials = $app.KeyCredentials
        $KeyCredentials += $KeyCredential

        Update-MgApplication -ApplicationId $app.id -KeyCredentials $KeyCredentials -ErrorVariable err

        if($err)
        {
            throw $err
        }
    }


    return [PSCustomObject]@{
        Thumbprint = $Thumbprint
        KeyId = Convert-AadThumbprint -Thumbprint $Thumbprint
        PublicValue = [System.Convert]::ToBase64String($Cert.RawData)
    }
}