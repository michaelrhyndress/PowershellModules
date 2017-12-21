Function Get-GroupMembers {
<#
    .SYNOPSIS
    Gets all members of a group

    .DESCRIPTION
    Gathers all members of a specific group using C# ActiveDirectory services. This is quicker than AD tools.

    .EXAMPLE
    Get-GroupMembers -DistinguishedName 'CN=Group,OU=Path,DC=corp,DC=com'
#>  
	Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $DistinguishedName,
        [switch] $Groups,
        [switch] $Users
    )

    If ([string]::IsNullOrWhitespace($DistinguishedName)) {
        return $null
    }

	$Result = $null

	Try {
		#Get all members of the passed group
		$Result = (Get-ADGroup -Identity $distinguishedName -Properties member).member
	} Catch {
		If ($_.Exception.Message.ToLower().Contains("s-1-5-21-")) {
			#Do nothing
			Write-Error $_.Exception.Message
		}
		Else {
			#Could be 'Everyone' or other error
			throw $_
		}
	}


    If ($Groups) {
        Write-Verbose 'Filtering by group'
        $Result = ($Result | ?{
            Try {
                (Get-ADObject $_).ObjectClass -eq 'Group'
            } Catch {}
        })
    }
    ElseIf ($Users) {
        Write-Verbose 'Filtering by user'
        $Result = ($Result | ?{
            Try {
                (Get-ADObject $_).ObjectClass -eq 'User'
            } Catch {}
        })
    }
    Else {}

    return $Result
}

Export-ModuleMember -Function Get-GroupMembers