#
# Get_CredentialPersist.ps1
#


Function Get-CredentialPersist {
    Param
    (
        [Parameter(Mandatory=$true)][ValidateSet("SESSION",
                                                  "LOCAL_MACHINE",
                                                  "ENTERPRISE")][String] $CredPersist
    )
    
    Switch ($CredPersist)
    {
        "SESSION" {return [PsUtils.CredentialManager+CRED_PERSIST]::SESSION}
        "LOCAL_MACHINE" {return [PsUtils.CredentialManager+CRED_PERSIST]::LOCAL_MACHINE}
        "ENTERPRISE" {return [PsUtils.CredentialManager+CRED_PERSIST]::ENTERPRISE}
    }
}