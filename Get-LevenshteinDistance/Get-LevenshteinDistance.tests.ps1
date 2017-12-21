#region Pester Module
ipmo (`
    Get-Item (`
        [System.IO.Path]::GetFullPath((`
            Join-Path $PSScriptRoot '../../Vendor/Pester')`
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
    Context "Get-LevenshteinDistance" {
        It "Should return 1 for Hey -eq Heyy" {
            'Hello World' | Get-LevenshteinDistance -Difference 'Helloo World' | Should be 1
        }

        It "Should return 0 for equal strings" {
            Get-LevenshteinDistance -Reference 'Hello World' -Difference 'Hello World' | Should be 0
        }

        It "Should return 0 for equal strings" {
            Get-LevenshteinDistance -Reference 'Hello World' -Difference 'Hello World' | Should be 0
        }
    }

    Context "Find-ClosestMatchingString" {
        It "Should find Exact value" {
            ,@("Hello", "World", "Hello World", "Hey World") | Find-ClosestMatchingString -Matching 'Hello World' | Should be "Hello World"
        }

        It "Should find closest match" {
            Find-ClosestMatchingString -List @("Hey World", "Hello Wrrd", "World", "Hello") -Matching 'Hello World' | Should be "Hello Wrrd"
        }

        It "Should support single string instead of list" {
            Find-ClosestMatchingString -List "Heyyyyyy World" -Matching 'Hello World' | Should be "Heyyyyyy World"
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"