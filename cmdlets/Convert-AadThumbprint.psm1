Function Convert-AadThumbprint {
    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true,ParameterSetName="Thumbprint")]
        [String] $Thumbprint,

        [parameter(Mandatory=$true,ParameterSetName="Base64")]
        [String] $Base64String
    )

    if($Thumbprint)
    {
        $Thumbprint = $Thumbprint.Replace("-","")
        # Convert Thumbprint to Bytes
        $Bytes = [byte[]]::new($Thumbprint.Length / 2)

        For($i=0; $i -lt $Thumbprint.Length; $i+=2){
            $Bytes[$i/2] = [convert]::ToByte($Thumbprint.Substring($i, 2), 16)
        } 

        $hashedString =[Convert]::ToBase64String($Bytes)

        $hashedString = $hashedString.Split('=')[0]
        $hashedString = $hashedString.Replace('+', '-')
        $hashedString = $hashedString.Replace('/', '_')

        return $hashedString
    }

    if($Base64String)
    {
        while($Base64String.Length % 4 -ne 0)
        {
            $Base64String += "="
        }
    
        $Bytes =[Convert]::FromBase64String($Base64String.Replace("-","+").Replace("_","/"))
        $Thumbprint = [BitConverter]::ToString($Bytes);
    
        return $Thumbprint
    }
}