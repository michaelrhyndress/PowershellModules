#
# Get-StoredCredential.ps1
#

Function Get-StoredCredential {
<#
.Synopsis
  Reads specified credentials for operating user

.Description
  Calls Win32 CredReadW via [PsUtils.CredentialManager]::CredRead

.INPUTS

.OUTPUTS
  [PsUtils.CredentialManager+Credential] if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  If not provided, the username is used as the target
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"
#>
  [CmdletBinding(DefaultParameterSetName="All")]
	Param
    (
        [Parameter(Mandatory=$true)][ValidateLength(1,32767)][String] $Target,
        [Parameter(Mandatory=$false)][ValidateSet("GENERIC",
                                                  "DOMAIN_PASSWORD",
                                                  "DOMAIN_CERTIFICATE",
                                                  "DOMAIN_VISIBLE_PASSWORD",
                                                  "GENERIC_CERTIFICATE",
                                                  "DOMAIN_EXTENDED",
                                                  "MAXIMUM",
                                                  "MAXIMUM_EX")][String] $CredType = "GENERIC",
        [Parameter(Mandatory=$false,ParameterSetName ="PSCredential")][String] $EncryptionKey,
        [Parameter(Mandatory=$false,ParameterSetName ="PSCredential")][switch] $PSCredential
    )

	#CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
	If ("GENERIC" -ne $CredType -and 337 -lt $Target.Length) {
        [String] $Msg = "Target field is longer ($($Target.Length)) than allowed (max 337 characters)"
        [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
        [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, 666, 'LimitsExceeded', $null)
        return $ErrRcd
    }

	[PsUtils.CredentialManager+Credential] $Cred = New-Object PsUtils.CredentialManager+Credential

    [Int] $Results = 0
    Try {
        $Results = [PsUtils.CredentialManager]::CredRead($Target, $(Get-CredentialType $CredType), [Ref]$Cred)
    } Catch {
        throw $_
    }

	Switch ($Results) {
        0 {break}
        0x80070490 {return $null} #ERROR_NOT_FOUND
        Default {
            [String] $Msg = "Error reading credentials for target '$Target' from '$Env:UserName' credentials store"
            [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
            [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
            return $ErrRcd
        }
    }

    #return as PSCred object
    If ($PSCredential) {
        $SecU = Unprotect-String -CipherText ($Cred.UserName) -Key $EncryptionKey
        $SecP = ConvertTo-SecureString (Unprotect-String -CipherText ($Cred.CredentialBlob) -Key $EncryptionKey) -AsPlainText -Force
        return New-Object System.Management.Automation.PSCredential($SecU, $SecP)
    }

    return $Cred

}