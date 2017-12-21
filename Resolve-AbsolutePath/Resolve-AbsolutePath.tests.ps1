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

Describe 'Tests' {
    Context 'Get-AbsolutePath' {
        It 'Should convert relative to absolute path' {
            Get-AbsolutePath './' | Should Be 'C:\Tests\Global\Modules\Resolve-AbsolutePath\'
        }

        It 'Should not change already absolute path' {
            Get-AbsolutePath 'C:\Windows' | Should BeExactly 'C:\Windows'
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"