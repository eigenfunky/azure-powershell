# Azure Powershell Tools
A collection of useful scripts for interacting with the Azure Cloud.

## Tools
- ServicePrincipal
    - AddServicePrincipal.ps1: Constructs a service principal, AAD application, and PFX Certificate.
    ``` powershell
        $securePassword = Convert-ToSecureString "XXXXXXXXXXXXXXXXXX" -AsPlainText -Force
        $params = @{
            ApplicationName = "powershell-rest-api"
            Domain = "eigenfunky.com"
            CertificatePassword = $securePassword
        }

        ./AddServicePrincipal.ps1 @params
    ```
    - RemoveServicePrincipal.ps1: Tears down a service principal and AAD application.
    ``` powershell
        $params = {
            ServicePrincipalObjectId = "XXXX-XXXX-XXXX-XXXXXXXXXXXXXXXXXXXXX"
            ApplicationObjectId = "XXXX-XXXX-XXXX-XXXXXXXXXXXXXXXXXXXXX"
            ApplicationName = "powershell-rest-api"
        }

        ./RemoveServicePrincipal.ps1 @params
    ```