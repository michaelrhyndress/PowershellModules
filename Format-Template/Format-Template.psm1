#
# Format_Template.psm1
#

function Format-Template {
<#
    .SYNOPSIS
    Replaces variables in a file with token values.

    .DESCRIPTION
    Takes a template file containing variables denoted by #KEY#
    and replaces the key with the associated hashtable value.

    .PARAMETER Template 
    Path to the template file.

    .PARAMETER Tokens 
    Key/Value pairs for replacing #variables# in template. 

    .EXAMPLE
	$tokens = @{
		Full_Name = 'Michael Rhyndress'
		Location = 'Midland'
		State = 'MI'
	}
	$template = Get-Content -Path TemplateEmail.html -RAW
	Format-Template -Template $template -Tokens $tokens
#> 

	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string] $Template,
		[Parameter(Mandatory=$true)]
		[hashtable] $Tokens
	)

	$Tp = $Template
	foreach ($Tk in $Tokens.GetEnumerator()) {
		$Pattern = '#{0}#' -f $Tk.key
		$Tp = $Tp -replace $Pattern, $Tk.Value
	}
	return $Tp
}

New-Alias -Name template -Value Format-Template
Export-ModuleMember -Function Format-Template
Export-ModuleMember -Alias template
