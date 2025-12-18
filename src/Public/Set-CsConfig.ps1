Function Set-CsConfig {
    <#
.SYNOPSIS
    Creates or updates the CyberShell configuration file.

.DESCRIPTION
    This function creates a JSONC configuration file under $HOME/.cybershell.
    If the file already exists, you can either overwrite it (with a backup) using
    -Overwrite, or open it using -Edit. If the file exists and neither option is
    provided, the function returns an error.

    This function supports -WhatIf/-Confirm (SupportsShouldProcess).

.PARAMETER Edit
    When specified, opens the configuration file in Visual Studio Code.
    If the file does not exist, it is created before opening.
    Does not accept pipeline input.

.PARAMETER Overwrite
    When specified, creates a backup and overwrites the configuration file if it exists.
    Does not accept pipeline input.

.EXAMPLE
    Set-CsConfig

    Creates the default configuration file if missing.

.EXAMPLE
    Set-CsConfig -Edit

    Creates (if needed) and opens the file in VS Code.

.EXAMPLE
    Set-CsConfig -Overwrite -Edit

    Backs up the existing file, recreates it, then opens it.

.OUTPUTS
    None

.NOTES
    The generated file is JSONC (JSON with comments) written via Set-Content.
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
