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
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.tests\.ps1', '.psd1'
ipmo "$here\$sut" -Force
#endregion Import Test Module

Describe 'Public Tests' {
    $LongPath = "C:\Testing\Global\Modules\HandleLongPath\Test\asdfasdgwrehwerhbfgjnedwtyrtesfsdg\Test\bxmOtVsLKkBnpweUGcRZFqNhMyWQPHoAf\HctgjzkJsQeiIKxbdwDpOmvFhSqonXNBfTMAPuU\dQCJLuYeayhBnwslUSjTkbHNigOf\fLEBpdxlFMbaTKHUoewhGgCqZQIiYAJRtVjyNOknvumcPzDsSWXr\XvHIhRugmkGzpBCewNdfLOExlQADSryYjiTVoPbJsqWU\FileNametha.txt"

    Context 'Get-LongPathACL' {
        It 'Should get long path ACL' {
            #File may not be in source control
            (Get-LongPathACL -Path $LongPath).Access.Count  | Should BeGreaterThan 0
        }

        It 'Should get short path ACL' {
            (Get-LongPathACL -Path "C:\").Access.Count  | Should BeGreaterThan 0
        }

        It 'Should throw on incorrect path' {
            {Get-LongPathACL -Path "C:\Path\that\does not exist"}  | Should Throw
        }
    }

    Context 'Get-LongPathItem' {
        It 'Should get item just like gci' {
            (Get-LongPathItem .\Test\).Count | Should BeExactly 1
        }

        It 'Should get long path items that GCI would miss' {
            (lpgi $LongPath).Count | Should BeGreaterThan (gi $LongPath -ErrorAction SilentlyContinue).Count
        }
    }

    Context 'Get-LongPathChildItem' {
        It 'Should get child item just like gci' {
            (Get-LongPathChildItem .\Test\).Count | Should BeExactly 2
        }

        It 'Should get long path items that GCI would miss' {
            (lpgci .\Test\ -recurse).Count | Should BeGreaterThan (gci .\Test\ -recurse -ErrorAction SilentlyContinue).Count
        }
    }
}

Remove-Module -name "$($sut -replace '.psd1', '')"