@('../AlphaFS/AlphaFS.dll',
  '../../Resolve-AbsolutePath'
) | %{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

Function Get-LongPathChildItem {

    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)][string] $Path,
        [Parameter(Mandatory=$false)][string] $Filter = '*',
        [switch] $Directory,
        [switch] $File,
        [switch] $Recurse,
        [switch] $ListOnly
    )

    Begin {
        $PathFormat = [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath
        
        If (!$Directory -and !$File) { #default to both
            $Directory = $true
            $File = $true
        }

        $Settings = New-Object System.Collections.ArrayList($null)

        If ($Directory) { [void] $Settings.Add('Folders') }
        If ($File) { [void] $Settings.Add('Files') }

        [void] $Settings.Add('BasicSearch')
        [void] $Settings.Add('SkipReparsePoints')
        [void] $Settings.Add('ContinueOnException')
              
        If ($Recurse) {
            [void] $Settings.Add('Recursive')
        }

        $DirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]"$($Settings -join ', ')"
    }

    Process {
        [Alphaleonis.Win32.Filesystem.Directory]::EnumerateFileSystemEntries((Resolve-AbsolutePath $Path), $Filter, $DirEnumOptions, $PathFormat) | %{
            If ($ListOnly) {
                return $_
            }

            return [Alphaleonis.Win32.Filesystem.DirectoryInfo]$_
        }
    }
}

New-Alias -Name lpGCI -Value Get-LongPathChildItem
Export-ModuleMember -Function Get-LongPathChildItem
Export-ModuleMember -Alias lpGCI