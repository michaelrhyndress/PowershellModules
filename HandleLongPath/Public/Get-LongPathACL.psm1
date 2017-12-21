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

Function Get-LongPathACL {

	Param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]$Path
	)

    Process {
        Write-Output ([Alphaleonis.Win32.Filesystem.Directory]::GetAccessControl((Resolve-AbsolutePath $Path))) #Get NTFS permissions
    }
}

New-Alias -Name lpACL -Value Get-LongPathACL
Export-ModuleMember -Function Get-LongPathACL
Export-ModuleMember -Alias lpACL