function Import-CsEnvironment {
    <#
.SYNOPSIS
    Imports CyberShell configuration from a JSONC file.

.DESCRIPTION
    This function loads a JSONC configuration file (practically JSON) and exposes
    CyberShell environments and settings. If no path is provided, it defaults to
    $HOME/.cybershell/CyberShell-Config.jsonc (or the CYBERSHELL_CONFIG environment
    variable when set).

.PARAMETER JsonPath
    Path to the JSONC file to import.
    Default: $HOME/.cybershell/CyberShell-Config.jsonc.
    Does not accept pipeline input.

.EXAMPLE
    Import-CsEnvironment

    Imports configuration from the default location.

.EXAMPLE
    Import-CsEnvironment -JsonPath "$HOME/.cybershell/CyberShell-Config.jsonc"

    Imports configuration from an explicit path.

.OUTPUTS
    None
    This function stores imported data in scope variables (CsData) rather than returning it.

.NOTES
    Imported data is stored in $script:CsData (module scope) and also copied to
    $global:CsData for compatibility.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification = 'Global variable used for $CsData.')]
    [CmdletBinding()]
    param (
        [string]$JsonPath = $null
    )

    Write-OutputPadded "Importing CyberShell Environment" -isTitle -Type "Information"

    # If a JSON path is explicitly specified, use it
    # If not, check for the CUBERSHELL_CONFIG environment variable
    # If the environment variable is not set, default to the CyberShell-Config.jsonc file
    # in the .cybershell directory of the user's home directory
    if (-not [string]::IsNullOrEmpty($JsonPath)) {
        Write-OutputPadded "Config file explicitly specified in Cmdlet" -IdentLevel 1 -Type "Debug" -BlankLineBefore

    }
    elseif ($env:CYBERSHELL_CONFIG) {
        $JsonPath = $env:CYBERSHELL_CONFIG
        Write-OutputPadded "Using JsonPath from CYBERSHELL_CONFIG environment variable" -IdentLevel 1 -Type "Debug"
    }
    else {
        $JsonFolder = Join-Path $HOME ".cybershell"
        $JsonPath = Join-Path $JsonFolder "CyberShell-Config.jsonc"
        Write-OutputPadded "Using default JsonPath: $JsonPath" -IdentLevel 1 -Type "Debug"
    }
    Write-OutputPadded "$JsonPath" -IdentLevel 1 -Type "Debug"

    Write-OutputPadded "Importing configuration from Json" -IdentLevel 1 -Type "Debug" -BlankLineBefore

    # Verifying the file exists
    if (-Not (Test-Path $JsonPath)) {
        Write-Error "The specified JSONC file does not exist at the path: $JsonPath"
        return
    }

    # Loading and parsing the JSON content
    $jsonContent = Get-Content -Path $JsonPath -Raw -ErrorAction Stop
    try {
        # Convert JSON content to a hashtable for structured access
        [hashtable]$rawData = $jsonContent | ConvertFrom-Json -AsHashtable
        Write-OutputPadded "CyberShell environments and configuration successfully imported." -IdentLevel 1 -Type "Success"
    }
    catch {
        Write-OutputPadded "Failed to import CyberShell environments and configuration from JSON: $_" -IdentLevel 1 -Type "Error"
    }

    # Structured global data storage
    $script:CsData = @{
        "Environments" = $rawData["CyberShellEnvironments"];
        "Settings"     = $rawData["Settings"];
    }

    # Backward compatibility
    $global:CsData = $script:CsData

    # Debug output for imported data
    Write-OutputPadded "Environment loaded:" -IdentLevel 1 -Type "Debug" -BlankLineBefore
    Write-OutputPadded "Environment: $($script:CsData.Environments | ConvertTo-Json)" -IdentLevel 1 -Type "Data"

    # debug output for settings

    # if settings exist, output them
    if ($script:CsData.Settings) {
        Write-OutputPadded "Settings loaded:" -IdentLevel 1 -Type "Debug" -BlankLineBefore
        Write-OutputPadded "Settings: $($script:CsData.Settings | ConvertTo-Json) " -IdentLevel 1 -Type "Data"
    }
    else {
        Write-OutputPadded "No settings found in the config file." -IdentLevel 1 -Type "Debug"
    }


    # CSData.settings.ExecutionPreference exist then set the script execution preference
    if ($script:CsData.Settings.ExecutionPreference) {
        Set-ScriptExecutionPreference -ExecutionPreference $script:CsData.Settings.ExecutionPreference
        Write-OutputPadded "Script execution preference set to $($script:CsData.Settings.ExecutionPreference)" -IdentLevel 1 -Type "Debug"
        Write-OutputPadded " " -Type "Debug"
    }

    If ($script:CsData.Settings.ExecutionPreference -eq "Debug") {
        Write-OutputPadded "Debug Informations:" -IdentLevel 1 -Type "Debug"
    }
    else {
        Write-OutputPadded "Debug and verbose Informations:" -IdentLevel 1 -Type "Debug"
    }

    Write-OutputPadded "JsonPath: $JsonPath" -IdentLevel 2 -Type "Debug"

    Write-OutputPadded "Imported CyberShell Data:" -IdentLevel 2 -Type "Debug" -BlankLineBefore
    Write-OutputPadded "$(ConvertTo-Json $script:CsData -Depth 20)" -IdentLevel 2 -Type "Data"

}
