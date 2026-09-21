# 01 Prerequisites — Quiz 2 (retake)

Date issued: 2026-09-21  
Prerequisite: Quiz 1 7/10 FAIL. This is a new paper, not the same items.  
Pass: **9/10**. Wrong terminology counts as wrong.

Reply in this chat as `1. …` through `10. …`. I grade after you submit.

---

**1.** You switch Cloud Shell from Bash to PowerShell. Which statement is true?

A. Cloud Shell starts a Windows VM running Windows PowerShell 5.1.  
B. You get PowerShell on the **same Linux container**; you are still signed in as yourself.  
C. PowerShell and Bash cannot share persisted files; each needs its own storage account.  
D. Switching shells requires `az login` again because the token is shell-specific.

**2.** On-call at 02:00. You need a 5-minute `az resource list` from an airport PC. Tomorrow you need a 90-minute ARM deploy that is quiet for long stretches. Where does each job belong?

A. Both in Cloud Shell, because the 20-minute limit is total runtime and 5 minutes is under it.  
B. The 5-minute interactive check in Cloud Shell; the 90-minute quiet deploy on a workstation or pipeline, because Cloud Shell dies after **20 minutes idle**, not 20 minutes of work.  
C. Both on a local workstation; Cloud Shell cannot run Azure CLI.  
D. The 90-minute deploy in Cloud Shell (it never times out if `az` is the parent process); the 5-minute check in the portal only.

**3.** An admin with **Contributor on the subscription** (not on a specific storage account) asks whether they can open another engineer’s Cloud Shell Azure Files share. Best answer?

A. No. Cloud Shell encryption at rest means only the session owner can read the share.  
B. Often **yes**. Subscription-level rights commonly inherit to the share. Treat `$HOME` as readable by other privileged identities. Per-user storage accounts.  
C. Only if they use Bash; PowerShell ACLs block subscription Contributors.  
D. Only after they run `az login --identity` inside that engineer’s Cloud Shell.

**4.** Match the ARM field to its job.

- `$schema`  
- `contentVersion`  
- a resource’s `apiVersion`  

Which mapping is correct?

A. `$schema` = your template version string (`1.0.0.0`); `contentVersion` = resource-provider contract; `apiVersion` = JSON schema URL.  
B. `$schema` = JSON schema URL (and implies deployment scope); `contentVersion` = **your** template version string; `apiVersion` = resource-provider contract for that resource.  
C. All three are Microsoft-controlled and must be identical in a template.  
D. `apiVersion` is optional if `$schema` is 2019-04-01.

**5.** Template deploys App Service in `eastus` for test and `westeurope` for prod. The app name is `app-contoso-{env}`. After deploy, the pipeline needs the default hostname.

Assign **parameter**, **variable**, or **output** (each once):

- `env` and `location` → ________  
- `app-contoso-{env}` → ________  
- default hostname → ________

**6.** An ARM template specifies VM size `Standard_D2s_v3`. The VM already exists as `Standard_D2s_v3`. You deploy again, incremental, no other changes. Then you change the template location from `eastus` to `westus` and deploy again. What happens?

A. First deploy duplicates the VM; second deploy moves it to `westus`.  
B. First deploy is a **no-op**; second deploy **fails** (you cannot change location/type of an existing resource in place).  
C. First deploy is a no-op; second deploy updates location in place.  
D. Both deploys fail because incremental mode never updates existing resources.

**7.** `rg-web` already has an NSG created by hand. Your template deploys a VNet only (no NSG). You run **incremental**. Then a teammate runs the **same template** with **complete** mode.

A. Incremental deletes the NSG; complete recreates it.  
B. Incremental leaves the NSG; complete **deletes** the NSG because it is not in the template. The VNet is created/updated in both.  
C. Both modes delete the NSG.  
D. Both modes leave the NSG; complete only deletes resources that are in the template.

**8.** Why is complete mode dangerous on a shared “playground” resource group that also holds a production database someone created in the portal?

A. Complete mode never deletes anything; the danger is only cost.  
B. Complete mode deletes RG resources **not listed in the template**, so the database can disappear even though the template never mentioned it.  
C. Complete mode deletes only resources that **are** in the template, so the VNet goes and the database stays.  
D. Complete mode converts the RG to a management group.

**9.** You have `azuredeploy.json` already deployed. Which sequence matches AZ-104 skills measured?

A. `az deployment group what-if` to preview a change; `az group export` to dump ARM JSON; `az bicep decompile` to get Bicep.  
B. `az bicep build` to preview; `terraform plan` to convert.  
C. `az group create --what-if` then `az bicep decompile` on the resource group name.  
D. Portal delete + recreate; export is not on the exam.

**10.** Cloud Shell with **mounted** storage. You put `id_rsa` in `~/.ssh/` and `notes.md` in `~/clouddrive/`. You sign out for a week, then open Cloud Shell (Bash, then PowerShell). What still exists?

A. Neither file; mounted storage only lasts 20 minutes.  
B. `notes.md` only; `~/.ssh` is always ephemeral.  
C. Both: `~/.ssh` lives in the `$HOME` disk image on the share; `notes.md` lives on the share via `clouddrive`. Both shells use that same share.  
D. Both, but only in Bash; PowerShell gets a different empty `$HOME`.

---

## Submission — 2026-09-21

1. B  
2. B  
3. B  
4. B  
5. parameter, variable, output  
6. B  
7. B  
8. B  
9. A  
10. C

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B |
| 2 | Correct | B — idle timeout, not max runtime |
| 3 | Correct | B |
| 4 | Correct | B |
| 5 | Correct | parameter, variable, output |
| 6 | Correct | B — no-op, then location change fails |
| 7 | Correct | B — incremental leaves NSG; complete deletes it |
| 8 | Correct | B |
| 9 | Correct | A |
| 10 | Correct | C |

Quiz 1 misses (idle vs runtime, parameter vs variable, incremental vs complete) are closed on this paper. Path 01 is checked off.
