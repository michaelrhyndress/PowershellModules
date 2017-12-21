@('../Convert-AccessMask') |
%{
    Import-Module (`
        Get-Item (`
            [System.IO.Path]::GetFullPath((`
                Join-Path $PSScriptRoot $_`
            ))`
        )`
    )
}

function ConvertFrom-PermStringToACE {
<#
    .SYNOPSIS
    Converts permissions stored in database as string into a ACE-like representation

    .DESCRIPTION
    Converts permissions stored in database as string into a ACE-like representation
    Format is [IdentityReference]: (Deny|Allow)?[FileSystemRights](|)?
    Use case for excluding would be if you don't need to resolve AccessMask

    .EXAMPLE
    ConvertFrom-PermStringToAce 'Domain\User: AllowFullControl'

    .EXAMPLE
    ConvertFrom-PermStringToAce 'Domain\User: AllowFullControl' -Exclude AccessMask
#>

    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String] $String,
        [Parameter(Mandatory=$false)]
        [ValidateSet('IdentityReference','AccessControlType','FileSystemRights','AccessMask')]
        [string[]] $Exclude
    )

    $Include = @(
        'IdentityReference',
        'AccessControlType',
        'FileSystemRights',
        'AccessMask'
    ) | ?{$_ -notin $Exclude}

    $Include = $Include | ?{$_ -notin $Exclude}

    $String.Split('|') | %{
        If ($_ -match 'error retrieving' -or [String]::IsNullOrEmpty($_)) { return $null}
        
        $Split = $_.Split(':').Trim()
        If (![String]::IsNullOrEmpty($Split[0])) {
            
            $Out = @{
                IdentityReference = $null
                AccessControlType=$null
                FileSystemRights=$null
                AccessMask = $null
            }

            If ($Include -contains 'IdentityReference') {
                $Out.IdentityReference = $Split[0] -replace "(?s)^.*\\",""
            }
            If ($Include -contains 'AccessControlType') {
                $Out.AccessControlType=@{$true='Deny';$false='Allow'}[$Split[1] -match 'Deny']
            }
            If ($Include -contains 'FileSystemRights') {
                $Out.FileSystemRights=$Split[1] -replace '(Deny|Allow)',''
            }
            If ($Include -contains 'AccessMask') {
                $Out.AccessMask = ConvertTo-AccessMask -FileSystemRights ($Split[1] -replace '(Deny|Allow)','')
            }

            return $Out
        }
    }
}

Function ConvertFrom-ACEToPermString {
<#
    .SYNOPSIS
    Converts permissions stored in database as string into a ACE-like representation

    .EXAMPLE
    ConvertFrom-ACEToPermString (Get-ACL).Access[0]

    .EXAMPLE
    Get-SecurityDescriptor '\\share\path' -ObjectType LMShare |  Select -ExpandProperty Access | ConvertFrom-ACEToPermString

    .EXAMPLE
    $CustomObj = [PSCustomObject] @{
        IdentityReference='Domain\User'
        AccessControlType='Allow'
        AccessMask=4
    }
    ConvertFrom-ACEToPermString $CustomObj
#>

    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$ACE
    )

    Begin {
        $Result = New-Object System.Collections.ArrayList($null)
    }

    Process {
        $Who = $null
        $CanDo = $null
        $What = $null

        If ($ACE -is [System.Security.AccessControl.QualifiedAce]) {
            $Who = "$($ACE.Principal)"
            $CanDo = @{$true='Allow';$false='Deny'}[$ACE.AceType -match 'Allow']
            $What = "$(Convertfrom-AccessMask $ACE.AccessMask)"
        }
        ElseIf ($Ace -is [System.Security.AccessControl.AccessRule]) {
            $Who = "$($ACE.IdentityReference)"
            $CanDo = @{$true='Allow';$false='Deny'}[$ACE.AccessControlType -match 'Allow']
            $What = "$(Convertfrom-AccessMask $Ace.FileSystemRights.value__)"
        }
        Else {
            Try {
                $Who = "$($ACE.IdentityReference)"
                $CanDo = @{$true='Allow';$false='Deny'}[$ACE.AccessControlType -match 'Allow']

                If ($Ace.AccessMask) {
                    $What = "$(Convertfrom-AccessMask $ACE.AccessMask)"
                }
                ElseIf ($Ace.FileSystemRights) {
                    $What = "$($ACE.FileSystemRights)"
                }
                Else {
                    throw 'Custom object must contain FileSystemRights and/or AccessMask'
                }

            } Catch {
                throw $_
            }
        }
        
        If (!$Who -or !$CanDo -or !$What) {
            throw 'Could not complete string'
        }

        [void] $Result.Add(('{0}:{1}{2}' -f ($Who,$CanDo,$What)))
    }

    End {
        return $Result -join '|'
    }
}

Export-ModuleMember -Function ConvertFrom-PermStringToACE
Export-ModuleMember -Function ConvertFrom-ACEToPermString