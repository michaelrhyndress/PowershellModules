Function Get-FolderSize {
<#
    .SYNOPSIS
    Calculates the size of a folder by traversing and getting each sub-file's size

    .DESCRIPTION
    Calculates the size of a folder. Can be done recursivly to obtain
    the actual size of the folder and all sub-folders. Can convert
    the size to Bytes, KB, MB, GB, or TB.

    .PARAMETER Path 
    Path to directory

    .PARAMETER Format 
    Conversion size. Default is Bytes.
    Possible choices are: "Bytes","KB","MB","GB","TB"

    .PARAMETER Recurse
    Triggers a recursive sum of all sub folder sizes

    .EXAMPLE
    Get-FolderSize -Path 'C:\'

    .EXAMPLE
    Get-FolderSize -Path 'C:\' -Format "GB" -Recurse
#>

    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$True)]
        $Path,
        [Parameter(Mandatory=$false)]
        [validateset("Bytes","KB","MB","GB","TB")]
        [string] $Format = 'Bytes',
        [switch] $Recurse
    )

    $Size = -1

    Try {
        
        If ($Path.gettype().BaseType -eq [System.IO.FileSystemInfo]) {
            $StringPath = $Path.FullName
        } ElseIf ($Path.gettype() -eq [string]) {
            $StringPath = $Path
        } Else {
            throw "Path is not a valid data type"
        }

        $Size = (gci -LiteralPath $StringPath -Recurse:$Recurse -File | measure-object -Property length -sum).sum

        switch ($Format) {            
            "Bytes" {$Size =  $Size; break}            
            "KB" {$Size = $Size/1KB; break}            
            "MB" {$Size = $Size/1MB; break}            
            "GB" {$Size = $Size/1GB; break}            
            "TB" {$Size = $Size/1TB; break}           
        }
    } Catch {
        throw $_
    }

    return $Size
}


Function Get-FolderSizeCom {
<#
    .SYNOPSIS
    Calculates the size of a folder using Windows API

    .DESCRIPTION
    Gets the precaulculated size of a folder, and sub-folders, from Windows API.
    This is how Win Explorer generates folder sizes.
    Can convert the size to Bytes, KB, MB, GB, or TB.

    .PARAMETER Path 
    Path to directory

    .PARAMETER Format 
    Conversion size. Default is Bytes.
    Possible choices are: "Bytes","KB","MB","GB","TB"

    .EXAMPLE
    Get-FolderSizeCom -Path 'C:\'

    .EXAMPLE
    Get-FolderSize -Path 'C:\' -Format "GB"
#>

    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$True)]
        $Path,
        [Parameter(Mandatory=$false)]
        [validateset("Bytes","KB","MB","GB","TB")]
        [string] $Format = 'Bytes'
    )

    $Size = -1
    $fso = New-Object -com Scripting.FileSystemObject

    Try {

        If ($Path.gettype().BaseType -eq [System.IO.FileSystemInfo]) {
            $StringPath = $Path.FullName
        } ElseIf ($Path.gettype() -eq [string]) {
            $StringPath = $Path
        } Else {
            throw "Path is not a valid data type"
        }

        $Size = $fso.GetFolder($StringPath).Size
        
        If ($Size) {
            switch ($Format) {            
                "Bytes" {$Size = $Size; break}            
                "KB" {$Size = $Size/1KB; break}            
                "MB" {$Size = $Size/1MB; break}            
                "GB" {$Size = $Size/1GB; break}            
                "TB" {$Size = $Size/1TB; break}           
            }
        } Else {
            throw "Size property does not exist"
        }
    } Catch {
        throw $_
    }

    $fso = $null

    return $Size
}

New-Alias -Name gfs -Value Get-FolderSize
Export-ModuleMember -Function Get-FolderSize
Export-ModuleMember -Alias gfs

New-Alias -Name gfsc -Value Get-FolderSizeCom
Export-ModuleMember -Function Get-FolderSizeCom
Export-ModuleMember -Alias gfsc