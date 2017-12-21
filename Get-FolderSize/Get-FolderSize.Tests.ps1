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

$TestFolder = Get-item (Join-Path $PSScriptRoot 'test-scenario')

Describe 'Tests' {
    Context 'Get-FolderSize' {
        It 'Should support pipeline' {
            $TestFolder | Get-FolderSize | Should be 1048576
        }

        It 'Should support string path' {
            $TestFolder.FullName | Get-FolderSize | Should be 1048576
        }

        It 'Should support recursion' {
            $TestFolder.FullName | Get-FolderSize -Recurse | Should be 2097152
        }

        It 'Should convert to kb' {
            Get-FolderSize -Path $TestFolder -Format 'kb' | Should be (1048576/1kb)
        }

        It 'Should convert to mb' {
            Get-FolderSize -Path $TestFolder -Recurse -Format 'mb' | Should be (2097152/1mb)
        }

        It 'Should convert to gb' {
            Get-FolderSize -Path $TestFolder -Format 'gb' | Should be (1048576/1gb)
        }

        It 'Should convert to tb' {
            Get-FolderSize -Path $TestFolder -Format 'tb' | Should be (1048576/1tb)
        }
    }


    Context 'Get-FolderSizeCom' {
        It 'Should support pipeline' {
            $TestFolder | Get-FolderSizeCom | Should be 2097152
        }

        It 'Should support string path' {
            $TestFolder.FullName | Get-FolderSizeCom | Should be 2097152
        }

        It 'Should convert units' {
            Get-FolderSizeCom -Path $TestFolder -Format 'mb' | Should be 2.0
        }

        It 'Should convert to kb' {
            Get-FolderSizeCom -Path $TestFolder -Format 'kb' | Should be (2097152/1kb)
        }

        It 'Should convert to mb' {
            Get-FolderSizeCom -Path $TestFolder -Format 'mb' | Should be (2097152/1mb)
        }

        It 'Should convert to gb' {
            Get-FolderSizeCom -Path $TestFolder -Format 'gb' | Should be (2097152/1gb)
        }

        It 'Should convert to tb' {
            Get-FolderSizeCom -Path $TestFolder -Format 'tb' | Should be (2097152/1tb)
        }
    }

}

Remove-Module -name "$($sut -replace '.psm1', '')"