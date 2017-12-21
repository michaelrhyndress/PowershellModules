@{

# Script module or binary module file associated with this manifest.
RootModule = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '8ab65cb3-516f-45c8-88c1-d0840f9122ca'

# Author of this module
Author = 'Michael Rhyndress'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = ''

# Description of the functionality provided by this module
Description = 'Determine if a specific user has access to a path'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

FunctionsToExport = '*'

NestedModules = @(
    'Public/Get-AllUsersWithAccess.psm1',
    'Public/Test-IfIHaveAccess.psm1',
    'Public/Test-IfUserHasAccess.psm1',
    'Public/Test-IfUserHasNTFSAccess.psm1',
    'Public/Test-IfUserHasShareAccess.psm1'
)

FileList = @(
    'Private/Compare-GroupListsRecursive.psm1',
    'Private/ConvertTo-DistinguishedNameFromIdentityReference.psm1',
    'Private/Get-GroupListsRecursive.psm1',
    'Private/Get-GroupMembers.psm1',
    'Public/Get-AllUsersWithAccess.psm1',
    'Public/Test-IfIHaveAccess.psm1',
    'Public/Test-IfUserHasAccess.psm1',
    'Public/Test-IfUserHasNTFSAccess.psm1',
    'Public/Test-IfUserHasShareAccess.psm1'
)

PrivateData = @{}

}