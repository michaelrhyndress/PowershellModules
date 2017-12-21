Function Test-ADGroupMember {
<#
    .SYNOPSIS
    Tests if a user is a member of a group, recursivly

    .DESCRIPTION
    Tests if a user is a member of a group, recursivly

    .EXAMPLE
    Test-ADGroupMember -User 'SamAccountName' -Group 'Group-Name'
#>
    Param (
        $User,
        $Group
    )

    Trap {throw $_}

    If ($Group -eq 'Everyone') {
        return $true
    }
    
    $Group = $Group -replace "(?s)^.*\\",""
    If (
        Get-ADUser -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group).DistinguishedName)'" `
        -SearchBase $((Get-ADUser $User).DistinguishedName) `
    )
    {
        return $true
    }
    Else {
        return $false
    }
}

New-Alias -Name isMemberOf -Value Test-ADGroupMember
Export-ModuleMember -Function Test-ADGroupMember
Export-ModuleMember -Alias isMemberOf