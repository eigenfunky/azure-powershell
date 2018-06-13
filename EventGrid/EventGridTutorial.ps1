#!/usr/local/bin/pwsh

<#
.DESCRIPTION
.NOTES
    Date - 6 Jun 2018
    Author - Jacob Nosal
    Contact - eigenfunky@pm.me
#>

# Set global variables
$resourceGroupName = "grid-demo"
$location = "westus2"
$sitename = "eigenviewer"
$endpoint = "https://$sitename.azurewebsites.net/api/updates"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# deploy the app for event viewing purposes.
$params = @{ 
    ResourceGroupName = $resourceGroupName 
    TemplateUri       = "https://raw.githubusercontent.com/eigenfunky/azure-event-grid-viewer/master/azuredeploy.json" 
    siteName          = $sitename 
    hostingPlanName   = "viewerhost" 
}
New-AzureRmResourceGroupDeployment @params

# Subscribe to subscription wide event types
$params = @{
    Endpoint              = $endpoint
    EventSubscriptionName = "subscription-network-resource"
    IncludedEventType     = "Microsoft.Resources.ResourceWriteSuccess"
}
New-AzureRmEventGridSubscription @params

# Navigate to the $endpoint URL. Once the page has rendered, go into the Azure portal and deploy a resource.
# You should see the event if the deployment is successful.
$serviceSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "svc" -AddressPrefix "10.0.1.0/24"
$mgmtSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "mgmt" -AddressPrefix "10.0.2.0/24"
$params = @{
    Name = "event-grid-vnet"
    ResourceGroupName = $resourceGroupName
    Location = $location
    AddressPrefix = "10.0.0.0/16"
    Subnet = $serviceSubnet, $mgmtSubnet
}
New-AzureRmVirtualNetwork @params

# Tear down resource group when complete
Remove-AzureRmResourceGroup -Name $resourceGroupName