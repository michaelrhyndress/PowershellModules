function Get-ADPrincipalGroupMembershipRecursive {

    Param(
        [string] $DistinguishedName,
        [array] $groups = @()
    )

    # Get an ADObject for the account and retrieve memberOf attribute.
	Try {
		$obj = Get-ADObject -Identity "$DistinguishedName" -Properties memberOf
    } Catch {
		#End of obj chain
	}
	Finally {
		If ($obj) {
			# Iterate through each of the groups in the memberOf attribute.
			foreach( $groupDsn in $obj.memberOf ) {

				# Get an ADObject for the current group.
                Try {
				    $tmpGrp = Get-ADObject $groupDsn -Properties memberOf
                } Catch {
                    #End of obj chain
                }
                Finally {
                    If ($tmpGrp) {        
        				$Contain = [PSCustomObject] @{
        					Base = $obj.Name
        					Groups = $tmpGrp.Name
        				}
                
        				# Check if the group is already in $groups.
        				if( ($groups | where { $_.DistinguishedName -eq $groupDsn }).Count -eq 0 ) {
                    
        					$groups += $Contain 

        					# Go a little deeper by searching this group for more groups.            
        					$groups = Get-ADPrincipalGroupMembershipRecursive $groupDsn $groups
        				}
                    }
                }
			}
		}
	}

    return $groups

}

Export-ModuleMember -Function Get-ADPrincipalGroupMembershipRecursive