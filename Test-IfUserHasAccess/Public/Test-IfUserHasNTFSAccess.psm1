@('../Private/ConvertTo-DistinguishedNameFromIdentityReference.psm1',
  '../Private/Compare-GroupListsRecursive.psm1') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}


Function Test-IfUserHasNTFSAccess {
<#
    .SYNOPSIS
    Determine if a user has access to a path via ACLs

    .DESCRIPTION
    Matches a users associated groups with a group allowed via the Access Control List.

    .EXAMPLE
    Test-IfUserHasNTFSAccess -Identity 'UA12345'  -Path '\\server\share\path\to\folder'
#>

    Param(
        [Parameter(Mandatory=$True)]
        $Identity,
        [Parameter(Mandatory=$True)]
        $Path
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

    #region Get path
    Try {
        $Path = (gi -LiteralPath $Path -Force)
    } Catch {
        throw $_
    }
    #endregion Get path

    #region Get ACLs of Path
    Try {
        $Access = ($Path.GetAccessControl().Access)
    } Catch {
        throw $_
    }
    #endregion Get ACLs of Path

    #region Add self to member list, incase of explicit access
    [void] $ResolvedID.memberof.Add($ResolvedID.DistinguishedName) # +self
    [void] $ResolvedID.memberof.Add('Everyone') # Everyone is a member of everyone
    #endregion Add self to member list, incase of explicit access

    $AllowList = New-Object System.Collections.ArrayList($null)
    $DenyList = New-Object System.Collections.ArrayList($null)

    #Check allows
    ($Access | ?{$_.AccessControlType -eq 'Allow'}) | sort -Property {$_.IdentityReference} -Unique | %{
        [void] $AllowList.Add((ConvertTo-DistinguishedNameFromIdentityReference -IdentityReference $_.IdentityReference))
    }

    #Check Denies
    ($Access | ?{$_.AccessControlType -eq 'Deny'}) | sort -Property {$_.IdentityReference} -Unique | %{
        [void] $DenyList.Add((ConvertTo-DistinguishedNameFromIdentityReference -IdentityReference $_.IdentityReference))
    }

    #Check top level Denies (quicker to start with this)
    $DeniedAccess = (Compare-GroupListsRecursive -UsersGroups $ResolvedID.memberof -FoldersGroups $DenyList)

    #Check top level allows
    If (!$DeniedAccess) {
        $AllowedAccess = (Compare-GroupListsRecursive -UsersGroups $ResolvedID.memberof -FoldersGroups $AllowList)
    }

    If ((!$DeniedAccess) -and $AllowedAccess){
        return $true
    }

    return $false
}

Export-ModuleMember -Function Test-IfUserHasNTFSAccess