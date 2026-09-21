# Path 01 — Commands (Bash / Azure CLI vs PowerShell)

Recognize these. You do not need every switch. If two answers look similar, pick the verb: **what-if**, **create**, **export**, **decompile**.

Resource groups are created with CLI/PowerShell. Templates then deploy **into** the group (`az deployment group …` / `New-AzResourceGroupDeployment`).

## Identity (Cloud Shell already did this)

| Azure CLI (Bash) | Azure PowerShell |
| --- | --- |
| `az account show` | `Get-AzContext` |
| `az login` (local only) | `Connect-AzAccount` (local only) |

## Resource group

| Azure CLI | Azure PowerShell |
| --- | --- |
| `az group create --name rg-app --location eastus` | `New-AzResourceGroup -Name rg-app -Location eastus` |
| `az group show --name rg-app` | `Get-AzResourceGroup -Name rg-app` |
| `az group delete --name rg-app --yes` | `Remove-AzResourceGroup -Name rg-app -Force` |

`az group create` / `New-AzResourceGroup` is **idempotent enough** for exams: existing group with same location is fine.

## Preview (what-if) — exam favorite

```bash
az deployment group what-if \
  --resource-group rg-app \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json
```

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName rg-app `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -WhatIf
```

Same cmdlet for preview and deploy in PowerShell: **`-WhatIf` is the difference**. CLI uses a different verb: `what-if` vs `create`.

Bicep file works in the same commands: `--template-file main.bicep` / `-TemplateFile main.bicep`.

## Deploy (incremental = default, use it)

```bash
az deployment group create \
  --resource-group rg-app \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json \
  --mode Incremental
```

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName rg-app `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -Mode Incremental
```

Complete mode (know it, do not use it on a shared RG):

```bash
az deployment group create ... --mode Complete
```

```powershell
New-AzResourceGroupDeployment ... -Mode Complete
```

Inline parameter (they show this too):

```bash
az deployment group create -g rg-app --template-file main.bicep --parameters environment=prod
```

```powershell
New-AzResourceGroupDeployment -ResourceGroupName rg-app -TemplateFile main.bicep -environment prod
```

PowerShell can splat template parameters as extra named arguments. CLI uses `--parameters key=value` or a `.parameters.json` file.

## Export and convert (skills measured, verbatim)

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Export RG as ARM JSON | `az group export --name rg-app > azuredeploy.json` | `Export-AzResourceGroup -ResourceGroupName rg-app -Path ./azuredeploy.json` |
| ARM JSON → Bicep | `az bicep decompile --file azuredeploy.json` | `az bicep decompile --file azuredeploy.json` (or `bicep decompile azuredeploy.json`) |
| Bicep → ARM JSON | `az bicep build --file main.bicep` | `az bicep build --file main.bicep` |

Do not mix these up:

- **decompile** = JSON → Bicep  
- **build** = Bicep → JSON  
- **export** = live RG → JSON  
- **what-if** = preview, no change  

## Trap commands (wrong on path 01 questions)

| Looks tempting | Why it is wrong |
| --- | --- |
| `terraform plan` | Not on AZ-104 |
| `az group create --what-if` | what-if is on **deployments**, not `az group create` |
| `az bicep decompile --file main.bicep` | decompile takes **JSON** |
| `az bicep build` as a preview of a live RG | build compiles a file; it does not what-if Azure |

## Cloud Shell itself

No special cmdlet “starts Cloud Shell.” You open portal / `shell.azure.com`. Inside:

- Toolbar: **Bash ↔ PowerShell**
- Editor: Monaco
- Persist: mount Azure Files, or go ephemeral
- Files: `$HOME` (image) and `$HOME/clouddrive` (share)

That is conceptual, not a command to memorize.
