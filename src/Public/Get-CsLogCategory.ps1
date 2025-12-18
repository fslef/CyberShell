function Get-CsLogCategory {
    <#
.SYNOPSIS
    Returns log/metric categories per resource type.

.DESCRIPTION
    This function builds a list of resource types present in the current subscription
    using Get-AzResource, then materializes LogCategoryObj instances. It can optionally
    filter to resource types that expose log categories only or metric categories only.

.PARAMETER LogOnly
    When specified, returns only resource types with at least one log category.
    Cannot be used with MetricOnly.

.PARAMETER MetricOnly
    When specified, returns only resource types with at least one metric category.
    Cannot be used with LogOnly.

.EXAMPLE
    Get-CsLogCategory

    Displays resource types and their available log/metric categories.

.EXAMPLE
    Get-CsLogCategory -LogOnly

    Displays only resource types that have log categories.

.EXAMPLE
    Get-CsLogCategory -MetricOnly

    Displays only resource types that have metric categories.

.OUTPUTS
    System.Object
    Emits formatting data (Format-Table) intended for console display.

.NOTES
    Make sure you are connected to Azure (Connect-AzAccount) and the correct subscription
    is selected (Set-AzContext) before running this function.
      #>

    param (
        [Parameter(Mandatory = $false)]
        [switch]$LogOnly,

        [Parameter(Mandatory = $false)]
        [switch]$MetricOnly
    )

    if ($LogOnly -and $MetricOnly) {
        throw "The LogOnly and MetricOnly parameters cannot be used at the same time."
    }

    [ListOfLogCategory]::Clear()

    $resources = Get-AzResource | Select-Object SubscriptionId, ResourceType -Unique
    $total = $resources.Count
    $current = 0

    $resources | ForEach-Object {
        $current++
        Write-Progress -Activity "Processing resources" -Status "Resource $current of $total $($_.ResourceTypeName)" -PercentComplete ($current / $total * 100)

        $Resource = [LogCategoryObj]::new(@{
                ContainerId      = $_.SubscriptionId
                ResourceTypeName = $_.ResourceType
                SourceType       = 'Az'
            })
        [ListOfLogCategory]::Add($Resource)
    }

    if ($LogOnly) {
        $ListOfLogCategory = [ListOfLogCategory]::FindAll({ param($r) $r.LogCategory.Length -gt 0 })
    }
    elseif ($MetricOnly) {
        $ListOfLogCategory = [ListOfLogCategory]::FindAll({ param($r) $r.MetricCategory.Length -gt 0 })
    }
    else {
        $ListOfLogCategory = [ListOfLogCategory]::LogCategoryObj
    }

    Write-Output $ListOfLogCategory | Format-Table -AutoSize
}