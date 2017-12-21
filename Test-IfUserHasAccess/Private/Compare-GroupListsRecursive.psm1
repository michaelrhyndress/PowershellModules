@('../../Compare-Set', './Get-GroupMembers.psm1') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Compare-GroupListsRecursive {
    Param (
        $UsersGroups,
        $FoldersGroups
    )

    $MATCHFOUND = $false

    Try {
        $MatchResults = (Get-Intersection $UsersGroups -DifferenceList $FoldersGroups) #match Result
        $MATCHFOUND = ($MatchResults.Count -gt 0)
    } Catch {
        Write-Error $_
    }

    If ($MATCHFOUND -eq $false) {

        :enumerateGroups foreach ($grp in $FoldersGroups) {
            If ($MATCHFOUND) {
                break :enumerateGroups
            }

            Write-Verbose "Checking $grp"

            $NextSet = $null
            Try {
                $NextSet = (Get-GroupMembers -DistinguishedName $grp)
            } Catch {}

            If (($NextSet.Count -gt 0) -and ($MATCHFOUND -eq $false)) {
                $NextSet | Write-Verbose
                $MATCHFOUND = (Compare-GroupListsRecursive -UsersGroups $UsersGroups -FoldersGroups $NextSet) #recurse
            }
        }

    }
    
    If ($MATCHFOUND) {
        Write-Verbose "Match Found."
        $MatchResults | Write-Verbose
        return $true
    }

    return $false
}

Export-ModuleMember -Function Compare-GroupListsRecursive