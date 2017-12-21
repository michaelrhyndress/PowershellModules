function Compress-Array {
<#

    .SYNOPSIS
    Flatten a nested Array

    .DESCRIPTION
    Flatten a nested Array

    .EXAMPLE
    $values = @(1, @(2, 3), $null, @(@(4), 5), 6)
    $values | Compress-Array
    
    Returns @(1,2,3,4,5,6)
    
#>

    $input | ForEach-Object{
        if ($_ -is [array]){$_ | Compress-Array}else{$_}
    } | Where-Object{![string]::IsNullorEmpty($_)}
}

New-Alias -Name splat -Value Compress-Array
Export-ModuleMember -Function Compress-Array
Export-ModuleMember -Alias splat