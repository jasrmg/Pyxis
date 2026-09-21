# Path 01 — What to remember

Exam will **show you snippets**. You are not asked to author a 200-line template from a blank page. You are asked to **read, modify, pick the right command, and predict the result**.

Do **not** memorize every `az` flag in existence. Do memorize the pairs in `commands.md` and the read-this-JSON patterns in `snippets.md`.

---

## Cloud Shell (6 facts)

1. Browser terminal, **already signed in as you**, Bash **or** PowerShell.
2. **Linux container** even for PowerShell. Same session identity. Same file share if storage is mounted.
3. Timeout = **20 minutes idle**, not 20 minutes of runtime. Silent jobs die. Interactive short work is the use case.
4. Persistence is optional: **ephemeral** = gone next session; **mounted Azure Files** = `$HOME` disk image + `clouddrive` folder on that share.
5. **Compute is free. The file share is billed.** Per-user storage. Subscription Contributor can often read the share.
6. Not CI/CD. Not a jump box. Not the place for a quiet 90-minute deploy.

## ARM / Bicep (7 facts)

1. Desired state. Declarative. Resource Manager is the control plane.
2. **Parameter** = deployer sets it (`env`, `location`). **Variable** = template computes it (`concat` / `'st${env}'`). **Output** = after success (resource ID, hostname).
3. `$schema` = JSON schema URL (scope). `contentVersion` = **your** file version (`1.0.0.0`). Resource `apiVersion` = provider contract. Three different things.
4. Unchanged resource = **no-op**. Changed updatable property = **update**. Location or type change = **fail**.
5. **Incremental** (default): extras in the RG **stay**. **Complete**: extras in the RG **deleted** — including a portal-created SQL DB the template never mentioned.
6. Preview: `az deployment group what-if` / `New-AzResourceGroupDeployment -WhatIf`. Then deploy. Never Complete on a junk-drawer RG.
7. Exam conversion: `az group export` (or portal Export) → ARM JSON; `az bicep decompile --file file.json` → Bicep. `az bicep build` is Bicep → JSON (the other direction).

## How a snippet question usually works

They paste JSON or Bicep (or two CLI lines) and ask one of:

- Which section is missing / which value is a parameter vs a variable?
- Change SKU / add a parameter / fix `apiVersion` — **which line**?
- What happens if you deploy twice? Incremental vs Complete?
- Which command previews, deploys, exports, or decompiles?

If you can annotate `poc/azuredeploy.json` and `poc/main.bicep` without notes, you are done with path 01 memory.
