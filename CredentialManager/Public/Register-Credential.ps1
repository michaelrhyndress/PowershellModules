#
# Register_Credential.ps1
#

Function Register-Credential {
<#
.Synopsis
  Saves or updates specified credentials for operating user

.Description
  Calls Win32 CredWriteW via [PsUtils.CredMan]::CredWrite

.INPUTS

.OUTPUTS
  [Boolean] true if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  If not provided, the username is used as the target
  
.PARAMETER UserName
  Specifies the name of credential to be read
  
.PARAMETER Password
  Specifies the password of credential to be read
  
.PARAMETER Comment
  Allows the caller to specify the comment associated with 
  these credentials
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"

.PARAMETER CredPersist
  Specifies the desired credentials storage type;
  defaults to "CRED_PERSIST_ENTERPRISE"
#>

	Param
    (
        [Parameter(Mandatory=$false)][ValidateLength(0,32676)][String] $Target,
        [Parameter(Mandatory=$false)][System.Management.Automation.CredentialAttribute()] $Credential,
        [Parameter(Mandatory=$false)][String] $EncryptionKey,
        [Parameter(Mandatory=$false)][ValidateLength(0,256)][String] $Comment = [String]::Empty,
        [Parameter(Mandatory=$false)][ValidateSet("GENERIC",
                                                  "DOMAIN_PASSWORD",
                                                  "DOMAIN_CERTIFICATE",
                                                  "DOMAIN_VISIBLE_PASSWORD",
                                                  "GENERIC_CERTIFICATE",
                                                  "DOMAIN_EXTENDED",
                                                  "MAXIMUM",
                                                  "MAXIMUM_EX")][String] $CredType = "GENERIC",
        [Parameter(Mandatory=$false)][ValidateSet("SESSION",
                                                  "LOCAL_MACHINE",
                                                  "ENTERPRISE")][String] $CredPersist = "ENTERPRISE"
    )

    If (!$Credential) {
      Try {
        $Credential = (Get-Credential)
      } Catch {
        throw $_
      }
    }


    $UserName = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password

	  If ([String]::IsNullOrEmpty($Target)) {
        $Target = $UserName
    }

	#region Encrypt Password and UserName
  If ($EncryptionKey) {
    $AESKey = Get-AesKey -Key $EncryptionKey
  }

  If ($AESKey) {
    $Password = Protect-String -String $Password -Key $AESKey
    $UserName = Protect-String -String $UserName -Key $AESKey
  }
  #endregion Encrypt Password and UserName

	#CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
	If ("GENERIC" -ne $CredType -and 337 -lt $Target.Length) {
        [String] $Msg = "Target field is longer ($($Target.Length)) than allowed (max 337 characters)"
        [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
        [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, 666, 'LimitsExceeded', $null)
        throw $ErrRcd
    }

	If ([String]::IsNullOrEmpty($Comment)) {
        $Comment = [String]::Format("Last edited by {0}\{1} on {2}",
                                    $Env:UserDomain,
                                    $Env:UserName,
                                    $Env:ComputerName)
    }

	#[String] $DomainName = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    
	#region Create Cred Object
	[PsUtils.CredentialManager+Credential] $Cred = New-Object PsUtils.CredentialManager+Credential
	If ($Target -eq $UserName -and 
           ("CRED_TYPE_DOMAIN_PASSWORD" -eq $CredType -or 
            "CRED_TYPE_DOMAIN_CERTIFICATE" -eq $CredType))
    {
		$Cred.Flags = [PsUtils.CredentialManager+CRED_FLAGS]::USERNAME_TARGET
	} Else {
		$Cred.Flags = [PsUtils.CredentialManager+CRED_FLAGS]::NONE
	}

	$Cred.Type = Get-CredentialType $CredType
    $Cred.TargetName = $Target
    $Cred.UserName = $UserName
    $Cred.AttributeCount = 0
    $Cred.Persist = Get-CredentialPersist $CredPersist
    $Cred.CredentialBlobSize = [Text.Encoding]::Unicode.GetBytes($Password).Length
    $Cred.CredentialBlob = $Password
    $Cred.Comment = $Comment
	#endregion Create Cred Object

	[Int] $Results = 0
    Try {
		$Results = [PsUtils.CredentialManager]::CredWrite($Cred)
    }
    Catch{
        throw $_
    }

	If($Results -ne 0) {
        [String] $Msg = "Failed to write to credentials store for target '$Target' using '$UserName', '$Password', '$Comment'"
        [Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
        [Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $Script:ErrorCategory[$Results], $null)
        return $ErrRcd
    }
}