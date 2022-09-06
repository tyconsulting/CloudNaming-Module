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

  [parameter( Mandatory = $true)]
  [string]$ConfigFilePath,

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

#Batch: resource Group + vNet + key vault + storage account
$batchParams = @{
  cloud          = 'Azure'
  type           = $resourceGroupType, $vnetType, $kvType, $storageAccountType
  company        = $company
  appIdentifier  = $appIdentifier
  environment    = $environment
  location       = $location
  instanceCount  = 1
  configFilePath = $ConfigFilePath
}
Write-Verbose "Generating resource names in batch"
$batchNames = GetCloudResourceName @batchParams | convertfrom-Json

<#
Sample output for $batchNames (type is array)
names                      description     type
-----                      -----------     ----
{kv-tao-d01-aue-blog-01}   Key Vault       kv
{rg-tao-d01-aue-blog-01}   Resource Group  rg
{sataod01aueblog01}        Storage Account sa
{vnet-tao-d01-aue-blog-01} Virtual Network vnet
#>

#Process Batch result

#resource group name
$rgName = ($batchNames | where-object { $_.type -ieq $resourceGroupType }).names[0]

#vnet name
$vnetName = ($batchNames | where-object { $_.type -ieq $vnetType }).names[0]

#key vault name
$kvName = ($batchNames | where-object { $_.type -ieq $kvType }).names[0]

#storage account name
$storageName = ($batchNames | where-object { $_.type -ieq $storageAccountType }).names[0]

#NSG pattern is customised in the custom config file
#Private Endpoint subnet & associated NSG
$peSubnetNsgParams = @{
  cloud          = 'Azure'
  type           = $subnetType, $nsgType
  workloadType   = 'pe'
  appIdentifier  = $appIdentifier
  location       = $location
  environment    = $environment
  instanceCount  = 1
  configFilePath = $ConfigFilePath
}
Write-Verbose "Generating private endpoint subnet and NSG names"
$peSubnetNsgNames = GetCloudResourceName @peSubnetNsgParams | convertfrom-Json

<#
sample output for $peSubnetNsgNames (type is array)
names                        description            type
-----                        -----------            ----
{nsg-tao-d01-aue-blog-pe-01} Network Security Group nsg
{sn-pe-01}                   Subnet                 sn
#>

#PE subnet name
$peSubnetName = ($peSubnetNsgNames | where-object { $_.type -ieq $subnetType }).names[0]

#PE Subnet NSG name
$peSubnetNsgName = ($peSubnetNsgNames | where-object { $_.type -ieq $nsgType }).names[0]

#VM subnet & associated NSG
$vmSubnetNsgParams = @{
  cloud          = 'Azure'
  type           = $subnetType, $nsgType
  workloadType   = 'vm'
  appIdentifier  = $appIdentifier
  location       = $location
  environment    = $environment
  instanceCount  = 1
  configFilePath = $ConfigFilePath
}
Write-Verbose "Generating vm subnet and NSG names"
$vmSubnetNsgNames = GetCloudResourceName @vmSubnetNsgParams | convertfrom-Json

<#
sample output for $vmSubnetNsgNames (type is array)
names                        description            type
-----                        -----------            ----
{nsg-tao-d01-aue-blog-vm-01} Network Security Group nsg
{sn-vm-01}                   Subnet                 sn
#>
#PE names can't be generated in batch because 'associatedResourceType'does not support array inputs.

$vmSubnetName = ($vmSubnetNsgNames | where-object { $_.type -ieq $subnetType }).names[0]

#VM Subnet NSG name
$vmSubnetNsgName = ($vmSubnetNsgNames | where-object { $_.type -ieq $nsgType }).names[0]

#Storage Account Private Endpoint
$storagePeParams = @{
  cloud                  = 'Azure'
  type                   = $privateEndpointType
  company                = $company
  associatedResourceType = $storageAccountType
  appIdentifier          = $appIdentifier
  instanceCount          = 1
  configFilePath         = $ConfigFilePath
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
  configFilePath         = $ConfigFilePath
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