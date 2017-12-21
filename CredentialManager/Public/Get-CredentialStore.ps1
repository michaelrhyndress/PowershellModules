#
# Get-CredentialStore.ps1
#
Function Get-CredentialStore {
<#
.Synopsis
  Enumerates stored credentials for operating user

.Description
  Calls Win32 CredEnumerateW via [PsUtils.CredentialManager]::CredEnum

.INPUTS
  

.OUTPUTS
  [PsUtils.CredentialManager+Credential[]] if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Filter
  Specifies the filter to be applied to the query
  Defaults to [String]::Empty
#>

	Param
    (
        [Parameter(Mandatory=$false)][AllowEmptyString()][String] $Filter = [String]::Empty
    )
    
    [PsUtils.CredentialManager+Credential[]] $Creds = [Array]::CreateInstance([PsUtils.CredentialManager+Credential], 0)
    [Int] $Results = 0
    Try {
        $Results = [PsUtils.CredentialManager]::CredEnum($Filter, [Ref]$Creds)
    }
    Catch {
        return $_
    }
    switch($Results)
    {
        0 {break}
        0x80070490 {break} #ERROR_NOT_FOUND
        default
        {
            [String] $Msg = "Failed to enumerate credentials store for user '$Env:UserName'"
            [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
            [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
            return $ErrRcd
        }
    }
    return $Creds

}