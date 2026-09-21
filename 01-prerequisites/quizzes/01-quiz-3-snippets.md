# 01 Prerequisites — Quiz 3 (snippet drill)

Date issued: 2026-09-21  
Purpose: command / ARM / Bicep exhibits only. Path 01 conceptual quiz already passed; this is to confirm you can **read the exam paper**.  
Pass: **9/10**. Closed notes.

Reply `1.` through `10.` in this chat. No hints. I grade after you submit.

---

**1.** Exhibit:

```json
"parameters": {
  "environment": { "type": "string", "allowedValues": [ "dev", "prod" ] }
},
"variables": {
  "storageAccountName": "[concat('st', parameters('environment'), 'logs')]"
},
"outputs": {
  "storageAccountId": {
    "type": "string",
    "value": "[resourceId('Microsoft.Storage/storageAccounts', variables('storageAccountName'))]"
  }
}
```

A teammate says “make `environment` a variable so we do not have to pass it.” What happens if you do that, and what is the correct fix if prod must be selectable at deploy time?

A. Fine — variables can be overridden with `--parameters`.  
B. Prod cannot be passed in; `environment` must stay a **parameter**. The concat name stays a **variable**. The resource ID stays an **output**.  
C. Move `storageAccountName` to `outputs` and `environment` to `resources`.  
D. Delete `parameters`; Bicep `var` is the only legal way to pass `prod`.

---

**2.** Exhibit:

```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}
```

What is the resource **API version**, and which ARM JSON fields does `'Microsoft.Storage/storageAccounts@2023-01-01'` replace?

A. API version is `1.0.0.0`; the string replaces `$schema` only.  
B. API version is `2023-01-01`; the string is ARM `type` + `apiVersion`.  
C. API version is `Standard_LRS`; the string replaces `contentVersion`.  
D. There is no API version in Bicep; you must keep a separate `apiVersion` property.

---

**3.** Exhibit (from `poc/azuredeploy.json`). Requirement: storage must use **GRS**, not LRS.

```json
"parameters": {
  "storageReplication": {
    "type": "string",
    "defaultValue": "LRS",
    "allowedValues": [ "LRS", "GRS", "ZRS" ]
  }
},
"variables": {
  "storageSkuName": "[concat('Standard_', parameters('storageReplication'))]"
},
"sku": { "name": "[variables('storageSkuName')]" }
```

Smallest correct change at **deploy time** (do not edit the template)?

A. Change `$schema` to `2019-04-01`.  
B. Pass `storageReplication=GRS` (CLI `--parameters` or the parameters file `value`).  
C. Change `contentVersion` to `2.0.0.0`.  
D. Add `"mode": "Complete"` to the template.

---

**4.** Goal: **preview** a Bicep deployment into `rg-app`. No resources should be created. Which command is correct?

A. `az group create --what-if --name rg-app --template-file main.bicep`  
B. `az bicep build --file main.bicep`  
C. `az deployment group what-if --resource-group rg-app --template-file main.bicep`  
D. `az bicep decompile --file main.bicep`

---

**5.** Exhibit:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName rg-app `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -Mode Incremental
```

This ran and **changed** Azure. You wanted a dry-run. What was missing, and which CLI verb is the equivalent dry-run?

A. Missing `-Force`; CLI equivalent is `az group create`.  
B. Missing `-WhatIf`; CLI equivalent is `az deployment group what-if`.  
C. Missing `-AsJob`; CLI equivalent is `az bicep build`.  
D. Nothing missing — Incremental never changes existing resources, so it is already a dry-run.

---

**6.** You already have a live resource group. Skills measured: dump it as ARM, then get Bicep. Pick the **pair**.

A. `az bicep build --file main.bicep` then `az group create`  
B. `az group export --name rg-app > main.json` then `az bicep decompile --file main.json`  
C. `az bicep decompile --file main.bicep` then `az deployment group what-if`  
D. `terraform show` then `az bicep build`

---

**7.** `rg-shared` contains a VNet (in the template) and a portal-created SQL server (not in the template). Exhibit:

```bash
az deployment group create \
  --resource-group rg-shared \
  --template-file vnet.json \
  --mode Complete
```

What happens to SQL and to the VNet?

A. SQL left alone; VNet deleted.  
B. Both deleted.  
C. SQL **deleted** (not in the template); VNet **created or updated** (in the template).  
D. Nothing, because `--mode Complete` is a what-if alias.

---

**8.** Someone runs:

```bash
az deployment group create \
  --resource-group rg-app \
  --template-file azuredeploy.parameters.json
```

`azuredeploy.parameters.json` starts with:

```json
"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
```

Why does this fail (or not deploy resources), and what should `--template-file` point at?

A. Parameters schema is not a template; `--template-file` must be `azuredeploy.json` or `main.bicep`. Pass the parameters file with `--parameters`.  
B. `deploymentParameters.json#` is the correct template schema; the RG name is wrong.  
C. You must use `--mode Complete` when the schema is parameters.  
D. PowerShell is required; CLI cannot deploy JSON.

---

**9.** Storage account `stlogs001` already exists in `eastus` at TLS 1.2. You deploy this resource again (same name) with **only** the location edited:

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2023-01-01",
  "name": "stlogs001",
  "location": "westus",
  "sku": { "name": "Standard_LRS" },
  "kind": "StorageV2"
}
```

Result?

A. ARM moves the account to `westus`.  
B. ARM creates a second account named `stlogs001` in `westus`.  
C. Deploy **fails**; location (and type) cannot be changed in place.  
D. Incremental no-op because the name already exists, regardless of location.

---

**10.** Match the job to the command. One correct row.

| Job | Command |
| --- | --- |
| A. Bicep → ARM JSON | `az bicep decompile --file main.json` |
| B. Live RG → ARM JSON | `az group export --name rg-app` |
| C. Preview deploy | `az bicep build --file main.bicep` |
| D. ARM JSON → Bicep | `az deployment group create --mode Complete` |

Which letter’s **job and command actually match**?

---

## Submission — 2026-09-21

1. B  
2. B  
3. B  
4. C  
5. B  
6. B  
7. C  
8. A  
9. C  
10. B

## Score: 10/10 (100%) — PASS

Snippet verbs you proved you can tell apart: parameter vs variable vs output, Bicep `@apiVersion`, deploy-time parameter (not `$schema`), `what-if` vs `build`/`decompile`/`group create`, PowerShell `-WhatIf`, `export` then `decompile`, `--mode Complete` deletes extras, parameters file is not `--template-file`, location change fails in place, `az group export` is live RG → JSON.

Path 01 remains checked off. Snippet drill closed.

