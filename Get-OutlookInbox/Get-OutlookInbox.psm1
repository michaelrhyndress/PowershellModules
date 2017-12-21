Function Get-OutlookInbox

{

  <#

   .Synopsis

    This function returns InBox items from default Outlook profile

   .Description

    This function returns InBox items from default Outlook profile. It

    uses the Outlook interop assembly to use the olFolderInBox enumeration.

    It creates a custom object consisting of Subject, ReceivedTime, Importance,

    SenderName for each InBox item.

    *** Important *** depending on the size of your InBox items this function

    may take several minutes to gather your InBox items. If you anticipate

    doing multiple analysis of the data, you should consider storing the

    results into a variable, and using that.

    # Script: Get-OutlookInbox.ps1 
    # Author: ed wilson, msft 
    # Date: 05/10/2011 08:34:36 
    # Keywords: Microsoft Outlook, Office 
    # comments: 
    # reference to HSG-1-29-09, HSG-5-24-11 
    # HSG-5-25-11 

   .Example

    Get-OutlookInbox |

    where { $_.ReceivedTime -gt [datetime]"5/5/11" -AND $_.ReceivedTime -lt `

    [datetime]"5/10/11" } | sort importance

    Displays Subject, ReceivedTime, Importance, SenderName for all InBox items that

    are in InBox between 5/5/11 and 5/10/11 and sorts by importance of the email.

   .Example

    Get-OutlookInbox | Group-Object -Property SenderName | sort-Object Count

    Displays Count, SenderName and grouping information for all InBox items. The most

    frequently used contacts appear at bottom of list.

   .Example

    $InBox = Get-OutlookInbox

    Stores Outlook InBox items into the $InBox variable for further

    "offline" processing.

   .Example

    ($InBox | Measure-Object).count

    Displays the number of messages in InBox Items

   .Example

    $InBox | where { $_.subject -match ‘2011 Scripting Games’ } |

     sort ReceivedTime -Descending | select subject, ReceivedTime -last 5

    Uses $InBox variable (previously created) and searches subject field

    for the string '‘'2011 Scripting Games'’' it then sorts by the date InBox.

    This sort is descending which puts the oldest messages at bottom of list.

    The Select-Object cmdlet is then used to choose only the subject and ReceivedTime

    properties and then only the last five messages are displayed. These last

    five messages are the five oldest messages that meet the string.

 #>

param(
  [string] $Account,
  [string] $Folder
)
 

Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null

$olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type]

$outlook = new-object -comobject outlook.application

$namespace = $outlook.GetNameSpace("MAPI")

If ($PSBoundParameters.ContainsKey('Account')) {
  try {
    $oRep = $namespace.CreateRecipient($Account)
    $SelectedFolder = $namespace.getSharedDefaultFolder($oRep, $olFolders::olFolderInBox)

    If ($PSBoundParameters.ContainsKey('Folder')) {

      $FolderSplit = $Folder.Split('\')

      foreach ($root in $FolderSplit) {
        $SelectedFolder = $SelectedFolder.Folders["$root"]
      }

    }

  } Catch {
    throw $_
  }
} Else {
  $SelectedFolder = $namespace.getDefaultFolder($olFolders::olFolderInBox)
}
$SelectedFolder.items | Sort-Object -Descending ReceivedTime | Select-Object -Property Subject, ReceivedTime, Importance, SenderName, Body

} #end function Get-OutlookInbox


Function Get-OutlookInboxEWS {
<#
    .SYNOPSIS
    Uses EWS to fetch inbox items from Account, and specified Folder (or default).

    .DESCRIPTION
    Uses EWS to fetch inbox items from Account, and specified Folder (or default).
    Credentials can be pre supplied, or gathered on function call.
    Different amounts of information can be loaded from EWS, including:
      Attachment Data
      Text Body
      Time Information
      Receipt Request Information
      Meta Information

    .PARAMETER Account 
    EWS Account to connect to

    .PARAMETER Folder 
    Specific folder to get items from

    .PARAMETER Credential 
    Credentials to gain access to Account

    .PARAMETER PageSize
    How many emails to return at once in a batch.
    Default is 500. If AllEmails is not specified, only this amount will be gathered.

    .PARAMETER AllEmails
    If specified, loops through all emails in batches the size of PageSize.

    .PARAMETER AttachmentData
    Adds Attachment information to output object:
      Attachments
      HasAttachments

    .PARAMETER BodyAsText
    Adds the body of email in text form to output object.

    .PARAMETER TimeData
    Adds Time information to output object:
      DateTimeReceived
      DateTimeSent
      DateTimeCreated

    .PARAMETER ReceiptData
    Adds Receipt information to output object:
      IsResponseRequested
      IsReadReceiptRequested
      IsDeliveryReceiptRequested

    .PARAMETER MetaData
    Adds Meta information to output object:
      InternetMessageHeaders
      MimeContent
      IsRead
      Size
      InternetMessageId
      ParentFolderId
      Culture
      DisplayCc
      DisplayTo
      EffectiveRights
      InReplyTo
      ItemClass
      LastModifiedName
      LastModifiedTime
      ReminderDueBy
      RetentionDate
      ReminderMinutesBeforeStart
      UniqueBody
      ConversationIndex
      ConversationTopic
      ReplyTo
      References
      ReceivedRepresenting
      ReceivedBy

    .EXAMPLE
    $6MonthsAgo = (Get-Date).AddMonths(-6)
    $Emails = Get-OutlookInboxEWS -Account 'email@domain.com' -Folder '2017\Data' -BodyAsText -TimeData | ?{
        $_.Subject -like "Survey Results for *" -and $_.DateTimeReceived -ge $6MonthsAgo
    } | Select Subject, From, TextBody, DateTimeReceived, DateTimeSent
#>


	Param(
		[Parameter(Mandatory=$true)][string] $Account,
		[string] $Folder,
		[System.Management.Automation.CredentialAttribute()] $Credential,
		[int] $PageSize = 500,
    [int] $Max = -1,
		[switch] $AllEmails,
		[switch] $AttachmentData,
		[switch] $BodyAsText,
		[switch] $TimeData,
		[switch] $ReceiptData,
		[switch] $MetaData,
		[switch] $vNext #2017
	)
	
  Begin {

    @('../Test-IfEmailAddress', './Exchange/Web Services/2.2/Microsoft.Exchange.WebServices.dll') | %{
        Import-Module (`
            Get-Item (`
                [System.IO.Path]::GetFullPath((`
                    Join-Path $PSScriptRoot $_`
                ))`
            )`
        )
    }

  	<# region Connection #>
  	If (!$PSBoundParameters.ContainsKey('Credential')) {
  		$psCred = (Get-Credential)
  	} Else {
  		$psCred = $Credential
  	}

    If ($vNext) {
  		If (!(Test-IfEmailAddress -Identity $psCred.UserName.ToString())) {
  			throw $_
  		}
    }

  	$exchService = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService         
    [void] $exchService.HttpHeaders.Add("X-AnchorMailbox", $Account)                                                                   

    $exchCred = New-Object System.Net.NetworkCredential( `
                    $psCred.UserName.ToString(), `
                    $psCred.GetNetworkCredential().password.ToString())

  	$exchService.UseDefaultCredentials = $false
  	$exchService.Credentials = $exchCred
  	$exchService.url = 'https://mail.o365.bsnconnect.com/EWS/Exchange.asmx'

    If ($vNext) {
		$exchService.url = 'https://outlook.office365.com/EWS/Exchange.asmx'
    }

  	$exchInbox = New-Object Microsoft.Exchange.WebServices.Data.FolderId(`
  						[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox, $Account)

  	<# endregion Connection #>


  	<# region Get Inbox #>
  	Try {
  		$Inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($exchService,$exchInbox)
  		$SelectedFolder = $Inbox
  	}
  	Catch
  	{
  		throw $_
  	#Find the "External folder" where our messages will be copieolor red
  	}
  	<# endregion Get Inbox #>


  	<# region Get Specific Folder #>
  	If ($PSBoundParameters.ContainsKey('Folder')) {

  		foreach ( $root in $Folder.Split('\') ) {
  			$View = New-Object Microsoft.Exchange.WebServices.Data.FolderView(1,0)
  			$View.PropertySet = [Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly

  			$SearchFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo( `
  								[Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName, $root) 
  			$SelectedFolder = $SelectedFolder.FindFolders($SearchFilter, $View)
  			$SelectedFolder =  [Microsoft.Exchange.WebServices.Data.Folder]::Bind($exchService,$SelectedFolder.Id)
  		}
  	}
    <# endregion Get Specific Folder #>

  	$PropSet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet( `
        [Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly)

  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Subject)
  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Body)
  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::From)
  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ToRecipients)
  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::CcRecipients)
  	[Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::BccRecipients)

  	If ($AttachmentData) {
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Attachments) 
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::HasAttachments)
  	}

  	If ($BodyAsText) {
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::TextBody)
  	}

  	If ($TimeData) {
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeReceived)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeSent)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeCreated)
  	}

  	# If ($FlagsData) {
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Importance)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Categories)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Sensitivity)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Flag)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsAssociated)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsDraft)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsFromMe)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsReminderSet)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsResend)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsSubmitted)
  	#  [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::IsUnmodified)
  	# }

  	If ($ReceiptData) {
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsResponseRequested)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsReadReceiptRequested)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsDeliveryReceiptRequested)
  	}

  	If ($MetaData) {
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::InternetMessageHeaders)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::MimeContent)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsRead)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Size)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::InternetMessageId)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::ParentFolderId)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Culture)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DisplayCc)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DisplayTo)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::EffectiveRights)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::InReplyTo)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::ItemClass)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::LastModifiedName)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::LastModifiedTime)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::ReminderDueBy)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::RetentionDate)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::ReminderMinutesBeforeStart)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::UniqueBody)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ConversationIndex)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ConversationTopic)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ReplyTo)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::References)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ReceivedRepresenting)
  	 [Void] $PropSet.Add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ReceivedBy)
  	}

  	$View = New-Object Microsoft.Exchange.WebServices.Data.ItemView($PageSize, 0)
  }

  Process {
  	Do {

  		#Aggregate results
  		$results = $SelectedFolder.FindItems($View)
  		[Void] $exchService.LoadPropertiesForItems($results,$PropSet)

  		# Keep Going?
  		If ($AllEmails -or $Max -gt 0) {
  			$moreItems = $results.MoreAvailable
  		} Else {
  			$moreItems = $false
        $Max = -1
  		}

  		$View.Offset = $results.NextPageOffset
  		
      If ($Max -gt 0) {
        $Max = ($Max - $PageSize)
      }

      # End Keep Going
      Write-Output $results

  	} While ( ($moreItems -eq $true) -and ($Max -gt 0) )
  }

  End {}
}

New-Alias -Name inbox -Value Get-OutlookInbox
Export-ModuleMember -Function Get-OutlookInbox
Export-ModuleMember -Alias inbox

New-Alias -Name inboxEWS -Value Get-OutlookInboxEWS
Export-ModuleMember -Function Get-OutlookInboxEWS
Export-ModuleMember -Alias inboxEWS