// Two-fault-domain availability set. Update domain count is fixed after this deploy.
// A VM resource in this file would set availabilitySet, not zones. Those two cannot be combined.

param location string = 'eastus'
param setName string = 'avset-web'

resource avset 'Microsoft.Compute/availabilitySets@2024-07-01' = {
  name: setName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
}
