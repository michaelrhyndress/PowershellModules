#region Pester Module
ipmo (`
    Get-Item (`
        [System.IO.Path]::GetFullPath((`
            Join-Path $PSScriptRoot '../../Vendor/Pester')`
        )`
    )`
)
#endregion Pester Module

#region Pester Module
ipmo (`
    Get-Item (`
        [System.IO.Path]::GetFullPath((`
            Join-Path $PSScriptRoot '../Compare-HashTable')`
        )`
    )`
)
#endregion Pester Module

#region Import Test Module
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.tests\.ps1', '.psm1'
ipmo "$here\$sut" -Force
#endregion Import Test Module

Describe 'Function Tests' {

    $Set1 = @(1,2,3,4,5)
    $Set2 = @(1,2,3,4,5,6,7,8,9,10)
    $Set3 = @(0,1,3,4,5,11,12,13) #for Difference testing


    $Solution = @{
        Union = @(1,2,3,4,5,6,7,8,9,10)
        Intersection = @(1,2,3,4,5)
        Difference = @()
        SymmetricDifference = @(6,7,8,9,10)
        IsSubset = $true
        IsSuperset = $false
    }

    Context 'Compare-Set' {
        It 'Should Compare-Set' {
            $Answer = Compare-Set -All $Set1 $Set2
            chash $Answer $Solution | Should BeNullOrEmpty
        }
    }

    Context 'Get-Union' {
        It 'Should Get Union' {
            Get-Union $Set1 $Set2 | Should Be $Solution.Union
        }
    }

    Context 'Get-Intersection' {
        It 'Should Get Intersection' {
            Get-Intersection $Set1 $Set2 | Should BeExactly $Solution.Intersection
        }
    }

    Context 'Get-Difference' {
        It 'Should Get Difference' {
            Get-Difference $Set1 $Set3 | Should BeExactly @(2)
        }
    }

    Context 'Get-SymmetricDifference' {
        It 'Should Get Symmetric Difference' {
            Get-SymmetricDifference $Set1 $Set3 | Should BeExactly @(0,2,11,12,13)
        }
    }

    Context 'Test-ifSubset' {
        It 'Should be a subset' {
            Test-IfSubset $Set1 $Set2 | Should BeExactly $Solution.IsSubset
        }
        It 'Should not be a subset' {
            Test-IfSubset $Set2 $Set1 | Should Not Be $Solution.IsSubset
        }
    }

    Context 'Test-ifSuperset' {
        It 'Should be a superset' {
            Test-IfSuperset $Set2 $Set1 | Should BeExactly $true
        }
        It 'Should not be a superset' {
            Test-IfSuperset $Set1 $Set2 | Should Not Be $true
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"