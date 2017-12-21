Function ConvertTo-UniversalScope {
<#
	.SYNOPSIS
	Converts a DomainLocal or Global group to a Universal Group

	.DESCRIPTION
	Checks to see if a Global/DomainLocal group can be safely converted into a Universal Group and then converts it.
	Groups that are members of other groups, and Global groups with Universal members cannot be converted.

	.EXAMPLE
	ConvertTo-GlobalScope -Group 'icrm-chg'

#>
    Param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		$Group
    )

	Begin {}

	Process {
		#region Resolve Group
		Try {
			$grp = (Get-ADGroup -Identity $Group -Properties memberof, members)
		}
		Catch {
			throw $_
		}

		If (!$grp) {
			throw "Could not resolve Group: $Group"
		}
		#endregion Resolve Group

		#region Check if already Universal
		If ($grp.GroupScope -eq 'Universal') {
			Write-Verbose "$($grp.Name) is already Universal."
			return
		}
		#endregion Check if already Universal

		#region Check that all sub groups are not DomainLocal
		foreach ($subGroup in ($grp.members | Get-ADObject | ?{$_.ObjectClass -eq 'group'} | get-adgroup)) {
			If ($subGroup.GroupScope -eq 'DomainLocal') {
		 		throw 'A sub group of this group is DomainLocal. Cannot convert.'
			}
		}
		#endregion Check that all sub groups are not DomainLocal

		#region Convert to Universal Scope
		Try {
			Set-ADGroup $grp -GroupScope Universal
		} Catch {
			throw $_
		}
		#endregion Convert to Universal Scope
	}

	End {}
}

Export-ModuleMember -Function ConvertTo-UniversalScope