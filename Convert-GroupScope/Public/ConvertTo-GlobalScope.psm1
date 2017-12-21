Function ConvertTo-GlobalScope {
<#
	.SYNOPSIS
	Converts a Universal group to a Global Group

	.DESCRIPTION
	Checks to see if a Universal group can be safely converted into a Global Group.
	groups that are members of other groups and groups with Universal members cannot be converted.
	DomainLocal groups are converted into Universal groups to then be converted into Global Groups.

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

		#region Check if already Global
		If ($grp.GroupScope -eq 'Global') {
			Write-Verbose "$($grp.Name) is already Global."
			return
		}
		#endregion Check if already Global

		#region Check if DomainLocal
		If ($grp.GroupScope -eq 'DomainLocal') {
			#Convert to Universal first
			Try {
				ConvertTo-UniversalScope -Group $grp
			} Catch {
				throw $_
			}
			Finally {
				Start-Sleep -Milliseconds 40 # wait a sec
			}

			#Check again
			$grp = (Get-ADGroup -Identity $Group -Properties memberof, members)
			If ($grp.GroupScope -eq 'DomainLocal') {
				throw 'Could not convert DomainLocal Scope to Universal Scope first.'
			}
		}
		#endregion Check if DomainLocal

		#region Check all users in the same domain
		Try {
			$Domains = ,(($grp.members | get-adobject | %{$_.DistinguishedName.Split(',')[-2]}) | sort -Unique)
			If ($Domains.Count -ne 1) {
				throw "Cannot convert a group with members from multiple domains. Found: {0}" -f ($Domains -join '|')
			}
		} Catch {
			throw $_
		}
		#endregion Check all users in the same domain

		#region Check that all sub groups are not Universal
		foreach ($subGroup in ($grp.members | Get-ADObject | ?{$_.ObjectClass -eq 'group'} | get-adgroup)) {
			If ($subGroup.GroupScope -eq 'Universal') {
				throw 'A sub group of this group is Universal. Cannot convert.'
			}
		}

		#endregion Check that all sub groups are not Universal


		#region Convert to Global Scope
		Try {
			Set-ADGroup $grp -GroupScope Global
		} Catch {
			throw $_
		}
		#endregion Convert to Global Scope
	}

	End {}
}

Export-ModuleMember -Function ConvertTo-GlobalScope