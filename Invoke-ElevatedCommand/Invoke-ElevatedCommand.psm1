Function Invoke-ElevatedCommand {
  <#
    .DESCRIPTION
      Invokes the provided script block in a new elevated (Administrator) powershell process, 
      while retaining access to the pipeline (pipe in and out). Please note, "Write-Host" output
      will be LOST - only the object pipeline and errors are handled. In general, prefer 
      "Write-Output" over "Write-Host" unless UI output is the only possible use of the information.
      Also see Community Extensions "Invoke-Elevated"/"su"
    .EXAMPLE
      Invoke-ElevatedCommand {"Hello World"}
    .EXAMPLE
      "test" | Invoke-ElevatedCommand {$input | Out-File -filepath c:\test.txt}
    .EXAMPLE
      Invoke-ElevatedCommand {$one = 1; $zero = 0; $throwanerror = $one / $zero}
    .PARAMETER Scriptblock
      A script block to be executed with elevated priviledges.
    .PARAMETER InputObject
      An optional object (of any type) to be passed in to the scriptblock (available as $input)
    .PARAMETER EnableProfile
      A switch that enables powershell profile loading for the elevated command/block
    .PARAMETER DisplayWindow
      A switch that enables the display of the spawned process (for potential interaction)
    .SYNOPSIS
      Invoke a powershell script block as Administrator
  #>

  param
  (
    ## The script block to invoke elevated. NOTE: to access the InputObject/pipeline data from the script block, use "$input"!
    [Parameter(Mandatory = $true)]
    [ScriptBlock] $Scriptblock,
   
    ## Any input to give the elevated process
    [Parameter(ValueFromPipeline = $true)]
    $InputObject,
    
    ## Credential of the user you want to run as. If none provided, run as Administrator
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.CredentialAttribute()] $Credential,

    ## Switch to enable the user profile
    [switch] $EnableProfile,
   
    ## Switch to display the spawned window (as interactive)
    [switch] $DisplayWindow
  )
   
  Begin
  {
    Set-StrictMode -Version Latest
    $inputItems = New-Object System.Collections.ArrayList
  }
   
  Process
  {
    $null = $inputItems.Add($inputObject)
  }
   
  End
  {

    ## Create some temporary files for streaming input and output
    $outputFile = [IO.Path]::GetTempFileName()  
    $inputFile = [IO.Path]::GetTempFileName()
    $errorFile = [IO.Path]::GetTempFileName()

    ## Stream the input into the input file
    $inputItems.ToArray() | Export-CliXml -Depth 1 $inputFile
   
    ## Start creating the command line for the elevated PowerShell session
    $commandLine = ""
    if(-not $EnableProfile) { $commandLine += "-NoProfile " }

    if(-not $DisplayWindow) { 
      $commandLine += "-Noninteractive " 
      $processWindowStyle = "Hidden" 
    }
    else {
      $processWindowStyle = "Normal" 
    }
   
    ## Convert the command into an encoded command for PowerShell
    $commandString = "Set-Location '$($pwd.Path)'; " +
      "`$output = Import-CliXml '$inputFile' | " +
      "& {" + $scriptblock.ToString() + "} 2>&1 ; " +
      "Out-File -filepath '$errorFile' -inputobject `$error;" +
      "Export-CliXml -Depth 1 -In `$output '$outputFile';"
   
    $commandBytes = [System.Text.Encoding]::Unicode.GetBytes($commandString)
    $encodedCommand = [Convert]::ToBase64String($commandBytes)
    $commandLine += "-EncodedCommand $encodedCommand"

    If ((!$PSBoundParameters.ContainsKey('Credential')) -or ($Credential.Username -eq 'Administrator')) {
      Write-Verbose 'Running as Administrator'
      #region Start the new PowerShell process
      $process = Start-Process -FilePath (Get-Command powershell).Definition `
        -ArgumentList $commandLine `
        -Passthru `
        -Verb RunAs `
        -WindowStyle $processWindowStyle
      #endregion Start the new PowerShell process
    }
    Else {
      Write-Verbose "Running as $($Credential.UserName)"

      #region Grant access to temp files
      $IdentityReference = New-Object System.Security.Principal.NTAccount("$($Credential.UserName)")

      Foreach ($TempFile in @($outputFile, $inputFile, $errorFile)) {
        $acl = Get-Acl $TempFile
        $acl.AddAccessRule(( `
            New-Object System.Security.AccessControl.FileSystemAccessRule `
            @($IdentityReference, [System.Security.AccessControl.FileSystemRights]"Modify", [System.Security.AccessControl.AccessControlType]::Allow) `
        ))
        $acl | Set-Acl
      }
      #endregion Grant access to temp files

      #region Start the new PowerShell process
      $process = Start-Process -FilePath (Get-Command powershell).Definition `
        -ArgumentList $commandLine `
        -Credential $Credential `
        -Passthru `
        -WindowStyle $processWindowStyle
      #endregion Start the new PowerShell process
    }

    $process.WaitForExit()

    $errorMessage = $(gc $errorFile | Out-String)
    if($errorMessage) {
      Write-Error -Message $errorMessage
    }
    else {
      ## Return the output to the user
      if((Get-Item $outputFile).Length -gt 0)
      {
        Import-CliXml $outputFile
      }
    }

    ## Clean up
    Remove-Item $outputFile
    Remove-Item $inputFile
    Remove-Item $errorFile
  }
}

New-Alias -Name su -Value Invoke-ElevatedCommand
Export-ModuleMember -Function Invoke-ElevatedCommand
Export-ModuleMember -Alias su