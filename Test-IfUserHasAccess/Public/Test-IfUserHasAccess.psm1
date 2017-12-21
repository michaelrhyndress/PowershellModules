@('../../../Vendor/PoshRSJob') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

<#
    Deny is faster than Access Granted
#>
Function Test-IfUserHasAccess {
<#
    .SYNOPSIS
    Determine if a user has access to a path via using both ACL and Security Descriptor

    .DESCRIPTION
    Matches a users associated groups with a group allowed via the Access Control List AND Security Descriptor.
    Check is run in parallel. It only takes one Access Denied to determine if the user has access.
    Both must be true to state access allowed.

    .EXAMPLE
    Test-IfUserHasAccess -Identity 'UA12345' -Path '\\server\share\path\to\folder' -SharePath '\\server\share'
#>

    Param (
        [Parameter(Mandatory=$True)]
        $Identity,
        [Parameter(Mandatory=$True)]
        $Path,
        [Parameter(Mandatory=$True)]
        $SharePath
    )

    $HasAccess = $null

    #region Check NTFS Access Job
    $CheckNTFSAccess = (Start-RSJob -Name "CheckNTFSAccess" `
        -ModulesToImport @([System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot './Test-IfUserHasNTFSAccess.psm1')))`
        -ScriptBlock {return (Test-IfUserHasNTFSAccess -Identity $Using:Identity -Path $Using:Path)})
    #endregion Check NTFS Access Job

    #region Check Share Access Job
    $CheckShareAccess = (Start-RSJob -Name "CheckShareAccess" `
        -ModulesToImport @([System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot './Test-IfUserHasShareAccess.psm1'))) `
        -ScriptBlock {return (Test-IfUserHasShareAccess -Identity $Using:Identity -SharePath $Using:SharePath)})
    #endregion Check Share Access Job
    
    #region if either is $false, then user does not have access.
    $ntfs = $share = $null

    :WhileRunning While ($HasAccess -eq $null) {

        If (($share -eq $null) -and $CheckShareAccess.Completed) {
            If ($CheckShareAccess.HasErrors) {
                throw $CheckShareAccess.Error
            }

            $share = ($CheckShareAccess.Output | Write-Output)
            Write-Verbose "CheckShareAccess State: $($CheckShareAccess.State); Value: $share"

            If ($share -eq $false) {
                $HasAccess = $false
            }
        }

        If (($ntfs -eq $null) -and $CheckNTFSAccess.Completed) {
            If ($CheckNTFSAccess.HasErrors) {
                throw $CheckNTFSAccess.Error
            }

            $ntfs = ($CheckNTFSAccess.Output | Write-Output)
            Write-Verbose "CheckNTFSAccess State: $($CheckNTFSAccess.State); Value: $ntfs"

            If ($ntfs -eq $false) {
                $HasAccess = $false
            }
        }

   
        If (($ntfs -eq $true) -and ($share -eq $true)) {
            $HasAccess = $true 
        }

    }
    #endregion if either is $false, then user does not have access.

    #Clean
    Remove-RSJob -Job $CheckNTFSAccess -Force
    Remove-RSJob -Job $CheckShareAccess -Force
    
    return $HasAccess
}

Export-ModuleMember -Function Test-IfUserHasAccess