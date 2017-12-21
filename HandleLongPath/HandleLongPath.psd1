@{

# Script module or binary module file associated with this manifest.
# RootModule = 'HandleLongPath.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '42dc683d-0e9e-4f07-adf2-20fb67fefdbd'

# Author of this module
Author = 'Michael Rhyndress'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = ''

# Description of the functionality provided by this module
#Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Functions to export from this module
FunctionsToExport = @(
    'Get-LongPathACL'
    'Get-LongPathChildItem'
    'Get-LongPathItem'
)

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    'Public/Get-LongPathACL'
    'Public/Get-LongPathChildItem'
    'Public/Get-LongPathItem'
)

FileList = @(
    'Public/Get-LongPathACL.psm1'
    'Public/Get-LongPathChildItem.psm1'
    'Public/Get-LongPathItem.psm1'
)

PrivateData = @{}

}

