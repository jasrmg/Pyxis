# Module 3 (Core architectural components) — Quiz 3

Date issued: 2026-09-27
Scope: this module only — regions, region pairs, sovereign clouds, availability zones, resource groups, subscriptions, management groups, hierarchy, tags.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** items that inherit downward through the management-group → subscription → resource-group → resource hierarchy.

A. Resource tags applied on a parent scope
B. Azure RBAC role assignments
C. Azure Policy assignments
D. Cost Management tag inheritance written onto each resource's `tags` property
E. Nested resource groups created automatically under a parent resource group

---

**2.** For each statement, answer **Yes** or **No**.

1. Tagging a resource group with `env=prod` stamps `env=prod` onto every resource in that group.
2. Enabling Cost Management tag inheritance updates each child resource's `tags` property.
3. The built-in policy "Inherit a tag from the resource group" uses the `modify` effect.
4. A single resource can have at most 50 tags.

---

**3.** Exhibit — run against a new subscription:

```bash
az group create --name rg-app --location southeastasia --tags env=prod owner=platform
az network public-ip create \
  --resource-group rg-app --name pip-app --location eastus --sku Standard
az network public-ip show --resource-group rg-app --name pip-app \
  --query '{location:location, tags:tags}' -o json
```

What does the last command return?

A. `"location": "southeastasia"` and `"tags": {"env":"prod","owner":"platform"}`
B. `"location": "eastus"` and `"tags": {}`
C. `"location": "eastus"` and `"tags": {"env":"prod","owner":"platform"}`
D. The `public-ip create` line fails because the resource region differs from the resource group.

---

**4.** Complete each blank.

1. A region that supports availability zones has a minimum of ________ zones.
2. A region pair sits in the ________ geography and is typically at least ________ miles apart.
3. Management groups: up to ________ per directory, ________ levels of depth excluding the root, and ________ parent each.
4. Deleting a resource group ________ every resource inside it.

---

**5.** Put these scopes in order from **smallest** to **largest**.

- Subscription
- Child management group
- Resource
- Tenant root management group
- Resource group

Then, in one sentence, name what inherits downward at each hop, and name one thing that does **not**.

---

**6.** Case study — Fabrikam payments.

Requirements, all of which must be met at the **lowest cost**:

- The API must stay up if a single datacenter in West Europe fails.
- Customer card data must remain in West Europe. The regulator will not accept a copy in another country.
- Finance will not fund a second full compute footprint.
- A full-region outage may take up to 24 hours to recover.

Which design meets every requirement?

A. Deploy zone-redundant (or zonal across three zones) in West Europe only.
B. Active-active in West Europe and North Europe, the paired region.
C. Deploy in Azure Government, which provides zone redundancy by default.
D. Split the API across three subscriptions in West Europe, one per zone.

---

**7.** Exhibit — a subscription Contributor runs this after noticing Reader on every resource group:

```bash
az role assignment list --scope /subscriptions/6f1e8a52-c2a1 --include-inherited -o json
```

```json
[{
  "roleDefinitionName": "Reader",
  "scope": "/providers/Microsoft.Management/managementGroups/mg-corp",
  "principalName": "data-team@contoso.com"
}]
```

```bash
az role assignment delete --ids "/subscriptions/6f1e8a52-c2a1/providers/Microsoft.Authorization/roleAssignments/...."
```

The caller has **Owner on this subscription only**, not on `mg-corp`. What happens, and how is Reader actually removed from this subscription alone?

A. The delete succeeds for this subscription; other subscriptions under `mg-corp` keep Reader.
B. The delete fails because the assignment lives at `mg-corp`; move this subscription out from under `mg-corp`, or change the assignment there.
C. The delete converts the inherited Reader into a deny assignment at the subscription.
D. The delete succeeds and removes Reader from every subscription under `mg-corp`.

---

**8.** Exhibit — Azure PowerShell:

```powershell
New-AzResourceGroup -Name 'rg-web' -Location 'westeurope' -Tag @{ env = 'prod' }
New-AzPublicIpAddress -Name 'pip-web' -ResourceGroupName 'rg-web' `
  -Location 'northeurope' -Sku 'Standard' -AllocationMethod 'Static'
(Get-AzPublicIpAddress -Name 'pip-web' -ResourceGroupName 'rg-web').Tag
```

Finance then enables **Cost Management tag inheritance** on the billing account. After the next cost export, which statement is true?

A. `(Get-AzPublicIpAddress ...).Tag` now returns `env=prod`; the setting writes tags onto the resource.
B. The public IP still has no resource tags; cost records for it can show `env=prod` for reporting only.
C. The public IP is moved to `westeurope` so the tag can apply.
D. Cost Management inheritance fails unless the public IP is in the same region as the resource group.

---

**9.** Select the **two** true statements about region pairs.

A. You create a region pair as a resource in the subscription, then pick a partner region.
B. Azure applies platform updates to one region of a pair before the other.
C. Pairing automatically replicates every service's customer data to the partner region.
D. In a broad outage, one region of the pair is prioritized for recovery.
E. Region pairs are always placed in different geographies.

---

**10.** Exhibit — a deployment in an existing resource group:

```bash
az vm create --resource-group rg-pay --name vm-pay-07 \
  --image Win2022Datacenter --size Standard_D4s_v5 --location westeurope
# OperationCouldNotBeCompletedAsItResultsInExceedingQuota
# standardDSv5Family Cores, location westeurope
```

The caller is Owner. `what-if` on the template was clean. The VM must stay in West Europe this week.

Which action meets the requirement without changing the architecture?

A. Create a second subscription and deploy the VM there.
B. Request a quota increase for the DSv5 family in West Europe on this subscription.
C. Deploy the same VM size in North Europe, the paired region.
D. Move `rg-pay` to a new resource group in the same subscription.

---

## Submission — 2026-09-27

1. B, C
2. No, No, Yes, Yes
3. C
4. (1) 3 (2) same, 300 (3) 10,000, 6, 1 (4) deletes
5. resource → resource group → subscription → child management group → tenant root management group. RBAC inherits downward; tags do not.
6. A
7. B
8. B
9. B, D
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — RBAC and Policy inherit downward. Tags do not; Cost Management does not write the `tags` property; RGs cannot nest |
| 2 | Correct | No / No / Yes / Yes |
| 3 | **Wrong** | **B** — location is `eastus` (RG location is metadata only), and `tags` is empty. You kept the mixed-region fact and then re-applied tag inheritance on the same exhibit |
| 4 | Correct | 3 zones; same geography, 300+ miles; 10,000 / 6 / one parent; delete wipes the contents |
| 5 | Correct | Order is right. RBAC downward and tags not inherited is enough. Also say **Policy** and **locks** inherit, and an inherited assignment cannot be removed at the child |
| 6 | Correct | A — zones meet datacenter HA, residency, and cost. North Europe is Ireland, so B fails residency and doubles spend |
| 7 | Correct | B — the assignment object lives at `mg-corp`. A subscription-only Owner cannot delete it, and deleting it would hit every child anyway. Move the subscription, or change the assignment at the MG |
| 8 | Correct | B — Cost Management inheritance is reporting-only. The resource `tags` stay empty |
| 9 | Correct | B, D — sequential updates and prioritized recovery. You do not create a pair, and pairing does not replicate every service |
| 10 | Correct | B — per-subscription, per-region, per-family quota. A and C change the architecture; D does not move quota |

Q3 is the same misconception as Quiz 1 Q5, wearing a CLI exhibit. You stated the rule correctly on Q1, Q2, Q5, and Q8, then failed it when location and tags were in the same output. On the exam, treat each property independently: region can differ, tags still do not flow.
