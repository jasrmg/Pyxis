# Module 5 (Azure RBAC) — Quiz 1

Date issued: 2026-09-30
Scope: this module only — role assignments, built-in vs custom roles, scope, inheritance, Azure RBAC vs Entra roles vs Policy vs locks.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** roles that can create a role assignment at a subscription.

A. Contributor
B. Owner
C. Reader
D. User Access Administrator
E. Virtual Machine Contributor

---

**2.** For each statement, answer **Yes** or **No**.

1. A Global Administrator can manage every subscription in the tenant with no further Azure role assignment.
2. Azure RBAC honours nested security groups when you assign a role to the parent group.
3. A Contributor at a resource group can assign Reader on that same resource group.
4. An assignment created at a management group can be deleted from a child subscription's IAM blade by a subscription Owner.

---

**3.** Exhibit:

```bash
az role assignment create \
  --assignee maria@contoso.com \
  --role Contributor \
  --scope "/subscriptions/6f1e8a52-c2a1"
```

Maria must restart VMs in `rg-app` only, and must not create role assignments. What is wrong, and what is the least-privilege fix?

A. Nothing. Contributor at the subscription is the built-in role for VM restarts.
B. Scope is too wide and Contributor is the wrong role; assign Virtual Machine Contributor at `rg-app`.
C. Replace Contributor with Owner at `rg-app` so she can also lock the group.
D. Keep Contributor; change `--scope` to the tenant ID.

---

**4.** Complete each blank.

1. A role assignment is the triple ________ + ________ + ________.
2. Classic co-administrator is roughly equivalent to ________ at ________ scope only.
3. Elevating a Global Administrator for Azure access grants ________ at the ________ management group.
4. Control-plane operations in a custom role go in ________; blob/queue data-plane operations go in ________.

---

**5.** Put these scopes in order from **smallest** to **largest** for an Azure role assignment. Then name, in one sentence, whether a child can remove an assignment that was created above it.

- Subscription
- Resource
- Management group
- Resource group

---

**6.** Case study — Contoso.

All of the following must be met, lowest privilege:

- 12 production subscriptions under `mg-prod` need the data team to **read** every resource, including subscriptions added later.
- The platform team must **grant and revoke Azure roles** on those subscriptions but must **not** deploy resources.
- An API running on a VM in `rg-pay` must **read blobs** in one storage account. No user password in the app.

A. Reader at each subscription for the data team; Owner at `mg-prod` for platform; storage account key in the VM.
B. Reader at `mg-prod` for a data-team group; User Access Administrator at `mg-prod` for a platform group; role on the VM's **managed identity** at the storage account.
C. Reader at `mg-prod`; Owner at `mg-prod` for platform; Reader on the storage account for a user account used by the API.
D. Contributor at `mg-prod` for both teams; `notScopes` on `rg-pay`.

---

**7.** Exhibit — a subscription Owner runs:

```bash
az role assignment list --scope /subscriptions/6f1e8a52-c2a1 --include-inherited -o json
```

```json
[{
  "roleDefinitionName": "Reader",
  "principalName": "data-team@contoso.com",
  "scope": "/providers/Microsoft.Management/managementGroups/mg-corp"
}]
```

They then run `az role assignment delete` against that assignment id. They have Owner on the subscription only. Result?

A. Reader is removed from this subscription; other subscriptions under `mg-corp` keep it.
B. The delete fails because the assignment lives at `mg-corp`.
C. The delete succeeds and removes Reader from every child of `mg-corp`.
D. Inherited assignments convert to deny assignments at the subscription.

---

**8.** Exhibit — custom role fragment:

```json
{
  "Name": "VM Restart Only",
  "Actions": [
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/restart/action"
  ],
  "NotActions": [],
  "DataActions": [],
  "AssignableScopes": [
    "/subscriptions/6f1e8a52-c2a1/resourceGroups/rg-other"
  ]
}
```

You try to assign this role at `rg-app` in the same subscription. What happens?

A. The assignment succeeds; `AssignableScopes` is documentation only.
B. The assignment fails because `rg-app` is not under `AssignableScopes`.
C. The assignment succeeds but only the `read` action is granted.
D. Custom roles cannot be assigned at resource group scope.

---

**9.** Select the **two** correct statements.

A. Azure Policy `deny` and an Azure RBAC deny assignment are the same object.
B. A resource lock `CanNotDelete` stops deletion even if the caller is Contributor.
C. Assigning an Entra User Administrator role lets that person create resource groups in Azure.
D. A managed identity can be the principal on an Azure role assignment.
E. Reader can view role assignments and add new ones at the same scope.

---

**10.** Exhibit — Bicep:

```bicep
resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userObjectId, readerRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: readerRoleId
    principalId: userObjectId
  }
}
```

The deploying identity is **Contributor** on the resource group. What happens?

A. The user receives Reader on the resource group.
B. The deployment fails because Contributor cannot create role assignments.
C. The user receives Contributor; Reader is ignored on a Contributor deploy.
D. The assignment is created at the subscription because `scope` is ignored.

---

## Submission — 2026-09-30

1. B, D
2. Yes, Yes, No, No
3. B
4. (1) idk (2) User Access Administrator, resource (3) idk (4) idk
5. resource → RG → subscription → management group. Child cannot remove inherited assignments.
6. B
7. B
8. B
9. B, D
10. B

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 5 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — Owner and User Access Administrator. Contributor cannot assign roles |
| 2 | **Wrong** | **No** / Yes / No / No — Global Admin does **not** get Azure resource access until you assign an Azure role or they **elevate** (UAA at root). Nested groups: yes. Contributor cannot assign. Inherited delete at child: no |
| 3 | Correct | B — VM Contributor at `rg-app` |
| 4 | **Wrong** | principal + role + **scope**; co-admin ≈ **Owner** at **subscription** only; elevate → **User Access Administrator** at the **root** MG; **Actions** / **DataActions** |
| 5 | Correct | Smallest to largest; inherited assignment changes where it was created |
| 6 | Correct | B — Reader at MG; UAA at MG (not Owner); managed identity at the storage account |
| 7 | Correct | B — assignment lives at `mg-corp` |
| 8 | Correct | B — `AssignableScopes` is enforced |
| 9 | Correct | B, D — locks are not RBAC but they still block Contributor delete; a managed identity is a valid principal |
| 10 | Correct | B — same fact as Q1: Contributor cannot write role assignments |

The operational items (least privilege, inheritance, AssignableScopes, locks vs RBAC, Bicep) landed. The blanks are the **plane split**: Entra Global Admin vs Azure Owner, and the assignment triple.

### Q2 statement 1 — Global Admin is not Owner

Directory role ≠ Azure role. With no Azure assignment and with elevation **off**, a Global Admin cannot even Reader a subscription. Elevation is a **toggle** that grants **User Access Administrator** at the **tenant root management group** so they can then assign Azure roles. It does not make them Owner, and you turn it off after the break-glass.

### Q4 — four facts, all in the notes exam-traps list

| Blank | Your answer | Key |
| --- | --- | --- |
| The assignment triple | (blank) | **principal + role definition + scope** |
| Classic co-admin | UAA at resource | **Owner**, at **subscription** only. Cannot be scoped to an RG |
| Elevate Global Admin | (blank) | **User Access Administrator** at the **root** management group |
| Custom role arrays | (blank) | **Actions** (control plane) / **DataActions** (blobs, queues, …) |

Co-admin is the trap that looks like UAA. Co-admin is the old “Owner of the whole subscription.” UAA is the modern “can assign Azure roles, cannot deploy.”
