function Set-ServicePrincipalAppSettings {
    <#
    .SYNOPSIS
        This module loads the application id of a service principal to a websites app settings.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $AppName,
        [Parameter(Mandatory = $true)]
        [string]
        $ServicePrincipalName
    )
    try {
        $applicationId = (Get-AzureRmADServicePrincipal -SearchString $ServicePrincipalName).ApplicationId
    }
    catch {
        Write-Error $_
    }

    if ([string]::IsNullOrEmpty($applicationId)) {
        Write-Host "Service Principal $ServicePrincipalName not found."
        exit 1
    }

    $params = @{
        Name = $AppName
        AppSettings = @{
            "ServicePrinicpalApplicationId" = $applicationId
        }
    }
    Set-AzureWebsite @params

}

Export-ModuleMember -Function Set-ServicePrincipalAppSettings