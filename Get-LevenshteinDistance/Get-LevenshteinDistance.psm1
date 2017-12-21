Function Get-LevenshteinDistance {
<#
    .SYNOPSIS
    Find the approximate similarity between two strings by finding the # of edits to transform a string into the other.

    .DESCRIPTION
    The Levenshtein Distance is a common metric/algorithm for measuring the similarity of two strings.
    The distance between two strings is the # of edits needed to get from one string to the other.

    .PARAMETER Reference 
    Primary String, output will be based on converting this string to the Difference string.

    .PARAMETER Difference 
    Secondary String

    .EXAMPLE
    Get-LevenshteinDistance -Reference 'Hey' -Difference 'Heyy' -eq 1

    .EXAMPLE
    Get-LevenshteinDistance -Reference 'Equal' -Difference 'Equal' -eq 0
#>

    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String] $Reference,
        [Parameter(Mandatory=$true)]
        [String] $Difference
    )

    #Length of input strings and distance matrix
    $L1 = $Reference.Length
    $L2 = $Difference.Length
    $D = New-Object 'int[,]' $($L1+1),$($L2+1)

    If ($L1 -eq 0){
      return $L2
    }
    if ($L2 -eq 0){
        return $L1
    }

    for ([int]$i = 0; $i -le $L1; $i++){
        $D[$i, 0] = $i
    }
    for ([int]$j = 0; $j -le $L2; $j++){
        $D[0, $j] = $j
    }

    for ([int]$i = 1; $i -le $L1; $i++){
        for ([int]$j = 1; $j -le $L2; $j++){
            if ($Difference[$($j - 1)] -eq $Reference[$($i - 1)]){
                $cost = 0
            }
            else{
                $cost = 1
            }
            $D[$i, $j] = [Math]::Min([Math]::Min($($D[$($i-1), $j] + 1), $($d[$i, $($j-1)] + 1)),$($D[$($i-1), $($j-1)]+$cost))
        }
    }
        
    return $D[$L1, $L2]
}


Function Find-ClosestMatchingString {
<#
    .SYNOPSIS
    Calculates the Levenshtein Distance of all List items to find closest match.

    .DESCRIPTION
    Use Levenshtein Distance algorithm on all List items to figure out which
    is the closest. The closest is defined by least cost to change Reference -> Matching.

    .PARAMETER List 
    List of strings to calculate Levenshtein Distance compared to Matching string.

    .PARAMETER Matching 
    String that is mutated into the list items to figure out lease cost.

    .EXAMPLE
    Find-ClosestMatchingString -List @("Hey World", "Hello Wrrd", "World", "Hello") -Matching 'Hello World'

    Returns "Hello Wrrd"
#>

    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String[]] $List,
        [Parameter(Mandatory=$true)]
        [String] $Matching
    )

    $Closest__str = $null
    $Closest__dist = [int]::MaxValue

    Foreach ($str in $List) {
        $str__dist = (Get-LevenshteinDistance -Reference $Matching -Difference $str)
        Write-Verbose  "$str diff $Matching = $str__dist"

        If ($str__dist -eq 0) { 
            return $str #exact match
        }

        If ($str__dist -lt $Closest__dist) { #less is closest
            $Closest__str = $str
            $Closest__dist = $str__dist
        }

    }

    return $Closest__str
}

New-Alias -Name Levenshtein -Value Get-LevenshteinDistance
Export-ModuleMember -Function Get-LevenshteinDistance
Export-ModuleMember -Alias Levenshtein

New-Alias -Name ClosestMatch -Value Find-ClosestMatchingString
Export-ModuleMember -Function Find-ClosestMatchingString
Export-ModuleMember -Alias ClosestMatch