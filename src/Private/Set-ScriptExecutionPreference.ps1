function Set-ScriptExecutionPreference {
    <#
.SYNOPSIS
   Sets the script execution preference.

.DESCRIPTION
   The Set-ScriptExecutionPreference function sets the script execution preference. It supports three levels of verbosity: "Information", "Verbose", and "Debug".

.PARAMETER ExecutionPreference
   The execution preference to be set. It can be one of the following: "Information", "Verbose", "Debug". Default is "Information".

.EXAMPLE
   Set-ScriptExecutionPreference -ExecutionPreference "Verbose"
   Sets the script execution preference to "Verbose". This will enable verbose logging.

.EXAMPLE
   Set-ScriptExecutionPreference -ExecutionPreference "Debug"
   Sets the script execution preference to "Debug". This will enable verbose and debug logging.

.EXAMPLE
   Set-ScriptExecutionPreference
   Sets the script execution preference to the default "Information". This will disable verbose and debug logging.

.NOTES
   The function changes the script scope variables $script:VerbosePreference and $script:DebugPreference.
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
