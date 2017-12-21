Function ConvertTo-DistinguishedNameFromIdentityReference {
<#
    .SYNOPSIS
    Convert a IdentityReference to a DistinguishedName

    .DESCRIPTION
    Uses ADSI to convert a IdentityReference to a DistinguishedName

    .EXAMPLE
    ConvertTo-DistinguishedNameFromIdentityReference -IdentityReference 'Domain\Group'
#> 
    Param(
        [string] $IdentityReference
    )

    Try {
        
        If ($IdentityReference -eq 'Everyone') { return 'Everyone'}

        $IdentityReference = ($IdentityReference -replace "(?s)^.*\\","")
        
        $searcher = [ADSISEARCHER]"(cn=$IdentityReference)"
        $FOUND = $searcher.FindOne().Properties.distinguishedname
        $searcher.Dispose()
        If ($FOUND -eq $null) { 
            #throw ""
        }
        return $FOUND
    }
    Catch {
        Write-Error "Could not find Distinguished Name for $IdentityReference"
    }
}

Export-ModuleMember -Function ConvertTo-DistinguishedNameFromIdentityReference