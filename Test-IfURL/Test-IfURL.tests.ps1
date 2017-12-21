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
	 Context 'Test-IfURL' {
        It 'Should support pipeline' {
            "https://www.website.com" | Test-IfURL | Should be $true
        }

        It 'Should return Match' {
            Test-IfURL -Address 'The URL is: https:\\www.website.com' -GetMatch | Should BeExactly 'https:\\www.website.com'
        }

        It 'Should return Match when there is a path' {
            Test-IfURL -Address 'The URL is: https:\\www.website.com\Path-to-here' -GetMatch | Should BeExactly 'https:\\www.website.com\Path-to-here'
        }

        It 'Should return EXACT' {
            Test-IfURL -Address 'https:\\www.website.com' -Exact | Should Be $true
        }

        It 'Should return EXACT Match when there is a path with spaces' {
            Test-IfURL -Address 'www.website.com\Path to here' -GetMatch -Exact | Should BeExactly 'www.website.com\Path to here'
        }

        It 'Should fail if not Exact' {
            Test-IfURL -Address 'The URL is: https:\\www.website.com\home' -Exact | Should Be $false
        }

        It 'Should NOT recognize non urls' {
            Test-IfURL -Address 'This text is not a url' | Should be $false
        }

        It 'Should get protocol' {
            Test-IfURL -Address 'ftp:\\thisfile' -GetProtocol | Should BeExactly 'ftp'
        }

        It 'Should NOT return if no protocol' {
            Test-IfURL -Address 'www.website.com' -GetProtocol | Should BeNullOrEmpty
        }


        It 'Should get NoProtocol regex' {
            Test-IfURL -Address 'http:\\www.google.com' -NoProtocol -GetRegex | Should BeExactly '[-A-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}(\\([-A-z0-9@:%_\+.~#?&//=]*))?'
        }
        It 'Should get EXACT NoProtocol regex' {
            Test-IfURL -Address 'http:\\www.google.com' -NoProtocol -GetRegex -Exact | Should BeExactly '^[-A-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}(\\([-A-z0-9@:%_\+.~#?&//= ]*))?$'
        }
        It 'Should get Protocol regex' {
            Test-IfURL -Address 'http:\\www.google.com' -GetRegex | Should BeExactly '([A-z]*:\\\\)??[-A-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}(\\([-A-z0-9@:%_\+.~#?&//=]*))?'
        }
        It 'Should get EXACT Protocol regex' {
            Test-IfURL -Address 'http:\\www.google.com' -GetRegex -Exact | Should BeExactly '^([A-z]*:\\\\)??[-A-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}(\\([-A-z0-9@:%_\+.~#?&//= ]*))?$'
        }
        It 'Should get protocol regex' {
            Test-IfURL -Address 'ftp:\\thisfile' -GetProtocol -GetRegex | Should BeExactly '^[\w]*(?=:\\\\)'
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"