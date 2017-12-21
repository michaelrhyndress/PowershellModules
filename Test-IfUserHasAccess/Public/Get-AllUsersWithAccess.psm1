@('../Private/ConvertTo-DistinguishedNameFromIdentityReference.psm1',
  '../Private/Get-GroupListsRecursive.psm1',
  '../Private/Get-GroupMembers.psm1',
  '../../Compare-Set',
  '../PowerShellAccessControl') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Get-AllUsersWithAccess {
<#
    .SYNOPSIS
    Return a list of all users who have access to a share

    .DESCRIPTION
    Return a list of all users who have access to a share via share permissions

    .EXAMPLE
    Get-AllUsersWithAccess -SharePath '\\server\share'
#>
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
        $SharePath,
        [switch] $Count
    )

    Try {
        Test-Path $SharePath | Out-Null
    } Catch {
        throw $_
    }

    $Attempts = 5
    $err = $null

    :getSD While ($Attempts -ge 0) {
        Try {
            $SD = (Get-SecurityDescriptor $SharePath -ObjectType LMShare)
        } Catch {
            $err = $_
        }

        If ($SD) {
            break :getSD
        }

        $Attempts--
    }

    If (!$SD) {
        throw $err
    }

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

    #Get recursive ALLOW group members
    If ($AllowList.Count -gt 0) {
        Write-Verbose 'Recursive ALLOW list'
        foreach ($grp in $AllowList.Clone()) {
            If ($grp -ne $null) {
                (Get-GroupListsRecursive -DistinguishedName $grp) | %{ [void] $AllowList.Add($_) }
            }
        }
    }

    #Get recursive DENY group members
    If ($DenyList.Count -gt 0) {
        Write-Verbose 'Recursive DENY list'
        foreach ($grp in $DenyList.Clone()) {
            If ($grp -ne $null) {
                (Get-GroupListsRecursive -DistinguishedName $grp) | %{ [void] $DenyList.Add($_) }
            }
        }
    }

    #remove DENY groups from ALLOW list
    Write-Verbose 'Removing Deny groups from Allow group list'
    $AllowList = (Get-Difference -ReferenceList $AllowList -DifferenceList $DenyList) | sort -Unique

    #Get all users of allow groups
    Write-Verbose 'Get users from all Allow groups'
    $Users = ($AllowList | %{ Get-GroupMembers -DistinguishedName $_ -Users })
    $Users = ($Users | sort -Unique)

    If ($Count) {
        $Users = $Users.Count
    }

    return $Users
}

Export-ModuleMember -Function Get-AllUsersWithAccess