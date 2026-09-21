# Path 01 — Snippet drills

This is how AZ-104 asks ARM/Bicep. Read the exhibit. Answer the question. Do not rewrite the whole file.

Live lab copies: `../poc/azuredeploy.json` and `../poc/main.bicep`.

---

## 1. Name the sections (ARM)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": { },
  "variables": { },
  "resources": [ ],
  "outputs": { }
}
```

If they highlight `$schema` → JSON schema URL, and the path (`deploymentTemplate.json`) implies **resource group** scope.  
If they highlight `contentVersion` → **your** version string, usually `1.0.0.0`. Not an Azure API.  
If a resource is missing `"apiVersion": "2023-01-01"` → the template is invalid; that is the provider contract.

---

## 2. Same desired state in Bicep (map 1:1)

```bicep
param environment string = 'dev'          // ARM parameters
var storageName = 'st${environment}logs'  // ARM variables
resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {  // type + apiVersion
  name: storageName
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}
output storageId string = st.id           // ARM outputs
```

`Microsoft.Storage/storageAccounts@2023-01-01` **is** ARM `type` + `apiVersion`. If the question is “which API version,” it is the bit after `@`.

---

## 3. Parameter vs variable vs output (spot the wrong one)

```json
"parameters": {
  "environment": { "type": "string", "allowedValues": [ "dev", "prod" ] }
},
"variables": {
  "appName": "[concat('app-contoso-', parameters('environment'))]"
},
"outputs": {
  "hostName": { "type": "string", "value": "[reference(variables('appName')).defaultHostName]" }
}
```

Caller changes `dev`/`prod` → **parameter**.  
`concat` / string interpolation → **variable**.  
Value needed **after** deploy → **output**.

Wrong exhibit you will see: `environment` stuffed in `variables` with no way to pass `prod` at deploy time. Fix: move it to `parameters`.

---

## 4. Which line do you change? (SKU / TLS)

They give a storage account and say “use GRS” or “require TLS 1.2”:

```json
"sku": { "name": "Standard_LRS" },
"properties": {
  "minimumTlsVersion": "TLS1_0",
  "supportsHttpsTrafficOnly": true
}
```

GRS → `"name": "Standard_GRS"` (or Bicep `sku: { name: 'Standard_GRS' }`).  
TLS → `"minimumTlsVersion": "TLS1_2"`.  
You do **not** change `$schema` or `contentVersion` for a SKU question.

---

## 5. Deploy twice / change location (predict the result)

Template name `stlogs001`, location `eastus`. Account already exists there, same SKU.

- Deploy again, same template → **no-op**.
- Change SKU LRS → GRS (updatable) → **update**.
- Change `"location": "westus"` on that **same name** → **fail**. Location and type are not in-place morphs. New name / new resource.

---

## 6. Incremental vs Complete (the exhibit is the RG, not just the template)

Template resources: `[ VNet ]`.  
RG already contains: VNet + a portal-created SQL server.

| Mode | VNet | SQL |
| --- | --- | --- |
| Incremental (default) | create/update | **left alone** |
| Complete | create/update | **deleted** |

If the command shows `--mode Complete` / `-Mode Complete` on a shared RG, the “unexpected” extra resource is the one that dies.

---

## 7. Pick the command (four looks-alike)

Goal: **preview** a Bicep deploy into `rg-app`.

Correct:

```bash
az deployment group what-if -g rg-app --template-file main.bicep
```

Not: `az group create --what-if`  
Not: `az bicep build --file main.bicep` (compiles locally, does not talk to the RG)  
Not: `az bicep decompile --file main.bicep` (wrong direction, wrong file type)

Goal: **turn exported JSON into Bicep**:

```bash
az group export --name rg-app > main.json
az bicep decompile --file main.json
```

---

## 8. Parameters file vs inline

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": { "value": "prod" }
  }
}
```

That schema is **parameters**, not the template schema (`deploymentTemplate.json`). If they ask “why did this fail to deploy as a template,” you pointed `--template-file` at a parameters file.

---

## Drill

Open `../poc/azuredeploy.json`. Without scrolling to Bicep, write the Bicep `param` / `var` / `resource` / `output` names. Then diff against `../poc/main.bicep`. If that takes more than a few minutes, you are not done with snippets yet.
