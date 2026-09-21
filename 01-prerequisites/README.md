# 01 — Prerequisites for Azure administrators

Microsoft Learn path: [AZ-104: Prerequisites for Azure administrators](https://learn.microsoft.com/en-us/training/paths/az-104-administrator-prerequisites/)

Two modules. Neither is "Azure 101." They exist so you can **operate Azure without a configured workstation** and **deploy the same infrastructure more than once without clicking**.

PoCs use the **AZ-104 exam stack**: Azure portal, Azure CLI, Azure PowerShell, ARM JSON, and Bicep. Learn path 01 writes ARM JSON; the exam also asks you to read, modify, deploy, export, and decompile Bicep.

---

## Module 1 — Introduction to Azure Cloud Shell

**Aim:** Describe Cloud Shell, decide if it fits the org, and persist files across sessions.

### What it is

Azure Cloud Shell is a **Microsoft-managed, authenticated, browser-accessible terminal** for managing Azure. You choose **Bash** or **PowerShell**. You do not install the CLI, Az modules, or auth tooling on the laptop.

Access points: Azure portal, [shell.azure.com](https://shell.azure.com), Azure mobile app, VS Code Azure Account extension, and Learn docs "Try it" panes.

It is **not**:

- A replacement for CI/CD
- A always-on jump box / bastion
- A generic multi-cloud shell
- "Just Azure CLI" — it is a full shell with Azure CLI, Azure PowerShell, an editor (Monaco), and a toolbelt Microsoft maintains

The **host machine is free**. The **storage account / Azure Files share is not** — normal storage charges apply.

### How a session works

| Fact | Detail |
| --- | --- |
| Host | Temporary container, **per-user, per-session** |
| OS | Linux. PowerShell in Cloud Shell is PowerShell on Linux, not Windows PowerShell |
| Auth | Already signed in as **you**. Commands run with **your** Entra ID token and RBAC |
| Idle timeout | Session dies after **20 minutes with no interactive activity** |
| Shells | Bash (typically Azure CLI) or PowerShell (typically Az cmdlets). Switch in the toolbar. Same backend. |

Bash vs PowerShell **as languages** (text streams vs .NET objects) is true and useful. It is **not** the Cloud Shell teaching point. The teaching point is: two admin experiences, one managed workstation, your identity.

### Persistence — the part people fail in interviews

On first launch you choose:

1. **Mount storage** (persistent), or
2. **Ephemeral session** (nothing survives the session)

If you mount storage, Cloud Shell uses **one Azure Files share** for both Bash and PowerShell, reused on later sessions.

Two persistence paths, both on that share:

| What | Where | Survives sessions? |
| --- | --- | --- |
| `$HOME` (SSH keys, profiles, `.bashrc`) | 5 GB disk image in the share: `.cloudconsole/<user>.img` | Yes, if storage is mounted |
| Extra files you put on the drive | `$HOME/clouddrive` → the file share itself | Yes, if storage is mounted |
| Anything in an ephemeral session | Container disk only | **No. Gone when the session ends.** |

Unmount the share and the next session will prompt you to attach another one.

**Security (enterprise, not Learn fluff):**

- Prefer **per-user storage accounts**. Do not share one Cloud Shell storage account across the team.
- The identity using Cloud Shell needs **Contributor or higher on that storage account**.
- Anyone with sufficient rights on the **subscription** can often reach the share via inherited RBAC. Treat `$HOME` as a secrets store you did not intend to create (SSH keys, downloaded kubeconfigs, copied SAS tokens).
- Encryption at rest is on by default for Cloud Shell infrastructure. That does not make a shared file share safe.

### When to use it vs a local workstation

Use Cloud Shell when:

- You are not on your configured workstation (hotel laptop, kiosk, phone, another team's PC)
- You need an already-authenticated Azure CLI / Az PowerShell **right now**
- You are following a Learn module or a runbook that assumes Cloud Shell
- The work is **interactive** and short

Use local CLI / a jump host / a pipeline when:

- The job must survive idle time (20 **idle** minutes, not 20 minutes of wall-clock runtime — a script that prints nothing can look idle and die)
- You are deploying IaC as a repeatable process (ARM/Bicep in a pipeline, not `az deployment group create` in a browser tab you then abandon)
- You need custom tooling, private network paths Cloud Shell cannot reach, or pinned CLI versions
- Secrets must not land on a storage account other people in the subscription can read

**Interview one-liner:** Cloud Shell is a managed admin workstation in the browser. The compute is ephemeral. Persistence is an Azure Files share you pay for and must lock down.

---

## Module 2 — Deploy Azure infrastructure by using JSON ARM templates

**Aim:** Stop clicking. Describe desired state in a template so Azure Resource Manager can create or update it **consistently**.

Learn uses JSON ARM. The exam skills measured also include Bicep: interpret, modify, deploy, export a deployment as ARM, and convert ARM → Bicep (`az bicep decompile`). Same concepts in both formats: declarative desired state, parameters vs variables vs outputs, incremental vs complete.

### What an ARM template is for

One sentence: **a JSON document of desired Azure state that Resource Manager deploys idempotently.**

- **Declarative:** you say *what* should exist, not the click/CLI steps to get there.
- **Idempotent:** run it again; Azure converges to the template. It does **not** blindly duplicate resources.
- **Reusable:** same template, different parameter files → dev / test / prod.

Azure Resource Manager is the **control plane**. The portal, Azure CLI, Azure PowerShell, ARM templates, and Bicep all end up talking to it.

### Template sections

Required in practice:

| Section | Role |
| --- | --- |
| `$schema` | URL of the JSON schema that validates the file (subscription vs resource-group vs management-group vs tenant scope) |
| `contentVersion` | **Your** template version string (`1.0.0.0`). Not the Azure API version. |
| `parameters` | Values supplied **at deploy time** (or defaults). Environment knobs. Max 256. |
| `variables` | Values computed **inside** the template. Callers cannot override them. Max 256. |
| `resources` | What actually gets deployed. Each needs `type`, `apiVersion`, `name`. Max 800. |
| `outputs` | Values returned **after** a successful deployment (IDs, FQDNs, connection strings). Max 64. |

Also exist, less critical for AZ-104: `functions`, `definitions`, `languageVersion`.

Resource `apiVersion` is **not** `contentVersion`. `apiVersion` pins the resource-provider contract (`Microsoft.Storage/storageAccounts@2023-01-01` style). Wrong `apiVersion` → missing properties or failed deploys.

### Parameter vs variable vs output (with a real example)

Deploy a storage account named `st{env}logs001` in `eastus` for prod and `westus` for test.

| Kind | Example | Who sets it | When resolved |
| --- | --- | --- | --- |
| **Parameter** | `environment = prod`, `location = eastus` | Deployer / pipeline / `.parameters.json` | Before resources are created |
| **Variable** | `storageName = concat('st', environment, 'logs001')` | Template author only | Before resources are created |
| **Output** | `storageAccountId` after deploy | Returned to the next pipeline step or `az deployment group show` | After success |

If a value **changes per environment**, it is a parameter (Bicep `param`).  
If a value is **derived so you do not repeat an expression**, it is a variable (Bicep `var`).  
If a later system **needs a result** (resource ID, FQDN), it is an output.

### Idempotency — what "run it twice" actually does

For resources **in the template**:

- Exists, properties **unchanged** → no-op
- Exists, properties **changed** → **update** (not "leave it alone")
- Exists, you try to change **location** or **type** → **fail**. Create a new resource instead
- Does not exist → **create**

That is idempotency: **converge to desired state**, not "never touch existing stuff."

Then deployment **mode** decides what happens to resources in the resource group that are **not** in the template:

| Mode | Resources in the template | Resources in the RG but missing from the template |
| --- | --- | --- |
| **Incremental** (default, recommended) | Create / update | **Left alone** |
| **Complete** | Create / update | **Deleted** |

Complete mode is an exam and production trap. Microsoft is steering deletions toward **deployment stacks**; do not casually use complete mode on a shared RG.

`what-if` (`az deployment group what-if` / `New-AzResourceGroupDeployment -WhatIf`) before you deploy. Always.

### ARM JSON → Bicep → imperative CLI

| ARM JSON | Bicep | Azure CLI / PowerShell (imperative, not IaC) |
| --- | --- | --- |
| `parameters` | `param` | `--name`, `--location` flags |
| `variables` | `var` | shell / PowerShell variables |
| `resources` | `resource` | `az group create`, `az storage account create`, … |
| `outputs` | `output` | `az ... show --query` |
| incremental deploy | same ARM engine | re-running ad-hoc `az` often errors or no-ops depending on the command |
| `az deployment group what-if` | same, `--template-file main.bicep` | N/A — that is the dry-run |
| `az group export` | `az bicep decompile` | N/A |

CLI is fine for one-off admin. It is not a template. Same environment twice → ARM JSON or Bicep.

---

## Enterprise scenarios (use these in interviews)

### 1. On-call at 02:00, personal laptop

You get paged. Corporate laptop is at home. Cloud Shell from the portal is the correct **interactive** tool: authenticated, no install, 15-minute investigation. You do **not** start a 40-minute ARM/Bicep deployment in that tab and walk away — idle timeout will kill it. You also do **not** paste the production kubeconfig into `$HOME` on a storage account the whole subscription can read.

### 2. Shared Cloud Shell storage

Platform team creates one storage account `stcloudshellshared` for 40 admins. SSH keys, copied secrets, and scripts now live in a file share that any Subscription Contributor can open. Fix: per-user storage, tight RBAC, no secrets in `clouddrive`, rotate anything that already landed there.

### 3. Three environments, one template

App team clicks a storage account + app insights in the portal for "dev." Staging does not match. Prod has a different SKU. Module 2's point: one template, three parameter files (`environment`, `location`, `sku`). Same resource names pattern via a variable. Outputs feed the app pipeline (storage account ID, connection string stored in Key Vault — not in the output log if you can avoid it).

### 4. Incremental leftover vs complete wipe

Someone deploys a VNet template incrementally, then later removes an NSG from the template and redeploys. **Incremental:** the NSG stays. Security review thinks it is gone. **Complete:** Resource Manager deletes everything in the RG that is not in the template — including the production database someone created by hand in the same RG. Lesson: dedicated RGs per workload, incremental + explicit deletes (or stacks), never complete mode on a junk-drawer RG.

---

## Exam traps from this path

1. Cloud Shell timeout is **idle**, not max session length.
2. Persistence requires an **Azure Files share**; ephemeral mode loses `$HOME`.
3. Cloud Shell compute is free; **storage is billed**.
4. Parameters = deploy-time input. Variables = author-time composition. Outputs = after-the-fact return values.
5. Idempotent ≠ "do nothing if it exists." It means **match the template**, including updates.
6. Incremental leaves extra RG resources. Complete deletes them.
7. `$schema` / `contentVersion` / resource `apiVersion` are three different things.

---

## Lab in this folder

`poc/` deploys a resource group (CLI/PowerShell) plus a StorageV2 account (ARM JSON or Bicep). Default is **what-if**. Apply only in a sandbox / dedicated RG. Incremental mode only.

```bash
cd 01-prerequisites/poc
./deploy.sh                          # Azure CLI, ARM JSON, what-if
TEMPLATE=bicep ./deploy.sh           # same desired state as Bicep
APPLY=1 ./deploy.sh                  # sandbox deploy
```

```powershell
cd 01-prerequisites/poc
./deploy.ps1                         # Azure PowerShell, ARM JSON, -WhatIf
./deploy.ps1 -Template bicep -Apply  # sandbox deploy via Bicep
```

Exam extras baked into the scripts after a real deploy:

- `az group export --name rg-pyxis-dev-prereq`
- `az bicep decompile --file azuredeploy.json`
