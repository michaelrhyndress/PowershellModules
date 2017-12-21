@('../../../Vendor/PowerShellAccessControl',
  '../Private/ConvertTo-DistinguishedNameFromIdentityReference.psm1',
  '../Private/Compare-GroupListsRecursive.psm1') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Test-IfUserHasShareAccess {
<#
    .SYNOPSIS
    Determine if a user has access to a share via Security Descriptors

    .DESCRIPTION
    Matches a users associated groups with a group allowed into a share via security descriptors.

    .EXAMPLE
    Test-IfUserHasShareAccess -Identity 'UA12345'  -SharePath '\\server\share'
#>
    Param(
        [Parameter(Mandatory=$True)]
        $Identity,
        [Parameter(Mandatory=$True)]
        $SharePath
    )

    #region Resolve Identity to AD Object
    Try {
        $ResolvedID = (Get-ADObject -Filter {SamAccountName -eq $Identity} -Properties memberof)
        If ($ResolvedID -eq $null) {
            throw "Could not resolve Identity $Identity" 
        }
    } Catch {
        throw $_
    }
    #endregion Resolve Identity to AD Object

    Try {
        $SD = (Get-SecurityDescriptor $Sharepath -ObjectType LMShare)
    } Catch {
        throw $_
    }

    #region Add self to member list, incase of explicit access
    [void] $ResolvedID.memberof.Add($ResolvedID.DistinguishedName) # +self
    [void] $ResolvedID.memberof.Add('Everyone') # Everyone is a member of everyone
    #endregion Add self to member list, incase of explicit access

    $AllowList = New-Object System.Collections.ArrayList($null)
    $DenyList = New-Object System.Collections.ArrayList($null)

    #Check allows
    ($SD.Access | ?{$_.AceType -eq 'AccessAllowed'}) | sort -Property {$_.Principal} -Unique | %{
        [void] $AllowList.Add((ConvertTo-DistinguishedNameFromIdentityReference -IdentityReference $_.Principal))
    }

    #Check Denies
    ($SD.Access  | ?{$_.AceType -eq 'AccessDenied'}) | sort -Property {$_.Principal} -Unique | %{
        [void] $DenyList.Add((ConvertTo-DistinguishedNameFromIdentityReference -IdentityReference $_.Principal))
    }

    #Check top level Denies (quicker to start with this)
    $DeniedAccess = (Compare-GroupListsRecursive -UsersGroups $ResolvedID.memberof -FoldersGroups $DenyList)

    #Check top level allows
    If (!$DeniedAccess) {
        Write-Verbose "Not Denied explicitly, checking if access granted."
        $AllowedAccess = (Compare-GroupListsRecursive -UsersGroups $ResolvedID.memberof -FoldersGroups $AllowList)
    } Else {
        Write-Verbose "Access Denied."
    }

    If ((!$DeniedAccess) -and $AllowedAccess){
        return $true
    } Else {
        Write-Verbose 'User does not have access.'
    }

    return $false
}

Export-ModuleMember -Function Test-IfUserHasShareAccess