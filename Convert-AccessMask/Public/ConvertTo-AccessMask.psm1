Function ConvertTo-AccessMask {
<#
    .SYNOPSIS
    Converts string permissions into int access mask equivalent 

    .DESCRIPTION
    Uses the standard FileSystemRights enum to resolve access mask from string permissions.
    If this failes, use bitwise operators to resolve other types of permissions, as the enum is incomplete. 

	.EXAMPLE
    ConvertTo-AccessMask -FileSystemRights 'FullControl'
#>

	Param (
		[Parameter(Mandatory=$true)] $FileSystemRights
	)

    $AccessMask = 0

    #Should be in format like: 'FullControl, write, read'
    $FileSystemRights = $FileSystemRights.Split(',').Trim()
	
    $FileSystemRights | %{
        $Perm = $_
        $Added = $false
        #Try to resolve the easy way.
        Try {
            $val = [System.Security.AccessControl.FileSystemRights]($Perm)
    		$AccessMask = $AccessMask -bor $val
            $Added = $true
    	} Catch {
            Try {
                @{  DELETE = [uint32]0x00010000L
                    READ_CONTROL = [uint32]0x00020000L
                    WRITE_DAC = [uint32]0x00040000L
                    WRITE_OWNER = [uint32]0x00080000L
                    SYNCHRONIZE = [uint32]0x00100000L
                    STANDARD_RIGHTS_REQUIRED = [uint32]0x000F0000L
                    STANDARD_RIGHTS_ALL = [uint32]0x001F0000L
                    SPECIFIC_RIGHTS_ALL = [uint32]0x0000FFFFL
                    ACCESS_SYSTEM_SECURITY = [uint32]0x01000000L
                    MAXIMUM_ALLOWED = [uint32]0x02000000L
                    GENERIC_READ = [uint32]0x80000000L
                    GENERIC_WRITE = [uint32]0x40000000L
                    GENERIC_EXECUTE = [uint32]0x20000000L
                    GENERIC_ALL = [uint32]0x10000000L
                }.GetEnumerator() | 
                    ?{$Perm -eq $_.Name} |
                    %{
                        $AccessMask = $AccessMask -bor $_.Value
                        $Added = $true
                    }
            }
            Catch {}
        }
        Finally {
            If (!$Added) {
                Throw "Could not convert $Perm to access mask"
            }
        }
    }


    If ($AccessMask -gt ([int32]::MaxValue+1)) {
        #Convert to int32
        [int32] $AccessMask = ([uint32]$AccessMask - ([uint32]::MaxValue+1))
    }
    
    return [int32]$AccessMask
    
}

Export-ModuleMember -Function ConvertTo-AccessMask