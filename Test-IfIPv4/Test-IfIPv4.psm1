function Test-IfIPv4 {
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Address,
	    [switch] $GetRegex,
        [switch] $GetMatch
    )

    If ($GetMatch -and $GetRegex) {
        Write-Error 'Only one GET may be specified'
        return
    }

    $regex = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
        
    If ($GetRegex){
        return $regex
    } ElseIf ($GetMatch) {
        If ($Address -match $regex) {
            return $Matches[0]
        } Else {
            return $null
        }
    }  Else {}

    return $Address -match $regex
}

New-Alias -Name isIPv4 -Value Test-IfIPv4
Export-ModuleMember -Function Test-IfIPv4
Export-ModuleMember -Alias isIPv4
