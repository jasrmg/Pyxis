// Hot SMB share on an existing general-purpose v2 account.
// Premium would be a FileStorage account with Premium_LRS or Premium_ZRS, not a GRS SKU.
// accessTier Hot | Cool | TransactionOptimized. Cool is still online.

param accountName string
param shareName string = 'dept'

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  name: '${accountName}/default/${shareName}'
  properties: {
    shareQuota: 100
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
  }
}
