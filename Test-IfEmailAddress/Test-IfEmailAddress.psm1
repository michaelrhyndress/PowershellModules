function Test-IfEmailAddress {
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Identity,
        [switch] $GetRegex,
        [switch] $GetMatch
    )

    If ($GetMatch -and $GetRegex) {
        Write-Error 'Only one GET may be specified'
        return
    }

    $regex = "\b[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+\.([a-zA-Z0-9-]+)*\b"


    If ($GetRegex){
        return $regex
    } ElseIf ($GetMatch) {
        If ($Identity -match $regex) {
            return $Matches[0]
        } Else {
            return $null
        }
    } Else {}

    return $Identity -match $regex
}

New-Alias -Name isEmailAddress -Value Test-IfEmailAddress
Export-ModuleMember -Function Test-IfEmailAddress
Export-ModuleMember -Alias isEmailAddress