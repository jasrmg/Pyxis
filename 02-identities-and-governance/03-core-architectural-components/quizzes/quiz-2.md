# Module 3 (Core architectural components) — Quiz 2 (retake)

Date issued: 2026-09-22  
Prerequisite: Quiz 1 scored 8.5/10 FAIL (tag inheritance, inheritance direction). New items, same scope.  
Pass: **9/10**. Closed notes.

Reply `1.` through `10.` in chat. I grade after you submit.

---

**1.** Exhibit — `rg-web` is tagged, then a storage account is created inside it:

```bash
az group create --name rg-web --location eastus --tags env=prod owner=platform
az storage account create --name stwebprod001 --resource-group rg-web --location eastus --sku Standard_LRS
az resource show --name stwebprod001 --resource-group rg-web \
  --resource-type Microsoft.Storage/storageAccounts --query tags
```

What does the last command return, and why?

A. `{ "env": "prod", "owner": "platform" }` — resources inherit their RG's tags.  
B. `{}` or null — **tags are not inherited** from a resource group. Tag the resource directly, or use the Azure Policy **"Inherit a tag from the resource group"** (`modify` effect).  
C. An error — you must tag a resource at creation time or never.  
D. `{ "env": "prod" }` only — `owner` is reserved for the RG.

---

**2.** An Owner assignment was made at the **management group** `mg-corp`. A subscription owner underneath wants it gone from **their** subscription only. What do you tell them?

A. Remove it in the subscription's Access control (IAM) blade; child scopes override parents.  
B. Inherited assignments **cannot be removed at the child scope** — the assignment has to be changed **where it was created** (the management group), or the subscription has to be moved out from under it.  
C. Apply a Deny assignment at the resource group to cancel it.  
D. Inheritance only applies to Azure Policy, so nothing needs to happen.

---

**3.** Which describes **zonal**, **zone-redundant**, and **always available**, in that order?

A. Platform spreads it across zones / you pin it to one zone / regional only.  
B. **You pin the resource to a specific zone** / **the platform spreads it across zones for you** / **global, non-regional services** like Entra ID, Azure DNS, and Traffic Manager.  
C. Paired-region replication / same-zone replication / on-premises only.  
D. All three mean the same thing with different billing tiers.

---

**4.** A regional outage takes down all of West Europe. The workload was deployed across **all three availability zones** in that region. Outcome and correct fix?

A. It stays up; three zones equal regional redundancy.  
B. It is **down** — zones protect against a **datacenter** failure inside a region, not against the region itself. Regional survival needs a **second region**, typically the **paired region**.  
C. It stays up if the storage account is ZRS.  
D. It stays up because Azure fails zones over to the paired region automatically.

---

**5.** Exhibit:

```bash
az group delete --name rg-sandbox --yes
```

`rg-sandbox` holds 6 test VMs and one production SQL database someone created by hand last month. What happens, and what is the governance lesson?

A. Only the VMs are deleted; databases are protected by default.  
B. The command fails because the RG contains resources from different workloads.  
C. **Everything in the RG is deleted, including the production database.** The resource group **is** the blast radius — one RG per workload/lifecycle, and put a **lock** on anything that must survive human error.  
D. The database is moved to the default resource group automatically.

---

**6.** Which statement about resources and resource groups is **true**?

A. A resource can belong to two resource groups if they are in the same subscription.  
B. Resource groups can be nested up to 3 levels.  
C. A resource belongs to **exactly one** RG, **can be moved** to another RG or subscription (if the resource type supports move), and resources in one RG **may be in different regions**.  
D. Changing a resource group's location moves every resource inside it to that region.

---

**7.** Match each need to the right boundary.

- Separate the finance department's bill and give them their own quota headroom → ________  
- Group 30 subscriptions so one Policy assignment covers all of them → ________  
- Contain one application's resources so they can be deleted together → ________

A. subscription / management group / resource group  
B. resource group / subscription / management group  
C. management group / subscription / resource group  
D. subscription / resource group / management group

---

**8.** Exhibit:

```bash
az account list-locations \
  --query "[?name=='southeastasia'].{region:name, paired:metadata.pairedRegion[0].name}" -o table
# Region          Paired
# southeastasia   eastasia
```

Which two statements about this pairing are correct?

A. The pair is in a different geography, and both regions receive platform updates at the same time.  
B. The pair is in the **same geography**, and Azure applies platform updates **sequentially** across the pair; one region is also **prioritized for recovery** in a broad outage.  
C. Pairing means data is automatically replicated for every service in the subscription.  
D. Pairing is editable — you can repoint `southeastasia` to `australiaeast`.

---

**9.** Exhibit — building a hierarchy:

```bash
az account management-group create --name mg-corp --display-name "Corporate"
az account management-group create --name mg-prod --display-name "Production" --parent mg-corp
az account management-group subscription add --name mg-prod --subscription 6f1e...c2a1
```

Assuming permissions are fine, what is the result, and what limits apply to this structure?

A. Fails — subscriptions can only attach to the root management group.  
B. **Succeeds.** Limits: up to **10,000** management groups per directory, **6 levels** of depth excluding the **root**, and each management group or subscription has **exactly one parent**.  
C. Succeeds, but the subscription now has two parents: `mg-prod` and the root.  
D. Fails — `--parent` must be a fully qualified resource ID, never a name.

---

**10.** Which single statement is **true**?

A. Azure Government and Azure China 21Vianet are ordinary regions inside the global Azure cloud.  
B. Every Azure service is available in every region, so region choice is purely about latency.  
C. **Sovereign clouds (Azure Government, Azure China) are separate instances of Azure** with their own compliance boundary and feature availability, and service availability varies by region in the public cloud too.  
D. Region pairs are always in different geographies to maximize the distance between them.

---

## Submission — 2026-09-22

1. B  
2. B  
3. B  
4. B  
5. C  
6. C  
7. A  
8. B  
9. B  
10. C

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B — tags are not inherited; use the `modify` policy |
| 2 | Correct | B — inherited assignments change at the scope where they were created |
| 3 | Correct | B — zonal / zone-redundant / always available |
| 4 | Correct | B — zones ≠ regional DR |
| 5 | Correct | C — RG is the blast radius; lock what must survive |
| 6 | Correct | C — one RG per resource, movable, mixed regions allowed |
| 7 | Correct | A — subscription / management group / resource group |
| 8 | Correct | B — same geography, sequential updates, prioritized recovery |
| 9 | Correct | B — 10,000 groups, 6 levels excluding root, one parent |
| 10 | Correct | C — sovereign clouds are separate Azure instances |

Both Quiz 1 misses are closed: tag inheritance (Q1) and the direction/immutability of inherited assignments (Q2). Module 3 passed and checked off.

Path 02 modules 1–3 complete. Next: Learn modules 4 (Azure Policy initiatives), 5 (Azure RBAC), 6 (SSPR).

