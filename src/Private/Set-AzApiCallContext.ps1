function Set-AzApiCallContext {
    <#
.SYNOPSIS
Sets the context for Azure API calls.

.DESCRIPTION
The Set-AzApiCallContext function sets up the context for Azure API calls. It takes in parameters like SubscriptionId, TenantId, targetEndpoint, and others. It then initializes the AzAPICall and creates a bearer token for the specified target endpoint.

.PARAMETER SubscriptionId
The subscription ID for the Azure account.

.PARAMETER TenantId
The tenant ID for the Azure account.

.PARAMETER targetEndpoint
The target endpoint for the Azure API call. It must be one of 'MicrosoftGraph', 'ARM', 'KeyVault', 'LogAnalytics', 'MonitorIngest' and must match the specified pattern.

.PARAMETER DebugAzAPICall
A boolean value indicating whether to debug the Azure API call.

.PARAMETER WriteMethod
The method to write the output.

.PARAMETER DebugWriteMethod
The method to write the debug output.

.PARAMETER SkipAzContextSubscriptionValidation
A boolean value indicating whether to skip Azure context subscription validation.

.EXAMPLE
Set-AzApiCallContext -SubscriptionId "sub-id" -TenantId "tenant-id" -targetEndpoint "https://example.blob.core.windows.net"

This example shows how to set the Azure API call context.
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('MicrosoftGraph', 'ARM', 'KeyVault', 'LogAnalytics', 'MonitorIngest')]
        [ValidatePattern('^https://[a-z0-9]+\.blob\.core\.windows\.net$|^https://[a-z0-9]+\.blob\.storage\.azure\.net$')]
        [string]$targetEndpoint,

        [bool]$DebugAzAPICall = $False,

        [string]$WriteMethod = 'Output',

        [string]$DebugWriteMethod = 'Warning',

        [bool]$SkipAzContextSubscriptionValidation = $true


    )

    Write-Output "Setting up parameters for AzAPICallModule."

    $parameters4AzAPICallModule = @{
        SubscriptionId4AzContext            = $SubscriptionId
        TenantId4AzContext                  = $TenantId
        DebugAzAPICall                      = $DebugAzAPICall
        WriteMethod                         = $WriteMethod
        DebugWriteMethod                    = $DebugWriteMethod
        SkipAzContextSubscriptionValidation = $SkipAzContextSubscriptionValidation
    }

    if ($PSCmdlet.ShouldProcess("AzAPICall", "Initialize")) {
        Write-Output "Initializing AzAPICall."
        $azAPICallConf = initAzAPICall @parameters4AzAPICallModule
        Write-Information "Creating bearer token..."
        createBearerToken -AzAPICallConfiguration $azapicallconf -targetEndPoint $targetEndpoint
        Write-Information 'here is the token:' $azAPICallConf['htBearerAccessToken'].$targetEndpoint
    }
    else {
        Write-Output "Initialization of AzAPICall was cancelled by the user."
    }
}