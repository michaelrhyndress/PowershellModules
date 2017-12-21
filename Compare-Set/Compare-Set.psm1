Function Compare-Set {
<#
    .SYNOPSIS
    Compares two sets

    .DESCRIPTION
    Returns a hash of set comparisons.
    Including, Union, Intersection, Difference, SymmertricDifference, Is Subset, Is Superset

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .PARAMETER Union
    Combines both sets into a single, unique set

    .PARAMETER Intersection
    Calculates and returns the items that are present in both sets

    .PARAMETER Difference
    Calculates and returns the items in set 1 that are not in set 2

    .PARAMETER SymmetricDifference
    Calculates and returns the items exclusive to each set

    .PARAMETER IsSubset
    Tests if set 1 is a subset of set 2

    .PARAMETER IsSuperset
    Tests if set 1 is a superset of set 2

    .PARAMETER All
    Calculates and returns all set comparisons

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Compare-Set -ReferenceList $set1 -DifferenceList $set2 -All
#>

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')] 
        $ReferenceList,

        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList,

        [switch] $Union,
        [switch] $Intersection,
        [switch] $Difference,
        [switch] $SymmetricDifference,
        [switch] $IsSubset,
        [switch] $IsSuperset,
        [switch] $All
    )

    If (!$Union -and !$Intersection -and !$Difference -and !$SymmetricDifference -and !$IsSubset -and !$IsSuperset){
        $All = $true
    }
    
    $out = @{}

    #All unique in both
    If ($Union -or $All) {
        $out.Union = Get-Union $ReferenceList $DifferenceList
    }

    #All in both ReferenceList and DifferenceList
    If ($Intersection -or $All) {
        $out.Intersection = Get-Intersection $ReferenceList $DifferenceList
    }

    If ($Difference -or $All) {
        $out.Difference = Get-Difference $ReferenceList $DifferenceList
    }

    If ($SymmetricDifference -or $All) {
        $out.SymmetricDifference = Get-SymmetricDifference $ReferenceList $DifferenceList
    }

    If ($IsSubset -or $All) {
        $out.IsSubset = Test-IfSubset $ReferenceList $DifferenceList
    }

    If ($IsSuperset -or $All) {
        $out.IsSuperset = Test-IfSuperset $ReferenceList $DifferenceList
    }

    return $out
}


Function Get-Union {
<#
    .SYNOPSIS
    Combines both sets into a single, unique set

    .DESCRIPTION
    Calculate the Union of the two sets. Unions represent all unique items in both sets.

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Get-Union -ReferenceList $set1 -DifferenceList $set2

    Returns @(1,2,3,4,5,6,7,8)
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )
    return ($ReferenceList + $DifferenceList) | sort -Unique
}

Function Get-Intersection {
<#
    .SYNOPSIS
    Gets items that are present in both sets.

    .DESCRIPTION
    Calculate the Intersetction of the two sets. Intersection represents items present in both sets.

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Get-Intersection -ReferenceList $set1 -DifferenceList $set2

    Returns @(4,5)
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )
    return $ReferenceList | ?{$DifferenceList -contains $_} | sort -Unique
}

Function Get-Difference {
<#
    .SYNOPSIS
    Gets the items in set 1 that are not in set 2

    .DESCRIPTION
    Calculate the Difference of the two sets.
    Difference represents items present in set1, and are not in set 2.

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Get-Difference -ReferenceList $set1 -DifferenceList $set2

    Returns @(1,2,3)
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )

    return $ReferenceList | ?{ $DifferenceList -notcontains $_ } | sort -Unique
}

Function Get-SymmetricDifference {
<#
    .SYNOPSIS
    Gets the items in set 1 that are not in set 2, and the items in set 2 that are not in set 1

    .DESCRIPTION
    Calculate the Symmetric Difference of the two sets.
    Symmetric Difference represents the items in set 1 that are not in set 2,
    and the items in set 2 that are not in set 1.

    Essentially this creates a set of Differences calculated both ways.

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Get-SymmetricDifference -ReferenceList $set1 -DifferenceList $set2

    Returns @(1,2,3,6,7,8)
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )
    $Union = (Get-Union -ReferenceList $ReferenceList -DifferenceList $DifferenceList)
    $Intersect = (Get-Intersection -ReferenceList $ReferenceList -DifferenceList $DifferenceList)
    
    return $Union | ?{ $Intersect -notcontains $_ } | sort -Unique
}

Function Test-IfSubset {
<#
    .SYNOPSIS
    Check if set1 is a subset of set2

    .DESCRIPTION
    Check if set1 is a subset of set2
    A Subset is a set that wholly fits in the other set.

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(4,5,6,7,8)
    Test-IfSubset -ReferenceList $set1 -DifferenceList $set2

    Returns $false


    .EXAMPLE
    $set1 = @(1,2,3,4,5)
    $set2 = @(1,2,3,4,5,6,7,8)
    Test-IfSubset -ReferenceList $set1 -DifferenceList $set2

    Returns $true
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )

    return ($ReferenceList | ?{$DifferenceList -contains $_}).Count -eq $ReferenceList.Count
}

Function Test-IfSuperset {
<#
    .SYNOPSIS
    Check if set1 is a superset of set2

    .DESCRIPTION
    Check if set1 is a superset of set2
    A superset is a set that contains the other set.

    Essentially, this checks if set2 is a subset of set1

    .PARAMETER ReferenceList 
    First set, this is the primary set.

    .PARAMETER DifferenceList 
    Camparison set

    .EXAMPLE
    $set1 = @(1,2,3)
    $set2 = @(1,2,3,4)
    Test-IfSuperset -ReferenceList $set1 -DifferenceList $set2

    Returns $false


    .EXAMPLE
    $set1 = @(1,2,3,4,5,6,7,8)
    $set2 = @(1,2,3,4,5)
    Test-IfSuperset -ReferenceList $set1 -DifferenceList $set2

    Returns $true
#>
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias('ref', 'RL')]
        $ReferenceList,
        [Parameter(Mandatory=$true, Position=1)]
        [Alias('diff', 'DL')]
        $DifferenceList
    )

    return ($DifferenceList | ?{$ReferenceList -contains $_}).Count -eq $DifferenceList.Count
}

New-Alias -Name cset -Value Compare-Set
Export-ModuleMember -Function Compare-Set
Export-ModuleMember -Alias cset

New-Alias -Name issub -Value Test-IfSubset
Export-ModuleMember -Function Test-IfSubset
Export-ModuleMember -Alias issub

New-Alias -Name issup -Value Test-IfSuperset
Export-ModuleMember -Function Test-IfSuperset
Export-ModuleMember -Alias issup

New-Alias -Name intersection -Value Get-Intersection
Export-ModuleMember -Function Get-Intersection
Export-ModuleMember -Alias intersection

New-Alias -Name union -Value Get-Union
Export-ModuleMember -Function Get-Union
Export-ModuleMember -Alias union

New-Alias -Name listdiff -Value Get-Difference
Export-ModuleMember -Function Get-Difference
Export-ModuleMember -Alias listdiff

New-Alias -Name symmdiff -Value Get-SymmetricDifference
Export-ModuleMember -Function Get-SymmetricDifference
Export-ModuleMember -Alias symmdiff