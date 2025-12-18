function Get-ProviderApiVersions {
    <#
.SYNOPSIS
    Gets the latest GA and Preview API versions per Azure resource type.

.DESCRIPTION
    This function queries Azure Resource Providers and builds a cache keyed by the
    canonical resource type (for example Microsoft.Web/sites).

    For each resource type, it returns:
    - LatestGAApiVersion: the latest stable API version (format YYYY-MM-DD)
    - LatestPreviewApiVersion: the latest preview API version (suffix -preview)

    Versions that are neither GA nor preview (for example -alpha) are ignored.

.EXAMPLE
    Get-ProviderApiVersions

    Returns a cache for all discovered resource types.

.EXAMPLE
    $cache = Get-ProviderApiVersions -Verbose
    $cache['Microsoft.ManagedIdentity/Identities']

    Returns the latest GA/Preview versions for a given resource type.

.OUTPUTS
    System.Collections.Hashtable
    Keys are strings "<ProviderNamespace>/<ResourceTypeName>".
    Values are PSCustomObject with LatestGAApiVersion and LatestPreviewApiVersion.
    #>
    [CmdletBinding()]
    param()

    $providerCache = @{}

    Write-Verbose "Retrieving Azure Resource Providers..."
    $providers = Get-AzResourceProvider -ListAvailable

    foreach ($provider in $providers) {
        foreach ($resourceType in $provider.ResourceTypes) {
            $fullTypeName = "$($provider.ProviderNamespace)/$($resourceType.ResourceTypeName)"

            $gaVersions = $resourceType.ApiVersions | Where-Object { $_ -match '^\d{4}-\d{2}-\d{2}$' }
            $previewVersions = $resourceType.ApiVersions | Where-Object { $_ -match '-preview$' }

            $providerCache[$fullTypeName] = [PSCustomObject]@{
                LatestGAApiVersion      = ($gaVersions | Sort-Object -Descending | Select-Object -First 1)
                LatestPreviewApiVersion = ($previewVersions | Sort-Object -Descending | Select-Object -First 1)
            }
        }
    }

    return $providerCache
}