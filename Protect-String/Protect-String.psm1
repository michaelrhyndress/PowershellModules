#private
$Script:KeySize = 256

function Create-AesManagedObject {
    Param (
        $key,
        $IV
    )
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = $Script:KeySize/2
    $aesManaged.KeySize = $Script:KeySize
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

#Public
function Get-AesKey {

    Param(
        [Parameter(Mandatory=$false)][String] $Key,
        [Switch] $Secure
    )

    If ($Secure) {
        $sKey = Read-Host -assecurestring "Please enter your key"
        $Key = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sKey)))
    }

    If (!$Key) {
        $aesManaged = Create-AesManagedObject
        $aesManaged.GenerateKey()
        $ByteArray = $aesManaged.Key
    } Else {
        $ByteArray = New-Object byte[] ($Script:KeySize/8)
        $Key = ConvertTo-Hash -String $Key HashName MD5
        [byte[]] $Key = [System.Text.Encoding]::UTF8.GetBytes($Key)
        for ($i=0; $i -lt $Key.length; $i++) {
            $ByteArray[$i] = $Key[$i]
        }
    }

    [System.Convert]::ToBase64String($ByteArray)
}


function Protect-String {
    Param (
        [Parameter(Mandatory=$true)][String] $String,
        [Parameter(Mandatory=$false)][String] $Key
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
    $aesManaged = Create-AesManagedObject $Key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function Unprotect-String {
    Param(
        $CipherText,
        $Key
    )

    $bytes = [System.Convert]::FromBase64String($CipherText)
    $IV = $bytes[0..15]

    Try {
        $aesManaged = Create-AesManagedObject $Key $IV
    } Catch {
        $aesManaged = Create-AesManagedObject (Get-AesKey -Key $Key) $IV
    }
    
    If (!$aesManaged) {
        throw 'Key is invalid'
    }

    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, ($Script:KeySize/2/8), $bytes.Length - ($Script:KeySize/2/8));
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

New-Alias -Name encrypt -Value Protect-String
Export-ModuleMember -Function Protect-String
Export-ModuleMember -Alias encrypt

New-Alias -Name decrypt -Value Unprotect-String
Export-ModuleMember -Function Unprotect-String
Export-ModuleMember -Alias decrypt

New-Alias -Name ekey -Value Get-AesKey
Export-ModuleMember -Function Get-AesKey
Export-ModuleMember -Alias ekey