# $parameters4AzAPICallModule = @{
#     #SubscriptionId4AzContext = c6474c6e-4123-467f-9b35-524c5271a0db
#     #TenantId4AzContext = 2bf82e52-075e-44ab-8a51-1cd300acaa02
#     #DebugAzAPICall = $true
#     #WriteMethod = 'Output'
#     #DebugWriteMethod = 'Warning'
#     #SkipAzContextSubscriptionValidation = $false
# }

# $azAPICallConf = initAzAPICall @parameters4AzAPICallModule


function Get-UniqueResourceTypesWithExampleIdsOLD {
    param (
        [Parameter(Mandatory = $true)]
        [object]$azAPICallConf,

        [Parameter(Mandatory = $true)]
        [string]$bearerToken
    )

    $start = Get-Date
    Write-Host "Starting to list all unique resource types with an example resource ID..."

    # Define the query to list all unique resource types along with an example resource ID
    $queries = @(
        [PSCustomObject]@{
            queryName = 'UniqueResourceTypesWithExamples'
            query     = "Resources | summarize exampleResourceId=min(id) by type | order by type asc"
            intent    = 'List unique resource types with an example ID'
        }
    )

    # Iterate over each query
    foreach ($queryDetail in $queries) {
        $uri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01"
        $headers = @{
            "Authorization" = "Bearer $bearerToken"
            "Content-Type"  = "application/json"
        }
        $body = @{
            query = $queryDetail.query
        } | ConvertTo-Json

        Write-Host "Executing query for $($queryDetail.intent)..."
        $response = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method "POST" -body $body -headers $headers -listenOn "Content"

        if ($response.count -gt 0) {
            Write-Host "Found $($response.count) entries for $($queryDetail.queryName)."
            foreach ($entry in $response) {
                Write-Host "Resource Type: $($entry.type), Example Resource ID: $($entry.exampleResourceId)"
            }
        }
        else {
            Write-Host "No entries found for $($queryDetail.queryName)."
        }
    }

    $end = Get-Date
    Write-Host "Completed listing. Duration: $((New-TimeSpan -Start $start -End $end).TotalMinutes) minutes."
}

function Get-UniqueResourceTypesWithExampleIds {
    $currentTask = 'Get Resource Types in subscription'
    Write-Host $currentTask
    $uri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01"
    $method = 'POST'
    $resourcesTypesResult = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method $method -currentTask $currentTask

    $resourcesTypesResult

}

# $azAPICallConf = initAzAPICall
# $bearerToken = createBearerToken -AzAPICallConfiguration $azapicallconf -targetEndPoint 'ARM'
# $Resultat = Get-UniqueResourceTypesWithExamples -azAPICallConf $azAPICallConf -bearerToken $bearerToken
# $Resultat

Get-UniqueResourceTypesWithExampleIds
