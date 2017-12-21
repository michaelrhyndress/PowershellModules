@('../../Compare-Set', './Get-GroupMembers.psm1') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Get-GroupListsRecursive {
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $DistinguishedName
    )
    [array] $Groups = @()
    $NextSet = $null
    Try {
        $NextSet = (Get-GroupMembers -DistinguishedName $DistinguishedName -Groups)
        $Groups += $NextSet
    } Catch {}

    foreach ($grp in $NextSet) {
        $grp | Write-Verbose
        $Groups += (Get-GroupListsRecursive -DistinguishedName $grp) #recurse
    }
    
    return ($Groups | sort -Unique)
}

Export-ModuleMember -Function Get-GroupListsRecursive