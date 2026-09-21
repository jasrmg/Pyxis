# 01 Prerequisites — Quiz 1

Date issued: 2026-09-21  
Time: untimed. Closed notes if you want this to mean anything.  
Pass: **9/10**. Wrong terminology counts as wrong.

Reply in this chat as `1. …` through `10. …`. Do not ask me to hint. I will grade after you submit.

---

**1.** You open Cloud Shell from the Azure portal on a hotel laptop. Which statement is accurate?

A. Cloud Shell is an unauthenticated Linux VM you SSH into; you then run `az login`.  
B. Cloud Shell is a Microsoft-managed, already-authenticated terminal running as **your** Entra ID identity, with Bash or PowerShell.  
C. Cloud Shell is Azure CLI installed in the browser; PowerShell is not available.  
D. Cloud Shell is a persistent jump box billed as a B-series VM until you deallocate it.

**2.** You start a 45-minute `az` script in Cloud Shell. The script prints nothing for 25 minutes, then would write a result. What happens?

A. Cloud Shell allows 20 minutes of **total** runtime, so the session is already dead.  
B. Cloud Shell never times out while a process is running, even if the process is silent.  
C. Cloud Shell times out after **20 minutes with no interactive activity**; a silent job can look idle and the session can die before minute 45.  
D. Cloud Shell times out only if you close the browser tab.

**3.** First Cloud Shell launch: you choose an **ephemeral** session and save a script at `~/runbook.sh`. You close the tab, open Cloud Shell again the next day. Where is the file?

A. In `$HOME`, because `$HOME` is always a 5 GB disk image.  
B. In `$HOME/clouddrive`, because Cloud Shell always mounts Azure Files.  
C. Gone. Ephemeral sessions do not persist `$HOME` or `clouddrive`.  
D. In the storage account named `cloudshell` in `East US`, regardless of your choice.

**4.** You **did** mount storage. Where do SSH keys in `$HOME/.ssh` actually live across sessions, and where do files you copy to `clouddrive` live?

A. Both live only in the container’s ephemeral disk.  
B. `$HOME` is persisted as a disk image on the Azure Files share; `clouddrive` is that same share mounted as a folder.  
C. `$HOME` is Blob Storage; `clouddrive` is Azure Files.  
D. `$HOME` is local browser storage; `clouddrive` is OneDrive.

**5.** Platform team says “Cloud Shell is free, so we will give 40 admins one shared storage account.” Pick the **best** architect response.

A. Correct — compute and storage are both free.  
B. Compute host is free; the Azure Files share is billed. A shared share plus subscription-level RBAC often lets others read `$HOME` (keys, tokens). Use per-user storage.  
C. Storage is free; only egress is billed. Sharing one account is required so Bash and PowerShell stay in sync.  
D. Correct as long as everyone uses PowerShell, because Bash cannot see the share.

**6.** In an ARM template, which mapping is correct?

A. `parameters` = computed inside the template; `variables` = supplied at deploy time; `outputs` = resource SKUs.  
B. `parameters` = supplied at deploy time; `variables` = computed inside the template; `outputs` = returned after a successful deployment.  
C. `contentVersion` = the resource provider API version; `apiVersion` on a resource = your template version string.  
D. `$schema` is optional; `resources` may omit `apiVersion` if `contentVersion` is set.

**7.** You need a storage account named `st{env}logs` where `env` is `dev` or `prod`, and after deploy the app pipeline needs the account resource ID.

- `env` should be a ________  
- the concatenated name `st{env}logs` should be a ________  
- the resource ID handed to the pipeline should be a ________  

Fill the three blanks with **parameter**, **variable**, or **output**. Each used once.

**8.** You deploy an ARM template that creates storage account `stlogs001` with TLS 1.2. The account already exists with TLS 1.0. Incremental mode. What does Resource Manager do?

A. No-op, because the resource already exists (idempotent means never touch existing resources).  
B. Create a second storage account with a generated suffix.  
C. **Update** the existing account to match the template (TLS 1.2), assuming the property is updatable.  
D. Fail, because you cannot change any property of an existing resource; you must delete it first.

**9.** Resource group `rg-app` contains a VNet (in the template) and a hand-created SQL server (not in the template). You redeploy the template.

- Incremental mode: what happens to the SQL server?  
- Complete mode: what happens to the SQL server?

One sentence each. “Left alone” / “deleted” is acceptable if you name the mode.

**10.** Which pair is an AZ-104-legal way to **preview** then **convert** a deployment?

A. `terraform plan` then `terraform show`  
B. `az deployment group what-if` (or `New-AzResourceGroupDeployment -WhatIf`), then `az group export` and `az bicep decompile`  
C. `az group create --what-if` then `az bicep build` only  
D. Portal “Create” with no validation; conversion is not in the exam skills

---

## Submission — 2026-09-21

1. B  
2. A  
3. C  
4. B  
5. B  
6. B  
7. variable, parameter, output  
8. C  
9. Incremental: will create the SQL server. Complete: will delete the VNet and create the SQL server.  
10. B

## Score: 7/10 (70%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Path 01 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B |
| 2 | **Wrong** | C — idle timeout, not max runtime |
| 3 | Correct | C |
| 4 | Correct | B |
| 5 | Correct | B |
| 6 | Correct | B |
| 7 | **Wrong** | parameter, variable, output |
| 8 | Correct | C |
| 9 | **Wrong** | Incremental: SQL left alone. Complete: SQL deleted. VNet stays in both (it is in the template). |
| 10 | Correct | B |

### Miss 2 — idle vs runtime

You picked A (20 minutes of **total** runtime). That is the same error as the interview. Cloud Shell kills the session after **20 minutes with no interactive activity**. A silent 45-minute script can look idle and die. A chatty 45-minute script can survive. The clock is idle time, not wall-clock job length.

### Miss 7 — parameter vs variable

`env` is **dev or prod** → the deployer changes it → **parameter**.  
`st{env}logs` is concatenated **inside** the template → **variable**.  
Resource ID after success → **output**.

You swapped the first two. Rule: if the caller must set it, it is not a variable.

### Miss 9 — incremental vs complete (backwards)

The VNet **is in the template**. The SQL server **already exists and is not in the template**. Redeploy does not "create SQL."

- **Incremental:** SQL is **left alone**. VNet is created or updated. Extra RG resources survive.
- **Complete:** SQL is **deleted** (not in the template). VNet is created or updated (it is in the template). Complete does **not** delete the VNet.

You described the opposite of both modes. This is an exam item and a production outage if you guess Complete wrong.

### What you actually know

Cloud Shell identity, ephemeral vs mounted storage, `$HOME` image vs `clouddrive`, billing/RBAC on the share, ARM section roles, idempotent **update** of TLS, what-if + export + decompile.

### Remediation

Re-read `01-prerequisites/README.md` sections: idle timeout, parameter vs variable vs output, incremental vs complete (enterprise scenario 4). Then retake with `/quiz`. Same pass line.
