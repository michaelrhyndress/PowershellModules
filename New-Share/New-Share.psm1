function New-Share {
<#

    .EXAMPLE
    mkshare -Folder "\\$Server\d$\$Share" -ShareName $Share -LocalPath "C:\vol\d\$Share" -Description 'Share description'

#>
    Param (
        [Parameter(Mandatory=$true, HelpMessage="Full UNC path to new shared folder")]
        [string] $Folder,
        [Parameter(Mandatory=$true, HelpMessage="Name of the new share, as found in AD and Permissions")]
        [string] $ShareName,
		[Parameter(Mandatory=$true, HelpMessage="Local path of new share on its host server")]
        [string] $LocalPath,
        [Parameter(Mandatory=$false, HelpMessage="Description of the share")]
        [string] $Description,
        [switch] $Private
    )

	$Existed = $false

    if (!(Test-Path $Folder)) { #IF not exists
        Try {
            $FolderObj = New-Item $Folder -type Directory
        } Catch {
            Throw $_
        }
    } else { #IF Exists
        Try {
            $FolderObj = Get-Item $Folder
            $Existed = $true
        } Catch {
            Throw $_
        }
    }

    if (!$Private) { # Do not share folder if Private switch
		Try {
			$ServerName = $Folder.Split('\', 5)[2]
			Write-Verbose $ServerName
			Write-Verbose $ShareName
			Write-Verbose $LocalPath
			Write-Verbose $Description
			$LanMan = [ADSI]"WinNT://$ServerName/lanmanserver"
			If (!$LanMan.psbase.Name) {
				Throw "Error Connecting to WinNT://$ServerName/lanmanserver"
			}
			$NewShareObj = $LanMan.Create("FileShare", $ShareName)
			[void]$NewShareObj.Put("Path", $LocalPath)
			[void]$NewShareObj.Put("Description", $Description)
			[void]$NewShareObj.SetInfo()
			[void]$LanMan.Close(); [void]$LanMan.Dispose()
			[void]$NewShareObj.Close(); [void]$NewShareObj.Dispose()

			#Test that it is there
			If ([bool]([ADSI]"WinNT://$ServerName/lanmanserver/$ShareName").Path -eq $false) {
				Throw "Failed to create WinNT://$ServerName/lanmanserver/$ShareName"
			}
		} Catch {
            If ($_.Exception.Message.ToLower().Contains("directory object exists")) { #already shared, technically

            } Else {
    			If ($Existed -eq $false) { #IF not Existed at start, delete since it failed to share
    				Remove-Item $FolderObj
    			}
    			Throw $_
            }
		}
	}
    # THIS IS FOLDER SHARING FOR WINDOWS, OUR SERVERS USE LANMANSERVER FILER
    # if (!(get-wmiObject Win32_Share -filter "name='$ShareName'")) { #IF name not used
    #     $shares = [WMICLASS]"WIN32_Share"
    #     $result = $shares.Create($Folder, $ShareName, 0, $null, $Description).ReturnValue
    #     Switch ($result) { #SWITCH Error code or Success
    #         0   { return $FolderObj } #Success
    #         2   {Write-Error 'Access Denied';break;}
    #         8   {Write-Error 'Unknown Failure';break;}
    #         9  {Write-Error 'Invalid Name';break;}
    #         10  {Write-Error 'Invalid Level';break;}
    #         21  {Write-Error 'Invalid Parameter';break;}
    #         22  {Write-Error 'Duplicate Share';break;}
    #         23  {Write-Error 'Redirected path';break;}
    #         24  {Write-Error 'Unknown device or directory';break;}
    #         25  {Write-Error 'Net name not found';break;}
    #         {$_ -ge 26} {Write-Error "An unspecified error occured. Error Code:($_)";break;}
    #     }
    #     $result = $null
    #     If ($Existed -eq $false) { #IF not Existed at start, delete since it failed to share
    #         Remove-Item $FolderObj
    #     }
    # } 
    return $FolderObj
}


function Remove-Share {
	Param(
		[Parameter(Mandatory=$true, HelpMessage="Full UNC path to shared folder")]
        [string] $Folder,
		[Parameter(Mandatory=$true, HelpMessage="Name of the share, as found in AD and Permissions")]
        [string] $ShareName,
		[switch] $KeepDirectory
	 )

	Try {
		$FolderObj = Get-Item $Folder
	} Catch {
		Throw $_
    }

	Try {
		$ServerName = $Folder.Split('\', 5)[2]
		$LanMan = [ADSI]"WinNT://$ServerName/lanmanserver"
		[void]$LanMan.Delete("FileShare",$ShareName)
		[void]$LanMan.Close(); [void]$LanMan.Dispose()

		#Test that it is there
		If ([bool]([ADSI]"WinNT://$ServerName/lanmanserver/$ShareName").Path -eq $true) {
			Throw "Failed to delete WinNT://$ServerName/lanmanserver/$ShareName"
		}

	} Catch {
        If ($_.Exception.Message.ToLower().Contains("does not exist")) {
            Write-Host "Folder is not currently being shared"
        } Else {
		  Throw $_
        }
	}

    If (!$KeepDirectory -and $FolderObj -ne $null) { # Delete Share
        Remove-Item $FolderObj
    }

    return $true
	#THIS IS FOLDER SHARING FOR WINDOWS, OUR SERVERS USE LANMANSERVER FILER
	#If ($share = get-wmiObject Win32_Share -filter "name='$Name'") { $share.delete() }
}

New-Alias -Name mkshare -Value New-Share
Export-ModuleMember -Function New-Share
Export-ModuleMember -Alias mkshare

New-Alias -Name rmshare -Value Remove-Share
Export-ModuleMember -Function Remove-Share
Export-ModuleMember -Alias rmshare