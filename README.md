# PowershellModules

Module      : Compare-HashTable
Version     : 1.0
Description : Computes differences between two Hashtables. Results are returned as an array of objects
Functions   : {Compare-Hashtable}
aliases     : {chash}
Author      : Michael Rhyndress
HasTest     : True

Module      : Compare-Set
Version     : 1.0
Description : Computes the Union and Intersection of two arrays. Can also determine if they are sub or super sets of 
              eachother.
Functions   : {Compare-Set, Get-Intersection, Get-SymmetricDifference, Get-Union...}
aliases     : {cset, intersection, symmdiff, union...}
Author      : Michael Rhyndress
HasTest     : True

Module      : Compress-Array
Version     : 1.0
Description : Flatten jagged Array
Functions   : {Compress-Array}
aliases     : {splat}
Author      : Michael Rhyndress
HasTest     : True

Module      : Convert-AccessMask
Version     : 1.0
Description : Converts int32 AccessMask into string file system rights and vice-versa.
Functions   : {ConvertFrom-AccessMask, ConvertTo-AccessMask}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : False

Module      : Convert-GroupScope
Version     : 1.0
Description : Converts AD groups to either Universal or Global Scope.
Functions   : {ConvertTo-GlobalScope, ConvertTo-UniversalScope}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : False

Module      : Convert-PermStringToACE
Version     : 1.0
Description : Convert ACE object to string and convert back to an ACE-like object.
Functions   : {ConvertFrom-PermStringToACE, ConvertFrom-ACEToPermString}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : False

Module      : CredentialManager
Version     : 1.0
Description : Allows storing of credentials
Functions   : {Get-CredentialStore, Get-StoredCredential, Register-Credential, Unregister-Credential}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : False

Module      : Format-Template
Version     : 1.0
Description : Replaces tokens in raw string
Functions   : {Format-Template}
aliases     : {template}
Author      : Michael Rhyndress
HasTest     : True

Module      : Get-ADPrincipalGroupMembershipRecursive
Version     : 1.0
Description : Recursively gets principal group membership
Functions   : {Get-ADPrincipalGroupMembershipRecursive}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : False

Module      : Get-CustomProperties
Version     : 1.0
Description : Get Custom Properties that are set on files
Functions   : {Get-CustomProperties}
aliases     : {customprops}
Author      : Michael Rhyndress
HasTest     : True

Module      : Get-FolderSize
Version     : 1.0
Description : Calculates the size of a folder structure
Functions   : {Get-FolderSize, Get-FolderSizeCom}
aliases     : {gfs, gfsc}
Author      : Michael Rhyndress
HasTest     : True

Module      : Get-LevenshteinDistance
Version     : 1.0
Description : Find the approximate similarity between two strings by finding the # of edits to transform a string into 
              the other.
Functions   : {Get-LevenshteinDistance, Find-ClosestMatchingString}
aliases     : {Levenshtein, ClosestMatch}
Author      : Michael Rhyndress
HasTest     : True

Module      : Get-OutlookInbox
Version     : 1.0
Description : Returns emails from a mailbox
Functions   : {Get-OutlookInbox, Get-OutlookInboxEWS}
aliases     : {inbox, inboxEWS}
Author      : Michael Rhyndress
HasTest     : False

Module      : HandleLongPath
Version     : 1.0
Description : Generic functions with long path support
Functions   : {Get-LongPathACL, Get-LongPathChildItem, Get-LongPathItem}
aliases     : {lpACL, lpGCI, lpGI}
Author      : Michael Rhyndress
HasTest     : False

Module      : Invoke-ElevatedCommand
Version     : 1.0
Description : Runs a scriptblock as Administrator or other user
Functions   : {Invoke-ElevatedCommand}
aliases     : {su}
Author      : Michael Rhyndress
HasTest     : False

Module      : New-Share
Version     : 1.0
Description : Manages creation and removal of shared folders
Functions   : {New-Share, Remove-Share }
aliases     : {mkshare, rmshare}
Author      : Michael Rhyndress
HasTest     : False

Module      : Protect-String
Version     : 1.0
Description : Allows encrypting, decrypting, and hashing of strings
Functions   : {Get-AESKey, Protect-String, Unprotect-String, ConvertTo-Hash}
aliases     : {ekey, encrypt, decrypt, hstring}
Author      : Michael Rhyndress
HasTest     : True

Module      : Resolve-AbsolutePath
Version     : 1.0
Description : Resolves the abaolute path from a relative path
Functions   : {Resolve-AbsolutePath}
aliases     : {absolute}
Author      : Michael Rhyndress
HasTest     : True

Module      : Search-WhoIs
Version     : 1.0
Description : REST call to whois.arin to resolve information about ip
Functions   : {Search-WhoIs}
aliases     : {whois}
Author      : Michael Rhyndress
HasTest     : False

Module      : Split-Array
Version     : 1.0
Description : Splits array into chunks
Functions   : {Split-Array}
aliases     : {chunk}
Author      : Michael Rhyndress
HasTest     : True

Module      : Test-ADGroupMember
Version     : 1.0
Description : Checks if a user is a member of a group
Functions   : {Test-ADGroupMember}
aliases     : {isMemberOf}
Author      : Michael Rhyndress
HasTest     : False

Module      : Test-Credential
Version     : 1.0
Description : Takes a PSCredential object and validates it against the domain.
Functions   : {Test-Credential}
aliases     : {vcreds}
Author      : Michael Rhyndress
HasTest     : False

Module      : Test-IfEmailAddress
Version     : 1.0
Description : Test if string is a valid Email Address, can return boolean, matching address, or regex for UID
Functions   : {Test-IfEmailAddress}
aliases     : {isEmailAddress}
Author      : Michael Rhyndress
HasTest     : True

Module      : Test-IfFileLocked
Version     : 1.0
Description : Tests if a file is locked
Functions   : {Test-IfFileLocked}
aliases     : {islocked}
Author      : Michael Rhyndress
HasTest     : False

Module      : Test-IfIPv4
Version     : 1.0
Description : Test if string has IPv4, can return boolean, matching ip, or regex for IPv4
Functions   : {Test-IfIPv4}
aliases     : {isIPv4}
Author      : Michael Rhyndress
HasTest     : True

Module      : Test-IfURL
Version     : 1.0
Description : Test if string has URL, can return boolean, matching URL in string (URL cannot have spaces), matching 
              url EXACTLY (with spaces), URL without Protocol, matching Protocol, or regex for each
Functions   : {Test-IfURL}
aliases     : {isURL}
Author      : Michael Rhyndress
HasTest     : True

Module      : Test-IfUserHasAccess
Version     : 1.0
Description : Test if user can access a specific folder or file based on share and/or NTFS permissions.
Functions   : {Get-AllUsersWithAccess, Test-IfIHaveAccess, Test-IfUserHasAccess, Test-IfUserHasNTFSAccess...}
aliases     : {}
Author      : Michael Rhyndress
HasTest     : True
