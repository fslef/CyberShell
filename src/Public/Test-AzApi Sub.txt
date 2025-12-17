# $parameters4AzAPICallModule = @{
#     #SubscriptionId4AzContext = c6474c6e-4123-467f-9b35-524c5271a0db
#     #TenantId4AzContext = 2bf82e52-075e-44ab-8a51-1cd300acaa02
#     #DebugAzAPICall = $true
#     #WriteMethod = 'Output'
#     #DebugWriteMethod = 'Warning'
#     #SkipAzContextSubscriptionValidation = $false
# }

# $azAPICallConf = initAzAPICall @parameters4AzAPICallModule


function get-csSubscription {
    $startGetSubscriptions = Get-Date
    $currentTask = 'Getting all Subscriptions'
    Write-Host "$currentTask"
    $uri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)/subscriptions?api-version=2020-01-01"
    $method = 'GET'
    $requestAllSubscriptionsAPI = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method $method -currentTask $currentTask

Return $requestAllSubscriptionsAPI


}

$Sub = get-csSubscription

$Sub