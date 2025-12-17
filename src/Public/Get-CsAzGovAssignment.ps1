function Get-CsAzGovAssignment {
    <#
.SYNOPSIS
    Retrieves Azure Governance Assignments.

.DESCRIPTION
    This function retrieves the list of security assessments from Azure and stores the governance assignments.

.PARAMETER azAPICallConf
    A hashtable containing the configuration for the Azure API call.

.PARAMETER CsEnvironment
    The environment for which the function is being run.

.PARAMETER OverdueOnly
    A switch parameter that retrieves only the overdue governance assignments.

.EXAMPLE
    Get-CsAzGovAssignment -SubId "your-subscription-id" -azAPICallConf $yourConfig -CsEnvironment "your-environment"

.INPUTS
    String, Hashtable, String

.OUTPUTS
    ArrayList
    Returns an ArrayList of governance assignments.

.NOTES
    This function makes use of the AzAPICall function to make the API call to Azure.
#>

    param (

        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$azAPICallConf,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]$CsEnvironment,

        [Parameter()]
        [switch]$OverdueOnly
    )

    Write-OutputPadded "Governance Assignments" -IdentLevel 1 -isTitle -Type "Information"

    if ($OverdueOnly) {
        Write-OutputPadded "OverdueOnly Parameter set" -IdentLevel 1 -Type "Verbose"
        $completionStatus = "'Overdue'"
    }
    else {
        $completionStatus = "'OnTime', 'Overdue', 'Unassigned', 'Completed'"
    }

    # Get the Governance Assignments list
    $query = @"
     securityresources
        | where type =~ 'microsoft.security/assessments'
        | extend assessmentType = tostring(properties.metadata.assessmentType),
                assessmentId = tolower(id),
                assessmentName = tostring(name),
                statusCode = tostring(properties.status.code),
                source = trim(' ', tolower(tostring(properties.resourceDetails.Source))),
                resourceId = trim(' ', tolower(tostring(properties.resourceDetails.Id))),
                resourceName = tostring(properties.resourceDetails.ResourceName),
                resourceType = tolower(properties.resourceDetails.ResourceType),
                displayName = tostring(properties.displayName)
        | where assessmentType == 'BuiltIn'
        | extend environment = case(
            source in~ ('azure', 'onpremise'), 'Azure',
            source =~ 'aws', 'AWS',
            source =~ 'gcp', 'GCP',
            source =~ 'github', 'GitHub',
            source =~ 'gitlab', 'GitLab',
            source =~ 'azuredevops', 'AzureDevOps',
            dynamic(null)
        )
        | where environment in~ ('AWS', 'Azure', 'AzureDevOps', 'GCP', 'GitHub', 'GitLab')
        | join kind=leftouter (
            securityresources
            | where type == 'microsoft.security/assessments/governanceassignments'
            | extend dueDate = todatetime(properties.remediationDueDate),
                    isGracePeriod = tobool(properties.isGracePeriod),
                    owner = tostring(properties.owner),
                    disableOwnerEmailNotification = tostring(properties.governanceEmailNotification.disableOwnerEmailNotification),
                    disableManagerEmailNotification = tostring(properties.governanceEmailNotification.disableManagerEmailNotification),
                    emailNotificationDayOfWeek = tostring(properties.governanceEmailNotification.emailNotificationDayOfWeek),
                    governanceStatus = case(
                        isnull(todatetime(properties.remediationDueDate)), 'NoDueDate',
                        todatetime(properties.remediationDueDate) >= bin(now(), 1d), 'OnTime',
                        'Overdue'
                    ),
                    assessmentId = tolower(tostring(properties.assignedResourceId)),
                    assignmentKey = tostring(properties.assignmentKey)
            | project dueDate, isGracePeriod, owner, disableOwnerEmailNotification, disableManagerEmailNotification, governanceStatus, assessmentId, assignmentKey, emailNotificationDayOfWeek
        ) on assessmentId
        | extend completionStatus = case(
            governanceStatus == 'Overdue', 'Overdue',
            governanceStatus == 'OnTime', 'OnTime',
            statusCode == 'Unhealthy', 'Unassigned',
            'Completed'
        )
        | where completionStatus in~ ($completionStatus)
        | extend csEnvironment = '$CsEnvironment'
        | project csEnvironment, resourceId,assessmentName, assignmentKey,displayName, completionStatus, resourceType, resourceName, owner, dueDate, isGracePeriod, disableOwnerEmailNotification, disableManagerEmailNotification, emailNotificationDayOfWeek
        | order by completionStatus, displayName, owner
"@

    $payLoad = @"
    {
        "query": "$($query)"
    }
"@

    Write-OutputPadded "Query Payload:" -Type 'debug' -IdentLevel 1 -BlankLineBefore
    Write-OutputPadded "$payLoad" -Type 'data' -IdentLevel 1 -BlankLineBefore

    $uri = "$($azapicallconf.azAPIEndpointUrls.ARM)/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01"
    $GovAssignments = AzAPICall -AzAPICallConfiguration $azapiCallConf -uri $uri -body $payLoad -method 'POST' -listenOn Content

    return $GovAssignments
}
