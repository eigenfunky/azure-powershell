<#
.DESCRIPTION
    This script creates a 
        - Pfx certificate with password $CertificatePassword in the Env:HOME\AzureCerts directory;
        - Azure Active Directory Application for the $ApplicationName cluster;
        - Azure Active Directory Service Principal in the context of $(Get-AzureRmContext).

    The script then prints the pertinent information to the console.
.PARAMETER ApplicationName [string]
.PARAMETER Domain [string]
.PARAMETER CertficateDirectory [string]
.PARAMETER CertificatePassword [SecureString]
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ApplicationName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Domain,
    [ValidateNotNullOrEmpty()]
    [string] $CertificateDirectory = $(Join-Path -Path "$($Env:HOME)" -ChildPath "AzureCerts"),
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [SecureString] $CertificatePassword
)

$certFilePath = "$CertificateDirectory\$ApplicationName.pfx"
$certStartDate = (Get-Date).Date
$certEndDate = $certStartDate.AddYears(1)
$CertificatePasswordSecureString = ConvertTo-SecureString $CertificatePassword -AsPlainText -Force

New-Item -ItemType Directory -Force -Path $CertificateDirectory

$cert = New-SelfSignedCertificate -DnsName $ApplicationName `
                        -CertStoreLocation cert:\CurrentUser\My `
                        -KeySpec KeyExchange `
                        -NotAfter $certEndDate `
                        -NotBefore $certStartDate
$certThumbprint = $cert.Thumbprint
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\$certThumbprint)

Export-PfxCertificate -Cert $cert `
                        -FilePath $certFilePath `
                        -Password $CertificatePasswordSecureString

$certificatePFX = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFilePath, $CertificatePasswordSecureString)
$certValue = [System.Convert]::ToBase64String($certificatePFX.GetRawCertData())

$application = New-AzureRmADApplication -DisplayName $ApplicationName `
                        -HomePage "$Domain/$ApplicationName" `
                        -IdentifierUris "$Domain/$ApplicationName"  `
                        -CertValue $certValue `
                        -StartDate $certStartDate `
                        -EndDate $certEndDate
                        
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId

Write-Output "Service Principal Application ID: $($servicePrincipal.ApplicationId)"
Write-Output "Service Principal Object ID: $($servicePrincipal.Id)"
Write-Output "Application Object ID: $($application.ObjectId)"
Write-Output "AAD Tenant ID: $((Get-AzureRmContext).Tenant.TenantId)"
Write-Output "PFX Password: $CertificatePassword"
Write-Output "Base-64 PFX file contents $([System.Convert]::ToBase64String((Get-Content $certFilePath -Encoding Byte)))"