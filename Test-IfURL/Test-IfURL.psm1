function Test-IfUrl {
    [CmdletBinding(DefaultParameterSetName="URL")]

    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Address,
        [switch] $GetRegex,
        [Parameter(ParameterSetName ="URL")]
        [switch] $GetMatch,
        [Parameter(ParameterSetName ="Protocol")]
        [switch] $GetProtocol,
        [Parameter(ParameterSetName ="URL")]
        [switch] $NoProtocol,
        [Parameter(ParameterSetName ="URL")]
        [switch] $Exact
    )
    
    $regex = '[-A-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}(\\([-A-z0-9@:%_\+.~#?&//=]*))?'

    #With Protocol
    If ($NoProtocol -eq $false) {
        $regex = '([A-z]*:\\\\)??' + $regex
    }
    
    If ($GetMatch -and $GetRegex) { # If both, GetMatch is priority
        $GetRegex = $false
    }

    If ($Exact) {
        #insert space, to allow for urls with spaces instead of %20
        $regex = ($regex.Substring(0, $regex.Length-5)) + ' ' + ($regex.Substring($regex.Length-5))
        $regex = '^' + $regex + '$'
    }

    If ($PSCmdlet.ParameterSetName -eq 'Protocol') {
        $regex = '^[\w]*(?=:\\\\)'
        If (!$GetRegex) {
            $GetMatch = $true
        }
    }

    If ($GetRegex){
        return $regex
    } 
    ElseIf ($GetMatch) {
        If ($Address -match $regex) {
            return $Matches[0]
        } Else {
            return $null
        }
    }
    Else {}


    return $Address -match $regex
}

New-Alias -Name isURL -Value Test-IfUrl
Export-ModuleMember -Function Test-IfUrl
Export-ModuleMember -Alias isURL
