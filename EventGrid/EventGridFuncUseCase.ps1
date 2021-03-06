#!/usr/local/bin/pwsh

<#
.SYNOPSIS
    This script will create an example of an Azure Event Grid to Azure 
    Function use case.
.DESCRIPTION
    This tutorial is in response to desires to automate ops processes on 
    resource deployments. I have minimal experience in Event Grid so this
    is very much exploratory... Buckle up, it may get bumpy.

    We will:
        1. Create a resource group
        2. Deploy function app template
        3. Create a resource group scoped event subscription
            a. Should be listening for Microssft.Resource.WriteSuccess
            b. Using the function app endpoint as webhook
        4. Deploy resource to resource group to trigger function execution.

    What will the function do?
    The function will extract a few key pieces of event data and send it to 
    the logs. The use case for this is ops automation - adding metric alert 
    rules to VMs as they are deployed, etc. Eventually, I'd like to write an
    Azure Function to add alerts by VM type with validation of available 
    metrics and any needed extensions installation and configuration.
.NOTES
    Date - 10 Jun 2018
    Author - Jacob Nosal
    Contact - eigenfunky@pm.me
#>

###############################################################################
# Global variables
###############################################################################

$ResourceGroupName = "EventGridFuncRG"
$Location = "westus2"
$AppName = "EventGridFuncDemo"
$VaultName = $AppName + "_Vault"
$SiteName = "https://$AppName.azurewebsites.net"
$Endpoint = "$SiteName/api/EventGridTest"
$TemplateUri = "https://raw.githubusercontent.com/eigenfunky/event-grid-func-demo/master/azuredeploy.json"
$TenantId = (Get-AzureRmContext).TenantId
$ServicePrincipalName = "powershell_rest-api"
$ServicePrincipalSecretName = "ServicePrincipalSecret"
$ServicePrincipalApplicationId = (Get-AzureRmADServicePrincipal -SearchString $ServicePrincipalName).ApplicationId

###############################################################################
# Functions
###############################################################################

###############################################################################
# Script
###############################################################################

# 1. Create a resource group.
$resourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
$resourceGroup

# 2. Deploy function app + key vault template
$params = @{ 
    ResourceGroupName = $ResourceGroupName 
    TemplateUri       = $TemplateUri
    appName           = $AppName
    vault_name        = $VaultName
}
New-AzureRmResourceGroupDeployment @params
# 
# Manually (ugggggh), navigate to the key vault that was just created and 
# add the function app service principal under IAM.
#
# Add parameters to app settings
$params = @{
    Name        = $AppName
    AppSettings = @{
        ServicePrincipalSecretName    = $ServicePrincipalSecretName
        ServicePrincipalName          = $ServicePrincipalName
        ServicePrincipalApplicationId = $ServicePrincipalApplicationId
        VaultName                     = $VaultName
        TenantId                      = $TenantId
    }
}
Set-AzureWebsite @params
#
# Manually (ugggggh), get a secret from the service principal through the portal. 
# Now, set that as a secret in the KeyVault that you just created. Name the 
# secret "ServicePrincipalSecret".
# 

# 3. Create a resource group scoped event subscription
#   a. Should be listening for Microssft.Resource.WriteSuccess
#   b. Using the function app endpoint as webhook
$params = @{
    Endpoint              = $Endpoint # need to get this value from above
    EventSubscriptionName = "subscription-network-resource"
    IncludedEventType     = "Microsoft.Resources.ResourceWriteSuccess"
}
New-AzureRmEventGridSubscription @params

# 4. Deploy resource to resource group to trigger function execution.
New-AzureRmResourceGroup -Name "$AppName-1" -Location $Location
Remove-AzureRmResourceGroup -Name "$AppName-1"

