@{

# Script module or binary module file associated with this manifest.
RootModule = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'd518a1a6-b520-40ca-ad25-1f21957a4192'

# Author of this module
Author = 'Michael Rhyndress'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = ''

# Description of the functionality provided by this module
Description = 'Converts AD groups to either Universal or Global Scope'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

FunctionsToExport = '*'

NestedModules = @(
    'Public/ConvertTo-GlobalScope.psm1',
    'Public/ConvertTo-UniversalScope.psm1'
)

FileList = @(
    'Public/ConvertTo-GlobalScope.psm1',
    'Public/ConvertTo-UniversalScope.psm1'
)

PrivateData = @{}

}