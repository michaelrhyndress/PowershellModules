function ConvertTo-Hash {
	Param (
		[Parameter(Mandatory=$true)][String] $String,
        [Parameter(Mandatory=$false)][String] $Salt = "Pr0TectM3!",
		[Parameter(Mandatory=$false)][ValidateSet("MD5",
                                                  "RIPEMD160",
                                                  "SHA1",
                                                  "SHA256",
                                                  "SHA384",
                                                  "SHA512")][String] $HashName = "SHA256"
	)

	$Encoding = [System.Text.Encoding]::UTF8

	#region String to Byte
	$String = $Encoding.GetBytes($String);
	#endregion String to Byte

	#region Salt String
	$Salt = $Encoding.GetBytes($Salt)
    $String += $Salt
	#endregion Salt String

    #region Build Hash
	$StringBuilder = New-Object System.Text.StringBuilder
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash($Encoding.GetBytes($String))|%{
	   [Void]$StringBuilder.Append($_.ToString("x2"))
	}
    #region Build Hash
	$StringBuilder.ToString()
}


New-Alias -Name hstring -Value ConvertTo-Hash
Export-ModuleMember -Function ConvertTo-Hash
Export-ModuleMember -Alias hstring