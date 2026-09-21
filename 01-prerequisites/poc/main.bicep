// Exam-equivalent of azuredeploy.json. Learn path 01 writes ARM JSON; AZ-104 also tests Bicep.
// Same desired state: one StorageV2 account. Resource group is created by deploy.sh / deploy.ps1.

@description('Deploy-time knob. Different parameter files → same template, different environments.')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Azure region for the storage account.')
param location string = resourceGroup().location

@description('Short alphanumeric prefix used in the storage account name.')
@minLength(2)
@maxLength(8)
param namePrefix string = 'pyxis'

@description('Replication for Standard SKU. Keep LRS in sandboxes.')
@allowed(['LRS', 'GRS', 'ZRS'])
param storageReplication string = 'LRS'

var storageAccountName = take(toLower('st${namePrefix}${environment}${uniqueString(resourceGroup().id)}'), 24)
var storageSkuName = 'Standard_${storageReplication}'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  tags: {
    environment: environment
    workload: 'az104-prereq'
    managedBy: 'bicep'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
}

output storageAccountName string = storage.name
output storageAccountId string = storage.id
output primaryBlobEndpoint string = storage.properties.primaryEndpoints.blob
