function Set-AzApiCallContext {
    <#
.SYNOPSIS
    Initializes AzAPICall context and a bearer token.

.DESCRIPTION
    This function creates an AzAPICall configuration (initAzAPICall) for a given
    subscription and tenant, then generates a bearer token for a target endpoint
    (ARM, MicrosoftGraph, etc.). It supports -WhatIf/-Confirm via ShouldProcess.

.PARAMETER SubscriptionId
    Azure subscription id.
    Does not accept pipeline input.

.PARAMETER TenantId
    Azure tenant id.
    Does not accept pipeline input.

.PARAMETER targetEndpoint
    Target endpoint for which to create a token.
    Valid values: MicrosoftGraph, ARM, KeyVault, LogAnalytics, MonitorIngest.
    Does not accept pipeline input.

.PARAMETER DebugAzAPICall
    Enables AzAPICall debug mode.
    Default: False.

.PARAMETER WriteMethod
    Output method used by AzAPICall (for example Output).
    Default: Output.

.PARAMETER DebugWriteMethod
    Debug output method used by AzAPICall (for example Warning).
    Default: Warning.

.PARAMETER SkipAzContextSubscriptionValidation
    When True, skips AzContext subscription validation.
    Default: True.

.EXAMPLE
    Set-AzApiCallContext -SubscriptionId '<subId>' -TenantId '<tenantId>' -targetEndpoint ARM -WhatIf

    Shows what would happen without executing.

.OUTPUTS
    None
    Initializes AzAPICall and writes informational messages.
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('MicrosoftGraph', 'ARM', 'KeyVault', 'LogAnalytics', 'MonitorIngest')]
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