@{

# Script module or binary module file associated with this manifest.
# RootModule = 'Convert-AccessMask.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '856c226a-c694-4458-ab41-c1384e26a625'

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
FunctionsToExport = '*'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    'Public/ConvertFrom-AccessMask',
    'Public/ConvertTo-AccessMask'
)

FileList = @(
    'Public/ConvertFrom-AccessMask.psm1',
    'Public/ConvertTo-AccessMask.psm1'
)

PrivateData = @{}

}

