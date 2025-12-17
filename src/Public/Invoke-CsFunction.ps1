function Invoke-CsFunction {
    <#
.SYNOPSIS
   Invokes a CyberShell function across multiple environments.

.DESCRIPTION
   The Invoke-CsFunction function invokes a specified CyberShell function across multiple environments.
   The function name, parameters, and target environments can be specified.

.PARAMETER CsFunctionName
   The name of the CyberShell function to invoke. This should include the '-Cs' prefix.

.PARAMETER CsFunctionParams
   A hashtable of parameters to pass to the CyberShell function.

.PARAMETER CsEnvironmentName
   The name of a specific environment to target. If not specified, the function is invoked across all environments.

.PARAMETER CsEnvironmentType
   The type of environment to target. If not specified, the function is invoked across all types of environments.

.EXAMPLE
   $params = @{ "ResourceGroupName" = "MyResourceGroup"; "Name" = "MyVM" }
   Invoke-CsFunction -CsFunctionName "Get-CsVM" -CsFunctionParams $params -CsEnvironmentName "Prod"

.INPUTS
   String, Hashtable, String, String

.OUTPUTS
   Varies based on the CyberShell function invoked.

.NOTES
   The CyberShell data must be loaded (using Import-CsEnvironment) before this function can be used.
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
