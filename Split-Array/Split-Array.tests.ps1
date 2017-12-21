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


Describe "Split-Array" {
  Context "Function" {
    It "Should Split array into sections" {
       Split-Array -List @(1..11) -SplitSize 3 | Should BeExactly @(1,2,3),@(4,5,6),@(7,8,9),@(10,11)
    }
  } 
}

Remove-Module -name "$($sut -replace '.psm1', '')"