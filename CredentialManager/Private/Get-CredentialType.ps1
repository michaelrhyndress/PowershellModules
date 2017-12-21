#
# Get-CredentialType.ps1
#

Function Get-CredentialType
{
    Param
    (
        [Parameter(Mandatory=$true)][ValidateSet("GENERIC",
                                                  "DOMAIN_PASSWORD",
                                                  "DOMAIN_CERTIFICATE",
                                                  "DOMAIN_VISIBLE_PASSWORD",
                                                  "GENERIC_CERTIFICATE",
                                                  "DOMAIN_EXTENDED",
                                                  "MAXIMUM",
                                                  "MAXIMUM_EX")][String] $CredType
    )
    
    Switch ($CredType)
    {
        "GENERIC" {return [PsUtils.CredentialManager+CRED_TYPE]::GENERIC}
        "DOMAIN_PASSWORD" {return [PsUtils.CredentialManager+CRED_TYPE]::DOMAIN_PASSWORD}
        "DOMAIN_CERTIFICATE" {return [PsUtils.CredentialManager+CRED_TYPE]::DOMAIN_CERTIFICATE}
        "DOMAIN_VISIBLE_PASSWORD" {return [PsUtils.CredentialManager+CRED_TYPE]::DOMAIN_VISIBLE_PASSWORD}
        "GENERIC_CERTIFICATE" {return [PsUtils.CredentialManager+CRED_TYPE]::GENERIC_CERTIFICATE}
        "DOMAIN_EXTENDED" {return [PsUtils.CredentialManager+CRED_TYPE]::DOMAIN_EXTENDED}
        "MAXIMUM" {return [PsUtils.CredentialManager+CRED_TYPE]::MAXIMUM}
        "MAXIMUM_EX" {return [PsUtils.CredentialManager+CRED_TYPE]::MAXIMUM_EX}
    }
}