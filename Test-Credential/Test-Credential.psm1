function Test-Credential {
    <#
    .SYNOPSIS
        Takes a PSCredential object and validates it against the domain.

    .PARAMETER Credential
        A PScredential object with the username/password you wish to test.
        Typically this is generated using the Get-Credential cmdlet

    .OUTPUTS
        A boolean, indicating whether the credentials were successfully validated.

    #>
    param(
        [System.Management.Automation.CredentialAttribute()] $Credential
    )
    $isValid = $false

    If (!$PSBoundParameters.ContainsKey('Credential')) {
        $psCred = (Get-Credential)
    } Else {
        $psCred = $Credential
    }
    If ($psCred -eq $null) {
        throw 'No valid credentials entered.'
    }

    $username = $psCred.username
    $password = $psCred.GetNetworkCredential().password

    # Get current domain using logged-on user's credentials
    $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
    $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

    If ($domain.name -ne $null){
        $isValid = $true
    }

    return $isValid
}

New-Alias -Name vcreds -Value Test-Credential
Export-ModuleMember -Function Test-Credential
Export-ModuleMember -Alias vcreds