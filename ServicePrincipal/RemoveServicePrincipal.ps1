<#
.SYNOPSIS
    This script tears down the objects created in the AddServicePrincipal.ps1 script.
.DESCRIPTION
    This script gracefully tears down
        - the Azure Active Directory Service Principal $ServicePrincipalObjectId in the context of $(Get-AzureRmContext);
        - the Azure Active Directory Application $ApplicationId;
        - the $ApplicationName Pfx certificate located at $CertificateDirectory.

.PARAMETER ServicePrincipalObjectId  [string]
.PARAMETER ApplicationObjectId [string]
.PARAMETER ApplicationName [string]
.PARAMETER CertificateDirectory [string]
.PARAMETER PurgeCertificate [string]
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ServicePrincipalObjectId,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ApplicationObjectId,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ApplicationName,
    [ValidateNotNullOrEmpty()]
    [string] $CertificateDirectory = $(Join-Path -Path "$($Env:HOME)" -ChildPath "AzureCerts"),
    [switch] $PurgeCertificate
)

Remove-AzureRmADServicePrincipal -ObjectId $ServicePrincipalObjectId -Force
Remove-AzureRmADApplication -ObjectId $ApplicationObjectId -Force

if ($PurgeCertificate) {
    Remove-Item -Path "$CertficateDirectory\$ApplicationName.pfx" -Force
}
