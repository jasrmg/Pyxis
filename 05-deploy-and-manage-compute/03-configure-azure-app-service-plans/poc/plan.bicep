// Interpret only. sku.name S1 is Standard: first tier with a staging slot.
// P1V3 is Premium v3: the tier for 10 slots, and one of the two that support automatic scaling.
// numberOfWorkers is scale-out. Changing the sku name is scale-up. Both apply to every app on the plan.

param location string = 'eastus'
param planName string = 'asp-hotel'

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}
