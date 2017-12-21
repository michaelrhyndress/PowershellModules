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
     Context 'Test-IfEmailAddress' {
        It 'Should support pipeline' {
            "mrhyndress@email.com" | Test-IfEmailAddress | Should be $true
        }
        
        It 'Should NOT recognize invalid Email Addresses' {
            Test-IfEmailAddress -Identity 'MyAddress@email' | Should be $false
        }

        It 'Should recognize Email Address in Parenthesis' {
            Test-IfEmailAddress -Identity '(mrhyndress@email.com)' -GetMatch | Should BeExactly 'mrhyndress@email.com'
        }

        It 'Should recognize an Email Address in a string' {
            Test-IfEmailAddress -Identity 'My Email Address Is mrhyndress@email.com if you have any questions.' -GetMatch | Should BeExactly 'mrhyndress@email.com'
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"