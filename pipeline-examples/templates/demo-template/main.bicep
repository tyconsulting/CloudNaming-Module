targetScope = 'subscription'

@description('Name of the resource Group')
param resourceGroupName string

@description('resource location')
param location string = deployment().location

@description('Name of the Virtual Network')
param vNetName string

@description('Virtual Network CIDRs. Eg: 10.0.0.0/8')
param vNetCIDRs array

@description('Subnet(s) Configuration Details')
param subnetConfiguration array = [
  {
    subnetName: 'SampleSubnetName'
    networkSecurityGroupName: 'SampleNsgId'
    nsgSecurityRules: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    addressPrefix: '10.0.0.0/8'
  }
]

@description('Name of Storage Account')
param storageAccountName string

@allowed([
  'Hot'
  'Cool'
])
@description('Optional. Storage Account Access Tier.')
param storageAccountAccessTier string = 'Hot'

@description('The name of the SKU')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageSku string = 'Standard_GRS'

@description('Specifies the kind of storage')
@allowed([
  'StorageV2'
  'BlobStorage'
  'FileStorage'
])
param storageKind string = 'StorageV2'

@description('The name of the key vault used for encryption using Customer-Managed Keys (CMK)')
param keyVaultName string

@description('Optional. The Sku of the key vault used for encryption using Customer-Managed Keys (CMK)')
@allowed([
  'premium'
  'standard'
])
param keyVaultSku string = 'premium'

@description('Optional. The size of the CMK encryption key in bits used for For example: 2048, 3072, or 4096 for RSA. Default is set to 4096')
param keySize int = 4096

@description('Optional. The type of the CMK encryption key. Default value is RSA')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'RSA-HSM'

@description('The name of the key vault private endpoint')
param keyVaultPrivateEndpointName string

@description('Name of the Private Endpoint for Storage Account')
param storageAccountPrivateEndpointName string

@description('Private Endpoint subnet name')
param peSubnetName string

var deploymentNameSuffix = last(split(deployment().name, '-'))

var cmkKeyName = 'cmk-${storageAccountName}'


// ---------- Resource Groups ----------
@description('Create a Resource Group')
module deployRg '../../modules/microsoft.resources/resourceGroups/main.bicep' = {
  name: take('deployRg-${deploymentNameSuffix}', 64)
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

// ---------- Azure Key Vault for CMK Encryption----------
module deployKV '../../modules/standardKeyVault/main.bicep' = {
  name: take('deployStandardKv-${deploymentNameSuffix}', 64)
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    deployRg
  ]
  params: {
    keyVaultName: keyVaultName
    skuName: keyVaultSku
    privateEndpointName: keyVaultPrivateEndpointName
    subnetId: '${deployStandardVNet.outputs.vNetResourceId}/subnets/${peSubnetName}'
    enableRbacAuthorization: true
  }
}

module deployCMKKey '../../modules/microsoft.keyvault/vaults/keys/main.bicep' = {
  name: take('deployCMKKey-${deploymentNameSuffix}', 64)
  scope: resourceGroup(resourceGroupName)
  params: {
    keyVaultName: deployKV.outputs.keyVaultName
    name: cmkKeyName
    keyOps: [
      'encrypt'
      'decrypt'
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
    ]
    keySize: keySize
    kty: keyType
  }
}

// ---------- Standard Storage Accounts ----------
module deployStdSa '../../modules/standardStorageAccount/main.bicep' = {
  name: take('deployStorage-${deploymentNameSuffix}', 64)
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    deployRg
    deployKV
  ]
  params: {
    location: location
    storageAccountName: storageAccountName
    sku: storageSku
    kind: storageKind
    storageAccountAccessTier: storageAccountAccessTier
    networkAclsDefaultAction: 'Deny'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    infrastructureEncryptionEnabled: true
    cMKKeyVaultResourceId: deployKV.outputs.keyVaultResourceId
    cMKKeyName: deployCMKKey.outputs.name
    enableSFTP: false
    privateEndpointName: storageAccountPrivateEndpointName
    privateEndpointGroupId: 'blob'
    subnetId: '${deployStandardVNet.outputs.vNetResourceId}/subnets/${peSubnetName}'
  }
}
// ---------- Virtual Network  ----------
module deployStandardVNet '../../modules/standardVNet/main.bicep' = {
  name: take('deployVNet-${deploymentNameSuffix}', 64)
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    deployRg
  ]
  params: {
    vNetName: vNetName
    vNetCIDRs: vNetCIDRs
    subnetConfiguration: subnetConfiguration
  }
}

// ---------- Outputs ----------

output resourceGroupName string = deployRg.outputs.resourceGroupName
output resourceGroupResourceId string = deployRg.outputs.resourceGroupResourceId

output vnetName string = deployStandardVNet.outputs.vNetName
output vnetResourceId string = deployStandardVNet.outputs.vNetResourceId
output subnetConfiguration array = deployStandardVNet.outputs.subnetConfiguration
