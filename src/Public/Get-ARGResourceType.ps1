function Get-ARGResourceType {
    <#
.SYNOPSIS
    Returns a profile per Azure resource type.

.DESCRIPTION
    This function queries Azure Resource Graph to retrieve the deployed resource
    count per resource type (for example Microsoft.Web/sites), then enriches the
    result with API versions published by Azure Resource Providers.

.PARAMETER SubscriptionId
    Subscription id(s) to query.
    If not specified, the query runs at tenant scope.
    Does not accept pipeline input.

.EXAMPLE
    Get-ARGResourceType

    Returns the tenant resource types with counts and the latest GA/Preview API versions.

.EXAMPLE
    Get-ARGResourceType -SubscriptionId '00000000-0000-0000-0000-000000000000'

    Queries a specific subscription (or multiple subscriptions).

.OUTPUTS
    PSCustomObject
    Objects with ResourceType, ResourceCount, LatestGAApiVersion, LatestPreviewApiVersion,
    and SupportsPreviewApi.
    #>
    [CmdletBinding()]
    param (
        [string[]]$SubscriptionId
    )

    $query = @"
Resources
| summarize ResourceCount = count() by type
| order by type asc
"@

    Write-Verbose "Running Azure Resource Graph query..."
    if ($SubscriptionId) {
        $argResults = Search-AzGraph -Query $query -Subscription $SubscriptionId
    }
    else {
        $argResults = Search-AzGraph -Query $query -UseTenantScope
    }

    Write-Verbose "Retrieving provider API versions..."
    $providerInfo = Get-ProviderApiVersions

    if (-not $providerInfo) {
        Write-Warning "Failed to retrieve provider information. Initializing an empty cache."
        $providerInfo = @{}
    }

    Write-Verbose "Enriching results..."
    $results = foreach ($item in $argResults) {
        $resourceType = $item.type
        $apiInfo = $providerInfo[$resourceType]

        if (-not $apiInfo) {
            Write-Warning "No provider information found for: $resourceType"
            $apiInfo = [PSCustomObject]@{
                LatestGAApiVersion      = $null
                LatestPreviewApiVersion = $null
            }
        }

        [PSCustomObject]@{
            ResourceType            = $resourceType
            ResourceCount           = $item.ResourceCount
            LatestGAApiVersion      = $apiInfo.LatestGAApiVersion
            LatestPreviewApiVersion = $apiInfo.LatestPreviewApiVersion
            SupportsPreviewApi      = ($null -ne $apiInfo.LatestPreviewApiVersion)
        }
    }

    return $results
}