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


Describe "Compress-Array" {
  Context "Function" {
    It "Should Compress Jagged Array" {
        (@(1, @(2, 3), $null, @(@(4), 5), 6) | Compress-Array) | Should BeExactly 1,2,3,4,5,6
    }
  } 
}

Remove-Module -name "$($sut -replace '.psm1', '')"