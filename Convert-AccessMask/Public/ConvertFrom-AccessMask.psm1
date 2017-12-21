Function ConvertFrom-AccessMask {
<#
    .SYNOPSIS
    Converts an integer access mask to the string equivalent 

    .DESCRIPTION
    Uses the standard FileSystemRights enum to resolve basic permissions from access mask.
    If this failes, use bitwise operators to resolve other types of permissions, as the enum is incomplete. 

	.EXAMPLE
    ConvertFrom-AccessMask -AccessMask 537657624

    .EXAMPLE
    get-acl -Path '\\path\to\file'  | select -ExpandProperty access | select @{l='FileSystemRights'; e={ConvertFrom-AccessMask $_.FileSystemRights}}

#>

	Param (
		[Parameter(Mandatory=$true)] $AccessMask
	)
    $permissions = @()


	Try {
        If ([int]$AccessMask -lt ([uint32]::MinValue-1)) {
            #Convert to Uint32 if negative
            $AccessMask = ([uint32]::MaxValue+1) + [int32]$AccessMask
        }
        
        $AccessMask = [uint32]$AccessMask
	} Catch {
		throw $_
	}

    do  {
        $Removed = $false

        Try {
            $val = [System.Security.AccessControl.FileSystemRights]$AccessMask
            $permissions += "$val"
            $AccessMask = $AccessMask -band (-bnot $val)
            $Removed = $true
        } Catch {

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
    			?{($AccessMask -band $_.Value) -eq $_.Value} |
    			%{
                    $permissions += $_.Name
                    $AccessMask = $AccessMask -band (-bnot $_.Value)
                    $Removed = $true
                }
        }
    } Until ($AccessMask -eq 0 -or $Removed -eq $false)

    If ($Removed -eq $false) {
        #Something is left over.
        Throw "Missing access mask conversion. Remaining value is: $AccessMask"
    }

	return ($permissions -join ', ')
}

Export-ModuleMember -Function ConvertFrom-AccessMask