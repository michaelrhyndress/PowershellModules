Function Test-IfIHaveAccess {
<#
    .SYNOPSIS
    Determine if the current user has access to a path

    .DESCRIPTION
    Attempts to open a file, if we cannot, we do not have access.

    .EXAMPLE
    Test-IfIHaveAccess -Path '\\server\share\folder'

    .EXAMPLE
    Test-IfIHaveAccess -Path '\\server\share\folder' -Write
#>
    Param (
        [Parameter(Mandatory=$true)]
        $Path,
        [switch] $Write
    )

    $HasAccess = $false
    Try {
        [System.IO.File]::OpenRead($Path).close()
        $HasAccess = $true
        Write-Verbose 'Has Read Access'
    } Catch {
        Write-Warning "Unable to Read file $Path"
    }

    Try {
        [System.IO.File]::OpenWrite($Path).close()
        $HasAccess = $true
        Write-Verbose 'Has Write Access'
    } Catch {
        Write-Warning "Unable to write to file $Path"
        If ($Write) { #return False if Write switch set
            return $false
        }
    }

    return $HasAccess

}

Export-ModuleMember -Function Test-IfIHaveAccess