@('../AlphaFS/AlphaFS.dll') | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Get-LongPathItem {

    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)][string]$Path,
        [switch] $Full
    )

    Process {
        If ($Full) {
            [Alphaleonis.Win32.Filesystem.File]::GetFileSystemEntryInfo($Path)
        }
        Else {
            [Alphaleonis.Win32.Filesystem.DirectoryInfo]$Path
        }
    }
}

New-Alias -Name lpGI -Value Get-LongPathItem
Export-ModuleMember -Function Get-LongPathItem
Export-ModuleMember -Alias lpGI