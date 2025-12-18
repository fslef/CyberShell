function Invoke-CsFunction {
    <#
.SYNOPSIS
    Invokes a CyberShell function across one or more environments.

.DESCRIPTION
    This function invokes a generic CyberShell command (for example Get-CsSomething)
    across environments declared in the CyberShell configuration.

    The "-Cs" prefix is replaced with an environment-specific prefix (for example
    Az for AzureCloud). The configuration must be loaded first using Import-CsEnvironment.

.PARAMETER CsFunctionName
    Name of the CyberShell function to invoke, including the "-Cs" prefix
    (for example Get-CsAzGovAssignment).
    Does not accept pipeline input.

.PARAMETER CsFunctionParams
    Hashtable of parameters to pass to the target cmdlet.
    Does not accept pipeline input.

.PARAMETER CsEnvironmentName
    Name of a specific environment to target. If omitted, targets all environments.
    Does not accept pipeline input.

.PARAMETER CsEnvironmentType
    Type of environment to target (for example AzureCloud, AWS, GCP). If omitted,
    targets all types.
    Does not accept pipeline input.

.EXAMPLE
    Import-CsEnvironment
    $params = @{ azAPICallConf = $azAPICallConf; CsEnvironment = 'Azure' }
    Invoke-CsFunction -CsFunctionName 'Get-CsAzGovAssignment' -CsFunctionParams $params -CsEnvironmentType 'AzureCloud'

    Invokes the command for all AzureCloud environments.

.OUTPUTS
    System.Object
    Output depends on the invoked function.

.NOTES
    Requires Import-CsEnvironment to have been executed (initializes $script:CsData).
#>
    [CmdletBinding()]
    param (
        [string]$CsFunctionName, # Complete cmdlet name including '-Cs'
        [hashtable]$CsFunctionParams, # Parameters to pass to the target cmdlet
        [string]$CsEnvironmentName, # Name of a specific environment to target (optional)
        [string]$CsEnvironmentType # Type of environment to target (optional)
    )

    # Check if the CyberShell data is loaded
    if ($null -eq $script:CsData) {
        Write-Error "CyberShell data is not loaded. Please run Import-CsEnvironment first."
        return
    }

    # Map environment types to their respective command prefixes
    $commandPrefixMap = @{
        "AzureCloud"        = "Az"
        "AzureChinaCloud"   = "Az"
        "AzureUSGovernment" = "Az"
        "AzureGermanCloud"  = "Az"
        "AWS"               = "AWS"
        "GCP"               = "GCP"
    }

    # Access environments from the global data structure
    $environments = $script:CsData["Environments"]

    foreach ($env in $environments) {
        # Skip environments that do not match the specified name or type, if provided
        if (-not [string]::IsNullOrEmpty($CsEnvironmentName) -and $env.Name -ne $CsEnvironmentName) {
            continue
        }
        if (-not [string]::IsNullOrEmpty($CsEnvironmentType) -and $env.Type -ne $CsEnvironmentType) {
            continue
        }

        # Find the command prefix based on the environment type
        $prefix = $commandPrefixMap[$env.Type]
        if ($null -ne $prefix) {
            # Construct the target cmdlet name by replacing '-Cs' with the correct prefix
            $targetCmdletName = $CsFunctionName -replace '-Cs', "-$prefix"

            # Check if the target cmdlet exists before attempting to invoke it
            if (Get-Command $targetCmdletName -ErrorAction SilentlyContinue) {
                & $targetCmdletName @CsFunctionParams
            }
            else {
                Write-Warning "The cmdlet $targetCmdletName does not exist."
            }
        }
        else {
            Write-Warning "No prefix found for the environment type $($env.Type)."
        }
    }
}
