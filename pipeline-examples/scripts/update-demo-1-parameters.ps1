#Requires -modules CloudNaming
<#
=======================================================
AUTHOR: Tao Yang
DATE: 01/09/2022
NAME: update-demo-1-parameters.ps1
VERSION: 1.0.0
COMMENT: Update the parameters of the demo-1 template
=======================================================
#>

[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [string]$parameterFilePath,

  [parameter(Mandatory = $false, HelpMessage = "The directory for updated parameter file")]
  [string]$updatedParameterFileArtifactName = 'UpdatedParameterFile'
)

# Import the modules
import-module CloudNaming

#variables
$appIdentifier = $env:Naming_appIdentifier
$company = $env:Naming_company
$environment = $env:Naming_environment
$location = $env:Naming_location
$vnetType = $env:Naming_vnetType
$subnetType = $env:Naming_subnetType
$nsgType = $env:Naming_nsgType
$kvType = $env:Naming_kvType
$storageAccountType = $env:Naming_storageAccountType
$resourceGroupType = $env:Naming_resourceGroupType
$privateEndpointType = $env:Naming_privateEndpointType
#Generate Names individually

#resource Group
$rgParams = @{
  cloud         = 'Azure'
  type          = $resourceGroupType
  company       = $company
  appIdentifier = $appIdentifier
  environment   = $environment
  location      = $location
  instanceCount = 1
}
Write-Verbose "Generating resource group name"
$rgName = (GetCloudResourceName @rgParams | convertfrom-Json).names[0]

#VNet
$vNetParams = @{
  cloud         = 'Azure'
  type          = $vnetType
  company       = $company
  appIdentifier = $appIdentifier
  environment   = $environment
  location      = $location
  instanceCount = 1
}
Write-Verbose "Generating virtual network name"
$vNetName = (GetCloudResourceName @vNetParams | convertfrom-Json).names[0]

#Private Endpoint subnet
$peSubnetParams = @{
  cloud         = 'Azure'
  type          = $subnetType
  workloadType  = 'pe'
  instanceCount = 1
}
Write-Verbose "Generating private endpoint subnet name"
$peSubnetName = (GetCloudResourceName @peSubnetParams | convertfrom-Json).names[0]

#Private Endpoint subnet NSG
$peSubnetNsgParams = @{
  cloud         = 'Azure'
  type          = $nsgType
  company       = $company
  appIdentifier = $appIdentifier
  environment   = $environment
  location      = $location
  instanceCount = 1
}
$peSubnetNsgName = (GetCloudResourceName @peSubnetNsgParams | convertfrom-Json).names[0]

#VM subnet
$vmSubnetParams = @{
  cloud         = 'Azure'
  type          = $subnetType
  workloadType  = 'vm'
  instanceCount = 1
}
Write-Verbose "Generating vm subnet name"
$vmSubnetName = (GetCloudResourceName @vmSubnetParams | convertfrom-Json).names[0]

#VM subnet NSG
$vmSubnetNsgParams = @{
  cloud               = 'Azure'
  type                = $nsgType
  company             = $company
  appIdentifier       = $appIdentifier
  environment         = $environment
  location            = $location
  instanceCount       = 1
  startInstanceNumber = 2
}
$vmSubnetNsgName = (GetCloudResourceName @vmSubnetNsgParams | convertfrom-Json).names[0]

#Key Vault
$kvParams = @{
  cloud         = 'Azure'
  type          = $kvType
  appIdentifier = $appIdentifier
  environment   = $environment
  location      = $location
  instanceCount = 1
}
Write-Verbose "Generatingkey vault name"
$kvName = (GetCloudResourceName @kvParams | convertfrom-Json).names[0]

#Storage Account
$storageParams = @{
  cloud         = 'Azure'
  type          = $storageAccountType
  appIdentifier = $appIdentifier
  environment   = $environment
  location      = $location
  instanceCount = 1
}
Write-Verbose "Generating storage account name"
$storageName = (GetCloudResourceName @storageParams | convertfrom-Json).names[0]

#Storage Account Private Endpoint
$storagePeParams = @{
  cloud                  = 'Azure'
  type                   = $privateEndpointType
  company                = $company
  associatedResourceType = $storageAccountType
  appIdentifier          = $appIdentifier
  instanceCount          = 1
}
Write-Verbose "Generating storage account private endpoint name"
$storagePeName = (GetCloudResourceName @storagePeParams | convertfrom-Json).names[0]

#Key Vault Private Endpoint
$kvPeParams = @{
  cloud                  = 'Azure'
  type                   = $privateEndpointType
  company                = $company
  associatedResourceType = $kvType
  appIdentifier          = $appIdentifier
  instanceCount          = 1
}
Write-Verbose "Generating key vault private endpoint name"
$kvPeName = (GetCloudResourceName @kvPeParams | convertfrom-Json).names[0]

#parse Json file
Write-Output "Parameter File Path: '$ParameterFilePath'"
$content = Get-Content -Path $ParameterFilePath -Raw
$json = ConvertFrom-Json -InputObject $content -ErrorVariable parseError
if ($parseError) {
  Throw $parseError
  exit -1
}

Write-Output "The Resource Group name is: '$rgName'"
Write-Output "The Virtual Network name is: '$vNetName'"
write-Output "The Private Endpoint subnet name is: '$peSubnetName'"
write-Output "The Private Endpoint subnet NSG name is: '$peSubnetNsgName'"
write-Output "The VM subnet name is: '$vmSubnetName'"
write-Output "The VM subnet NSG name is: '$vmSubnetNsgName'"
Write-Output "The Storage Account name is: '$storageName'"
Write-Output "The Key Vault name is: '$kvName'"
Write-Output "The Storage Account Private Endpoint name is: '$storagePeName'"
Write-Output "The Key Vault Private Endpoint name is: '$kvPeName'"


#Add names to the parameter file
Write-Output "Update the parameter file"
$json.parameters.resourceGroupName.value = $rgName
$json.parameters.vNetName.value = $vNetName
$json.parameters.storageAccountName.value = $storageName
$json.parameters.keyVaultName.value = $kvName
$json.parameters.keyVaultPrivateEndpointName.value = $kvPeName
$json.parameters.storageAccountPrivateEndpointName.value = $storagePeName
$json.parameters.peSubnetName.value = $peSubnetName
#Identify subnets
foreach ($subnet in $json.parameters.subnetConfiguration.value) {
  if ($subnet.privateEndpointNetworkPolicies -eq 'Enabled') {
    $subnet.subnetName = $peSubnetName
    $subnet.networkSecurityGroupName = $peSubnetNsgName
  } else {
    $subnet.subnetName = $vmSubnetName
    $subnet.networkSecurityGroupName = $vmSubnetNsgName
  }
}

# Save Updated Parameter File
$parameterFile = get-item $parameterFilePath
$parameterFileDir = $parameterFile.Directory
$parameterFileName = $parameterFile.Name
$UpdatedParameterFileDirPath = Join-Path $parameterFileDir $updatedParameterFileArtifactName
Write-Output "Save the updated parameter file to '$UpdatedParameterFileDirPath'"
if (!(Test-Path $UpdatedParameterFileDirPath)) {
  New-Item -ItemType Directory -Path $UpdatedParameterFileDirPath
}

$json | ConvertTo-Json -depth 100 | Out-File -FilePath $(join-path $UpdatedParameterFileDirPath $parameterFileName) -Force