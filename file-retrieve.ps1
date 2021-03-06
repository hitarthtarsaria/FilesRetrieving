param (
    [string]$tenantId = $OctopusParameters["Name-of-Parameter"], 
    [string]$subscriptionId = $OctopusParameters["Name-of-Parameter"],   
    [string]$clientId = $OctopusParameters["Name-of-Parameter"], 
    [string]$clientSecret = $OctopusParameters["Name-of-Parameter"]
)

#Checking the Powershell Version

Write-Host "Powershell Version: $($PSVersionTable.PSVersion)"

# Getting AZ Module and installing package
if (!(Get-Module "Az")) {
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name Az -AllowClobber -Force
    Import-Module -Name Az    
}

$tenant = $($OctopusParameters["Octopus.Deployment.Tenant.Name"]).Replace(" ","")
$password = $clientSecret | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($clientId, $password)
Connect-AzAccount -Tenant $tenantId -Subscription $subscriptionId -ServicePrincipal -Credential $credential -Confirm:$false -WarningAction SilentlyContinue | Out-Null


#Passing the Directory file path

$SourceFile = "directory"
$Files = Get-ChildItem $SourceFile
$Guid = New-Guid  // Creating a temporary with GUID
$Destination = New-Item -Path "Z:\" -Name $Guid -ItemType "directory" 
Write-Host " Destination Name"
Write-Output $Destination
Copy-Item $Files -Destination $Destination

#Passing your resources

$location = "location-of-your-resource"
$resourceGroup = "ResourceGroupName"
$storageAccountName = "StorageAccountName"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$ctx = $storageAccount.Context
$containerName = "ContainerName"

# upload a file


foreach ( $x in $Files) {
    Write-Output $x // To check the content we are fetching it
    $targetPath = $tenant+ "_" + $x.Name 
    Set-AzStorageBlobContent -File $x.fullname -Container $containerName -Blob $targetPath -Context $ctx 
}


Remove-Item –path $destination.FullName -Force -Confirm:$false -Recurse
