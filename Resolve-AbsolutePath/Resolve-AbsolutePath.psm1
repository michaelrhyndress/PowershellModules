Function Resolve-AbsolutePath {
    Param(
        [string]$Path
    )
    return [System.IO.Path]::GetFullPath([System.IO.Path]::Combine(((pwd).Path),($Path)));
}

New-Alias -Name absolute -Value Resolve-AbsolutePath
Export-ModuleMember -Function Resolve-AbsolutePath
Export-ModuleMember -Alias absolute