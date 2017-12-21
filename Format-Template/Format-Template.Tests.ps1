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
	 Context 'Format-Template' {
        $Required = @('FirstName', 'LastName', 'DateTime')
        $TokenList = @{
            FirstName = 'Michael'
            LastName = 'Rhyndress'
            DateTime = "{0:D}" -f (Get-Date)
        }
        $Tmpl = "#FirstName# #LastName# #DateTime#"
        $Template = Format-Template -Template $Tmpl -Tokens $TokenList

        It 'Should format template to have all values' {
            foreach ($word in $TokenList.Values) {
                $Template -match $word | Should be $true
            }
        }
        
        It 'Should NOT have unfilled required keys' {
            foreach ($key in $required) {
                $Template -match "#{0}#" -f $key | Should be $false
            }
        }

        It 'Should support pipeline' {
            $Tmpl | Format-Template -Tokens $TokenList | Should be $true
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"