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
	 Context 'Test-IfIPv4' {
        It 'Should support pipeline' {
            "127.0.0.1" | Test-IfIPv4 | Should be $true
        }

        It 'Should NOT recognize IPv6' {
            Test-IfIPv4 -Address '2001:0db8:85a3:0000:0000:8a2e:0370:7334' | Should be $false
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"