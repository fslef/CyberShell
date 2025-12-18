function Set-ScriptExecutionPreference {
    <#
.SYNOPSIS
   Sets module Verbose/Debug preferences.

.DESCRIPTION
   This function configures $script:VerbosePreference and $script:DebugPreference
   to control Verbose, Debug, and Data output across the module.

.PARAMETER ExecutionPreference
   Desired verbosity level.
   Valid values: Information, Verbose, Debug.
   Default: Information.
   Does not accept pipeline input.

.EXAMPLE
   Set-ScriptExecutionPreference

   Resets to Information mode (no Verbose/Debug output).

.EXAMPLE
   Set-ScriptExecutionPreference -ExecutionPreference Verbose

   Enables Verbose output and disables Debug.

.EXAMPLE
   Set-ScriptExecutionPreference -ExecutionPreference Debug

   Enables Verbose and Debug output.

.OUTPUTS
   None

.NOTES
   Modifies script-scope variables; does not use ShouldProcess.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "This function only changes script scope variables")]
    [CmdletBinding()]
    param (
        [ValidateSet("Information", "Verbose", "Debug")]
        [string]$ExecutionPreference = "Information"
    )

    if ($ExecutionPreference -eq "Verbose" -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) {
        $script:VerbosePreference = "Continue"
        $script:DebugPreference = "SilentlyContinue"
    }
    elseif ($ExecutionPreference -eq "Debug" -or $PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent -eq $true) {
        $script:VerbosePreference = "Continue"
        $script:DebugPreference = "Continue"
    }
    else {
        $script:VerbosePreference = "SilentlyContinue"
        $script:DebugPreference = "SilentlyContinue"
    }

}
