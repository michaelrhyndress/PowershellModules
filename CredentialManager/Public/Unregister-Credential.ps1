#
# Unregister_Credentials.ps1
#

Function Unregister-Credential
{
<#
.Synopsis
  Deletes the specified credentials

.Description
  Calls Win32 CredDeleteW via [PsUtils.CredentialManager]::CredDelete

.INPUTS
  See function-level notes

.OUTPUTS
  0 or non-0 according to action success
  [Management.Automation.ErrorRecord] if error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"
#>

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
                                                  "MAXIMUM_EX")][String] $CredType = "GENERIC"
    )
    
    [Int] $Results = 0
    Try {
        $Results = [PsUtils.CredentialManager]::CredDelete($Target, $(Get-CredentialType $CredType))
    } Catch {
		throw $_
    }

    If (0 -ne $Results)
    {
        [String] $Msg = "Failed to delete credentials store for target '$Target'"
        [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
        [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $Script:ErrorCategory[$Results], $null)
        throw $ErrRcd
    }
}
