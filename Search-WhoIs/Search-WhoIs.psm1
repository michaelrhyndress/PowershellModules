Function Search-WhoIs {
    Param (
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage='Please enter valid IPv4 Address',
                   ParameterSetName ="IP")]
        [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
        [string]$IPv4
    )

    If ($IPv4) {
        Try {
            $REST = Invoke-Restmethod "http://whois.arin.net/rest/ip/$IPv4" -Headers @{"Accept"="application/xml"}
            Try {
                $City = $null
                $City = (Invoke-RestMethod ($REST.net.orgRef.'#text')).org.city
            } Catch {}
            $propHash=[ordered] @{
                IP = $IPv4
                Name = $REST.net.name
                RegisteredOrganization = $REST.net.orgRef.name
                City = $City
                StartAddress = $REST.net.startAddress
                EndAddress = $REST.net.endAddress
                NetBlocks = $REST.net.netBlocks.netBlock | foreach {"$($_.startaddress)/$($_.cidrLength)"}
                Updated = $REST.net.updateDate -as [datetime]   
            }
            Write-Verbose ($REST.net | out-string)
            return $propHash
        }
        Catch {
            throw $_
        }
    }

    return $null
}

New-Alias -Name whois -Value Search-WhoIs
Export-ModuleMember -Function Search-WhoIs
Export-ModuleMember -Alias whois