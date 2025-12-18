function Update-CsAzGovAssignment {
    <#
.SYNOPSIS
    Updates an Azure governance assignment.

.DESCRIPTION
    This function updates a governance assignment associated with a Microsoft Defender
    for Cloud assessment. It retrieves the existing assignment, applies the requested
    changes (due date, owner, notifications, etc.), then submits the update via the ARM API.
    The function supports -WhatIf/-Confirm.

.PARAMETER azAPICallConf
    AzAPICall configuration hashtable.
    Does not accept pipeline input.

.PARAMETER resourceId
    ARM resource id where the assessment is attached.
    Accepts pipeline input by property name.

.PARAMETER AssessmentName
    Assessment name (resource name segment).
    Accepts pipeline input by property name.

.PARAMETER assignmentKey
    Governance assignment key.
    Accepts pipeline input by property name.

.PARAMETER RemediationDueDate
    Remediation due date. Optional.
    Does not accept pipeline input.

.PARAMETER IsGracePeriod
    Indicates whether a grace period is enabled. Optional.
    Does not accept pipeline input.

.PARAMETER OwnerEmailAddress
    Owner email address. Optional.
    Does not accept pipeline input.

.PARAMETER OwnerEmailNotification
    Enables/disables owner email notification. Optional.
    Does not accept pipeline input.

.PARAMETER ManagerEmailNotification
    Enables/disables manager email notification. Optional.
    Does not accept pipeline input.

.PARAMETER NotificationDayOfWeek
    Day of week for notifications. Optional.
    Valid values: Monday..Sunday.
    Does not accept pipeline input.

.EXAMPLE
    Update-CsAzGovAssignment -azAPICallConf $azAPICallConf -resourceId $resourceId -AssessmentName $AssessmentName -assignmentKey $assignmentKey -RemediationDueDate (Get-Date).AddDays(30)

    Sets the remediation due date to 30 days from now.

.EXAMPLE
    Update-CsAzGovAssignment -azAPICallConf $azAPICallConf -resourceId $resourceId -AssessmentName $AssessmentName -assignmentKey $assignmentKey -OwnerEmailAddress 'owner@contoso.com' -NotificationDayOfWeek 'Monday'

    Updates the owner and the notification day.

.OUTPUTS
    System.Object
    Returns the object emitted by AzAPICall for the PUT request.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$azAPICallConf,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$resourceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$AssessmentName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$assignmentKey,

        [Parameter(Mandatory = $false)]
        [datetime]$RemediationDueDate,

        [Parameter(Mandatory = $false)]
        [object]$IsGracePeriod,

        [Parameter(Mandatory = $false)]
        [string]$OwnerEmailAddress,

        [Parameter(Mandatory = $false)]
        [bool]$OwnerEmailNotification,

        [Parameter(Mandatory = $false)]
        [bool]$ManagerEmailNotification,

        [Parameter(Mandatory = $false)]
        [Validateset('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
        [string]$NotificationDayOfWeek

    )



    begin {
        # if the input is not from pipeline, then create a custom object with a single entry
        Write-OutputPadded "Update Azure Governance Assignment" -Type 'information' -isTitle -BlankLineBefore
    }

    process {

        Write-OutputPadded "Processing Azure Governance Assignment" -Type 'information' -IdentLevel 1 -BlankLineBefore
        Write-OutputPadded "Resource Id: $resourceId" -Type 'information' -IdentLevel 1
        Write-OutputPadded "Assessment Name: $AssessmentName" -Type 'Verbose' -IdentLevel 1
        Write-OutputPadded "Assignment Key: $assignmentKey" -Type 'Verbose' -IdentLevel 1

        $uri = "$($azAPICallConf.azAPIEndpointUrls.ARM)$resourceId/providers/microsoft.security/assessments/$AssessmentName/governanceAssignments/$assignmentKey/?api-version=2021-06-01"

        # get the existing assignment
        $govassessment = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method 'GET' -listenOn Content


        if ($RemediationDueDate) {
            # Update the remediationDueDate
            $RemediationDueDate = $RemediationDueDate.ToString('yyyy-MM-dd')
            Write-OutputPadded "New remediation Due Date: $RemediationDueDate" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.remediationDueDate = $RemediationDueDate
        }

        if ($IsGracePeriod) {
            # Update the isGracePeriod
            Write-OutputPadded "New isGracePeriod: $IsGracePeriod" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.isGracePeriod = $IsGracePeriod
        }

        if ($OwnerEmailAddress) {
            # Update the owner
            Write-OutputPadded "New Owner Email Address: $OwnerEmailAddress" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.owner = $OwnerEmailAddress
        }

        if ($OwnerEmailNotification) {
            # Update the disableOwnerEmailNotification
            Write-OutputPadded "New Owner Email Notification: $OwnerEmailNotification" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.disableOwnerEmailNotification = $OwnerEmailNotification
        }

        if ($ManagerEmailNotification) {
            # Update the disableManagerEmailNotification
            Write-OutputPadded "New Manager Email Notification: $ManagerEmailNotification" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.disableManagerEmailNotification = $ManagerEmailNotification
        }

        if ($NotificationDayOfWeek) {
            # Update the emailNotificationDayOfWeek
            Write-OutputPadded "New Email Notification Day Of Week: $NotificationDayOfWeek" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.emailNotificationDayOfWeek = $NotificationDayOfWeek
        }

        # Convert the updated object to JSON
        $jsonBody = $govassessment | ConvertTo-Json -Depth 10
        Write-OutputPadded "Updated JSON Body:" -Type 'data' -IdentLevel 1
        Write-OutputPadded "$jsonBody" -Type 'data' -IdentLevel 1

        # Update the assignment
        Write-OutputPadded "Updating Azure Governance Assignment" -Type 'debug' -IdentLevel 1


        try {
            # Check if the operation should proceed using ShouldProcess
            if ($PSCmdlet.ShouldProcess("$uri", "Update Azure Governance Assignment")) {
                AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method 'PUT' -body $jsonBody -listenOn Content
                Write-OutputPadded "Azure Governance Assignment Updated Successfully" -Type 'success' -IdentLevel 1
            }
        }
        # Catch block to handle any exceptions that occur during the update operation
        catch {
            Write-OutputPadded "Failed to update Azure Governance Assignment: $_" -Type 'error' -IdentLevel 1
        }
    }
}