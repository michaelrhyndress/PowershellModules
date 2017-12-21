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
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
ipmo "$here\$sut" -Force
#endregion Import Test Module

#Word Processing
$TestFile__doc = Get-item (Join-Path $PSScriptRoot 'test-scenario/LegacyWord.doc')
$TestFile__docx = Get-item (Join-Path $PSScriptRoot 'test-scenario/Word.docx')
$TestFile__docm = Get-item (Join-Path $PSScriptRoot 'test-scenario/MacroWord.docm')

# Spreadsheet 
$TestFile__xls = Get-item (Join-Path $PSScriptRoot 'test-scenario/LegacySpreadsheet.xls')
$TestFile__xlsx = Get-item (Join-Path $PSScriptRoot 'test-scenario/Spreadsheet.xlsx')
$TestFile__xlsm = Get-item (Join-Path $PSScriptRoot 'test-scenario/MacroSpreadsheet.xlsm')
$TestFile__xlsb = Get-item (Join-Path $PSScriptRoot 'test-scenario/BinarySpreadsheet.xlsb')

#Presentation
$TestFile__ppt = Get-item (Join-Path $PSScriptRoot 'test-scenario/LegacyPresentation.ppt')
$TestFile__pptx = Get-item (Join-Path $PSScriptRoot 'test-scenario/Presentation.pptx')
$TestFile__pptm = Get-item (Join-Path $PSScriptRoot 'test-scenario/MacroPresentation.pptm')

#Text file
$TestFile__txt = Get-item (Join-Path $PSScriptRoot 'test-scenario/Text.txt')


Describe 'Tests' {
    Context "Word Processing documents" {
        It "doc documents" {
            ($TestFile__doc | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "docx documents" {
            ($TestFile__docx | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "docm documents" {
            ($TestFile__docm | Get-CustomProperties).HasCustomProperties | Should be $true
        }
    }

    Context "Spreadsheet documents" {
        It "xls documents" {
            ($TestFile__xls | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "xlsx documents" {
            ($TestFile__xlsx | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "xlsm documents" {
            ($TestFile__xlsm | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "xlsb documents" {
            ($TestFile__xlsb | Get-CustomProperties).HasCustomProperties | Should be $true
        }
    }

    Context "Presentation documents" {
        It "ppt documents" {
            ($TestFile__ppt | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "pptx documents" {
            ($TestFile__pptx | Get-CustomProperties).HasCustomProperties | Should be $true
        }

        It "pptm documents" {
            ($TestFile__pptm | Get-CustomProperties).HasCustomProperties | Should be $true
        }
    }

    Context "Test not supported" {
        It "Text documents are OLE objects, but have no custom props (other than job runspace)" {
            ($TestFile__txt | Get-CustomProperties).HasCustomProperties | Should be $false
        }
    }
}

Remove-Module -name "$($sut -replace '.psm1', '')"