function Update-CsAzGovAssignment {
    <#
.SYNOPSIS
Updates an Azure Governance Assignment.

.DESCRIPTION
The Update-CsAzGovAssignment function updates an Azure Governance Assignment with the provided parameters.

.PARAMETER azAPICallConf
A hashtable containing the configuration for the Azure API call.

.PARAMETER resourceId
The unique identifier of the resource.

.PARAMETER AssessmentName
The name of the assessment.

.PARAMETER assignmentKey
The key of the assignment.

.PARAMETER RemediationDueDate
The due date for remediation. This is optional.

.PARAMETER IsGracePeriod
Indicates whether there is a grace period. This is optional.

.PARAMETER OwnerEmailAddress
The email address of the owner. This is optional.

.PARAMETER OwnerEmailNotification
Indicates whether the owner will receive email notifications. This is optional.

.PARAMETER ManagerEmailNotification
Indicates whether the manager will receive email notifications. This is optional.

.PARAMETER NotificationDayOfWeek
The day of the week when notifications will be sent. This is optional and must be one of 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'.

.EXAMPLE
$azAPICallConf = @{...}
Update-CsAzGovAssignment -azAPICallConf $azAPICallConf -resourceId "resourceId" -AssessmentName "AssessmentName" -assignmentKey "assignmentKey"

This example updates an Azure Governance Assignment with the provided parameters.
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