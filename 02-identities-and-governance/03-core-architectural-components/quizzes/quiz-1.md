# Module 3 (Core architectural components) — Quiz 1

Date issued: 2026-09-22  
Scope: this module only — regions, region pairs, sovereign regions, availability zones, datacenters, resources, resource groups, subscriptions, management groups, hierarchy.  
Pass: **9/10**. Closed notes.

Reply `1.` through `10.` in chat. I grade after you submit.

---

**1.** Exhibit:

```bash
az group create --name rg-app --location southeastasia
az network public-ip create --resource-group rg-app --name pip-app --location eastus
```

Result?

A. Fails — a resource must be in the same region as its resource group.  
B. **Succeeds.** The RG location only stores the group's **metadata**; resources inside an RG can live in **different regions**.  
C. Succeeds, but the public IP is silently recreated in `southeastasia`.  
D. Fails unless the RG is created with `--location global`.

---

**2.** Order these scopes smallest to largest, and state which direction RBAC and Azure Policy assignments inherit.

`subscription`, `resource`, `management group`, `resource group`

---

**3.** A data team needs **Reader** across **14 subscriptions**, and more subscriptions are coming next quarter. Least-effort correct design?

A. Assign Reader 14 times, once per subscription, and repeat for new ones.  
B. Place the subscriptions under a **management group** and assign Reader **once at the management group**; new child subscriptions inherit automatically.  
C. Assign Reader at the root of each subscription's default resource group.  
D. Create a single subscription and merge all 14 into it.

---

**4.** Exhibit:

```bash
az group show --name rg-app --query tags
# { "env": "prod", "owner": "platform", "costCenter": "CC-4471" }

az tag update --resource-id /subscriptions/.../resourceGroups/rg-app \
  --operation Replace --tags reviewed=2026-09
```

What are the tags on `rg-app` afterward, and which operation was intended?

A. All four tags; `Replace` appends.  
B. Only `reviewed=2026-09` — **`Replace` drops every tag you did not list**. The intent was **`Merge`**.  
C. The original three; `Replace` is rejected without `--force`.  
D. `reviewed=2026-09` plus `env=prod`, because `env` is a reserved governance tag.

---

**5.** True or false, with the reason: a resource group can contain another resource group, and tags applied to a resource group are automatically inherited by the resources inside it.

---

**6.** The business asks for "high availability." Match the requirement to the correct construct.

- Survive the loss of a single **datacenter** within the region → ________  
- Survive the loss of the **entire region** → ________

A. availability zones / a second region, ideally the **paired region**  
B. region pairs / availability zones  
C. a second subscription / a second resource group  
D. zone-redundant storage / a second availability zone in the same datacenter

---

**7.** Which set of facts about **region pairs** is correct?

A. Pairs are in different geographies, ~30 miles apart, and update simultaneously for consistency.  
B. Pairs are in the **same geography**, typically **at least 300 miles apart**, receive **sequential** platform updates, and one region is **prioritized for recovery** in a broad outage.  
C. Pairs exist only for Azure Government and Azure China.  
D. Pairing is configured per subscription in the portal.

---

**8.** A deployment fails at 40 vCPUs in West Europe. RBAC is Owner, the template validated, and `what-if` looked clean. Most likely cause and where the limit lives?

A. A missing Azure Policy exemption at the management group.  
B. A **per-subscription quota/limit** for that region. Request an increase, deploy to another region, or split into another subscription.  
C. The resource group ran out of capacity; create a second RG.  
D. Availability zones are exhausted in that region.

---

**9.** Exhibit:

```bash
az account management-group create --name "Corp Production" --parent mg-corp
az account management-group show --name "Corp Production"
```

What is wrong here?

A. Nothing; display names are valid for `--name`.  
B. `--name` is the management group **ID/name**, not the display name. Use something like `--name mg-corp-prod --display-name "Corp Production"`; `show` also requires the **name**, not the display name.  
C. `--parent` must be a subscription ID.  
D. Management groups cannot be created with the CLI, only with PowerShell.

---

**10.** Which statement about the management group hierarchy is **true**?

A. A subscription may have multiple parent management groups for flexible reporting.  
B. The tree supports unlimited depth, and there is no root management group.  
C. Up to **10,000** management groups per directory, **6 levels** of depth excluding the **root**, and each management group or subscription has **exactly one parent**.  
D. Management groups sit below subscriptions and above resource groups.

---

## Submission — 2026-09-22

1. B  
2. resource, resource group, subscription, management group  
3. B  
4. B  
5. "A resource group can't contain another resource group, it can contain resources only. Tags applied to RG is inherited by the resources, yes"  
6. A  
7. B  
8. B  
9. B  
10. C

## Score: 8.5/10 (85%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 3 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B — RG location is metadata only |
| 2 | **Half credit** | Order correct. Did not state that assignments inherit **downward** |
| 3 | Correct | B — assign once at the management group |
| 4 | Correct | B — `Replace` drops unlisted tags; `Merge` was intended |
| 5 | **Wrong** | RG nesting: correct. **Tag inheritance: wrong — tags are NOT inherited** |
| 6 | Correct | A — zones for datacenter loss, second/paired region for region loss |
| 7 | Correct | B |
| 8 | Correct | B — per-subscription quota |
| 9 | Correct | B — `--name` is the ID, not the display name |
| 10 | Correct | C — 10,000 groups, 6 levels excluding root, one parent |

### Q2 — the order was right, the inheritance clause was missing

`resource < resource group < subscription < management group` is correct.

The question also asked for the direction. **RBAC role assignments and Azure Policy assignments inherit downward** — from management group to subscription to resource group to resource. Consequences worth saying out loud in an interview:

- An assignment made at a parent scope **cannot be removed at the child**. You change it where it was assigned.
- So assign at the **smallest scope that does the job** (least privilege), because anything you grant high up lands on everything below it.

### Q5 — tags are not inherited, and this one matters

Half of your answer is right: **resource groups cannot be nested**, and they contain resources only.

The second half is a real misconception. **A resource does not inherit tags from its resource group or subscription.** Tag `env=prod` on `rg-app` and the VM inside it has **no** tags. That is why "apply and manage tags on resources" is a named exam skill with a policy attached to it.

How inheritance is actually achieved:

- **Azure Policy** — the built-in **"Inherit a tag from the resource group"** policy uses the **`modify`** effect to stamp the tag onto resources. That is a deliberate policy assignment, not default behavior. (Policy is module 4, so you will meet this again.)
- **Azure Cost Management tag inheritance** — a billing setting that applies RG/subscription tags to child resources' **cost records** for reporting. It does not change the resource's actual tags.

Two more tag facts on the exam: not every resource type supports tags, and a resource is limited to **50** tags.

### Remediation

Re-read `../README.md`, specifically the hierarchy section (inheritance direction) and the tag lines in the Q&A above. Then take the retake.

