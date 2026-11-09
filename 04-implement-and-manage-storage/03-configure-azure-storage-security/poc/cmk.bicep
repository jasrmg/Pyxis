// Interpret only. The vault must already exist in the SAME region as the account.
// A different subscription is allowed. keySource Microsoft.Keyvault is the customer-managed key.
// This is not key1/key2.

param location string = 'eastus'
param accountName string
param vaultUri string
param keyName string = 'cmk'

resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: accountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyvaulturi: vaultUri
        keyname: keyName
      }
    }
  }
}
