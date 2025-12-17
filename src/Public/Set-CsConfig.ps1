Function Set-CsConfig {
    <#
.SYNOPSIS
    Creates or updates a CyberShell configuration file.

.DESCRIPTION
    The Set-CsConfig function creates a new CyberShell configuration file in the .CyberShell directory in the user's home directory. If the file already exists, the function's behavior depends on the parameters provided:
    - If the -Overwrite switch is provided, the function will create a backup of the existing file and then overwrite it.
    - If the -Edit switch is provided, the function will open the existing file in Visual Studio Code.
    - If neither switch is provided and the file exists, the function will throw an error.

.PARAMETER Edit
    If this switch is provided, the function will open the configuration file in Visual Studio Code after creating it. If the file already exists, the function will open the existing file instead of throwing an error.

.PARAMETER Overwrite
    If this switch is provided, the function will overwrite the existing configuration file after creating a backup. The backup file will be named "CyberShell-Config.bak.jsonc", or "CyberShell-Config.bakX.jsonc" if a backup file already exists, where X is a number.

.EXAMPLE
    Set-CsConfig -Edit -Overwrite

    This command creates a new CyberShell configuration file in the .CyberShell directory in the user's home directory, overwrites the existing file if it exists (after creating a backup), and opens the new or existing file in Visual Studio Code.

.INPUTS
    None. You cannot pipe objects to Set-CsConfig.

.OUTPUTS
    None. This function does not return any output.

.NOTES
    The configuration file is a JSONC file, which is a JSON file that supports comments. The default configuration file created by this function includes comments to explain each setting.
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [switch]$Edit,
        [switch]$Overwrite
    )

    $folderPath = Join-Path -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)) -ChildPath ".cybershell"
    if (-not (Test-Path -Path $folderPath)) {
        if ($PSCmdlet.ShouldProcess("$folderPath", "Create directory")) {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
        }
    }

    $filePath = Join-Path -Path $folderPath -ChildPath "CyberShell-Config.jsonc"
    $backupPath = Join-Path -Path $folderPath -ChildPath "CyberShell-Config.bak.jsonc"

    if (Test-Path -Path $filePath) {
        if ($Overwrite) {
            if ($PSCmdlet.ShouldProcess("$filePath", "Copy file to $backupPath")) {
                Copy-Item -Path $filePath -Destination $backupPath -Force
            }
        }
        else {
            if (-not $Edit) {
                Write-Error -Message "CyberShell-Config.jsonc already exists in the .CyberShell directory. Use -Overwrite to overwrite it."
                return
            }
        }
    }

    $defaultConfig = @"
{
    "Settings" : [],
    "CyberShellEnvironments" : [
        {
            // The name of the environment
            "Name" : "<environmentName>",
            // The type of the environment, can be AzureCloud, AzureChinaCloud, AzureUSGovernment, AzureGermanCloud
            "Type" : "AzureCloud",
            // The tenant id of the environment
            "TenantId" : "<tenantId>",
            // The scopes of the environment
            // for subscription, it should be /subscriptions/{subscription-id}
            // for management group, it should be /providers/Microsoft.Management/managementGroups/{management-group-id}
            "Scopes" : [
                "/subscriptions/<subscriptionId>"
            ]
        }
    ]
}
"@
    if ($PSCmdlet.ShouldProcess("$filePath", "Set content")) {
        $defaultConfig | Set-Content -Path $filePath
    }

    if ($Edit) {
        if ($PSCmdlet.ShouldProcess("$filePath", "Open in VS Code")) {
            Start-Process -FilePath "code" -ArgumentList $filePath
        }
    }
}
