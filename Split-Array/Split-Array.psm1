function Split-Array {
<#

    .SYNOPSIS
    Splits an array into chunks

    .DESCRIPTION


    .EXAMPLE
    $example = 1..11
    Split-Array -List $example -SplitSize 10
    
#>
    param(
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] $List,
        [Parameter(Mandatory=$true)][ValidateRange(1, 247483647)][int] $SplitSize)

    begin {
        $Ctr = 0
        $Array = @()
        $TempArray = @()
    }
    process {
        foreach ($e in $List) {
            if (++$Ctr -eq $SplitSize) {
                $Ctr = 0
                $Array += , @($TempArray + $e)
                $TempArray = @()
                continue
            }
            $TempArray += $e
        }
    }
    end {
        if ($TempArray) { $Array += , $TempArray }
        $Array
    }
}

New-Alias -Name chunk -Value Split-Array
Export-ModuleMember -Function Split-Array
Export-ModuleMember -Alias chunk
