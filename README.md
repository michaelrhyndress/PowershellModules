Module      : Compare-HashTable<br />
Version     : 1.0<br />
Description : Computes differences between two Hashtables. Results are returned as an array of objects<br />
Functions   : {Compare-Hashtable}<br />
aliases     : {chash}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Compare-Set<br />
Version     : 1.0<br />
Description : Computes the Union and Intersection of two arrays. Can also determine if they are sub or super sets of <br />
              eachother.<br />
Functions   : {Compare-Set, Get-Intersection, Get-SymmetricDifference, Get-Union...}<br />
aliases     : {cset, intersection, symmdiff, union...}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Compress-Array<br />
Version     : 1.0<br />
Description : Flatten jagged Array<br />
Functions   : {Compress-Array}<br />
aliases     : {splat}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Convert-AccessMask<br />
Version     : 1.0<br />
Description : Converts int32 AccessMask into string file system rights and vice-versa.<br />
Functions   : {ConvertFrom-AccessMask, ConvertTo-AccessMask}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Convert-GroupScope<br />
Version     : 1.0<br />
Description : Converts AD groups to either Universal or Global Scope.<br />
Functions   : {ConvertTo-GlobalScope, ConvertTo-UniversalScope}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Convert-PermStringToACE<br />
Version     : 1.0<br />
Description : Convert ACE object to string and convert back to an ACE-like object.<br />
Functions   : {ConvertFrom-PermStringToACE, ConvertFrom-ACEToPermString}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : CredentialManager<br />
Version     : 1.0<br />
Description : Allows storing of credentials<br />
Functions   : {Get-CredentialStore, Get-StoredCredential, Register-Credential, Unregister-Credential}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Format-Template<br />
Version     : 1.0<br />
Description : Replaces tokens in raw string<br />
Functions   : {Format-Template}<br />
aliases     : {template}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Get-ADPrincipalGroupMembershipRecursive<br />
Version     : 1.0<br />
Description : Recursively gets principal group membership<br />
Functions   : {Get-ADPrincipalGroupMembershipRecursive}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Get-CustomProperties<br />
Version     : 1.0<br />
Description : Get Custom Properties that are set on files<br />
Functions   : {Get-CustomProperties}<br />
aliases     : {customprops}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Get-FolderSize<br />
Version     : 1.0<br />
Description : Calculates the size of a folder structure<br />
Functions   : {Get-FolderSize, Get-FolderSizeCom}<br />
aliases     : {gfs, gfsc}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Get-LevenshteinDistance<br />
Version     : 1.0<br />
Description : Find the approximate similarity between two strings by finding the # of edits to transform a string into <br />
              the other.<br />
Functions   : {Get-LevenshteinDistance, Find-ClosestMatchingString}<br />
aliases     : {Levenshtein, ClosestMatch}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Get-OutlookInbox<br />
Version     : 1.0<br />
Description : Returns emails from a mailbox<br />
Functions   : {Get-OutlookInbox, Get-OutlookInboxEWS}<br />
aliases     : {inbox, inboxEWS}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : HandleLongPath<br />
Version     : 1.0<br />
Description : Generic functions with long path support<br />
Functions   : {Get-LongPathACL, Get-LongPathChildItem, Get-LongPathItem}<br />
aliases     : {lpACL, lpGCI, lpGI}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Invoke-ElevatedCommand<br />
Version     : 1.0<br />
Description : Runs a scriptblock as Administrator or other user<br />
Functions   : {Invoke-ElevatedCommand}<br />
aliases     : {su}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : New-Share<br />
Version     : 1.0<br />
Description : Manages creation and removal of shared folders<br />
Functions   : {New-Share, Remove-Share }<br />
aliases     : {mkshare, rmshare}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Protect-String<br />
Version     : 1.0<br />
Description : Allows encrypting, decrypting, and hashing of strings<br />
Functions   : {Get-AESKey, Protect-String, Unprotect-String, ConvertTo-Hash}<br />
aliases     : {ekey, encrypt, decrypt, hstring}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Resolve-AbsolutePath<br />
Version     : 1.0<br />
Description : Resolves the abaolute path from a relative path<br />
Functions   : {Resolve-AbsolutePath}<br />
aliases     : {absolute}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Search-WhoIs<br />
Version     : 1.0<br />
Description : REST call to whois.arin to resolve information about ip<br />
Functions   : {Search-WhoIs}<br />
aliases     : {whois}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Split-Array<br />
Version     : 1.0<br />
Description : Splits array into chunks<br />
Functions   : {Split-Array}<br />
aliases     : {chunk}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Test-ADGroupMember<br />
Version     : 1.0<br />
Description : Checks if a user is a member of a group<br />
Functions   : {Test-ADGroupMember}<br />
aliases     : {isMemberOf}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Test-Credential<br />
Version     : 1.0<br />
Description : Takes a PSCredential object and validates it against the domain.<br />
Functions   : {Test-Credential}<br />
aliases     : {vcreds}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Test-IfEmailAddress<br />
Version     : 1.0<br />
Description : Test if string is a valid Email Address, can return boolean, matching address, or regex for UID<br />
Functions   : {Test-IfEmailAddress}<br />
aliases     : {isEmailAddress}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Test-IfFileLocked<br />
Version     : 1.0<br />
Description : Tests if a file is locked<br />
Functions   : {Test-IfFileLocked}<br />
aliases     : {islocked}<br />
Author      : Michael Rhyndress<br />
HasTest     : False<br />
<br />
<br />

Module      : Test-IfIPv4<br />
Version     : 1.0<br />
Description : Test if string has IPv4, can return boolean, matching ip, or regex for IPv4<br />
Functions   : {Test-IfIPv4}<br />
aliases     : {isIPv4}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Test-IfURL<br />
Version     : 1.0<br />
Description : Test if string has URL, can return boolean, matching URL in string (URL cannot have spaces), matching <br />
              url EXACTLY (with spaces), URL without Protocol, matching Protocol, or regex for each<br />
Functions   : {Test-IfURL}<br />
aliases     : {isURL}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
<br />
<br />

Module      : Test-IfUserHasAccess<br />
Version     : 1.0<br />
Description : Test if user can access a specific folder or file based on share and/or NTFS permissions.<br />
Functions   : {Get-AllUsersWithAccess, Test-IfIHaveAccess, Test-IfUserHasAccess, Test-IfUserHasNTFSAccess...}<br />
aliases     : {}<br />
Author      : Michael Rhyndress<br />
HasTest     : True<br />
