Function Test-IfFileLocked {
<#

    .SYNOPSIS
    Tests if a file is locked

    .DESCRIPTION
    Will return TRUE if a user has a file open/locked.

    .EXAMPLE
    $File = get-item '../Path-to-file.txt'
    $File | Test-IfFileLocked

    .EXAMPLE
    $File = '../Path-to-file.txt'
    Test-IfFileLocked -Path $File
    
#>
     Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline=$true
        )] $Path
    )

    Try {
        $fileinfo = [System.IO.FileSystemInfo](gi -LiteralPath $Path -Force)
    } Catch {}

    $result = $false

    try {
        $stream = $fileInfo.Open([System.IO.FileMode]"Open",[System.IO.FileAccess]"ReadWrite",[System.IO.FileShare]"None")
        $stream.Dispose()
    } catch [System.IO.IOException] {
        $result = $true
    } catch {
        #all other errors
    }

    $result
}

New-Alias -Name islocked -Value Test-IfFileLocked
Export-ModuleMember -Function Test-IfFileLocked
Export-ModuleMember -Alias islocked