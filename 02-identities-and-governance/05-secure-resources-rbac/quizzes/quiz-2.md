# Module 5 (Azure RBAC) — Quiz 2

Date issued: 2026-09-30
Prerequisite: Quiz 1 scored 8/10 FAIL (Global Admin ≠ Azure access; assignment triple; co-admin; elevate = UAA at root; Actions vs DataActions).
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A Global Administrator can create resource groups in every subscription by default.
B. Elevating access for a Global Administrator grants User Access Administrator at the root management group.
C. After elevation, the Global Administrator is Owner on every subscription until they sign out.
D. With elevation off, a Global Administrator still needs an Azure role assignment (or a group that has one) to manage a subscription.
E. User Administrator in Entra ID can assign the Azure Owner role at a subscription.

---

**2.** For each statement, answer **Yes** or **No**.

1. Classic co-administrator can be scoped to a single resource group.
2. Classic co-administrator is roughly equivalent to Owner at subscription scope.
3. `DataActions` in a custom role cover blob and queue data-plane operations.
4. `Actions` in a custom role cover ARM control-plane operations such as restarting a VM.

---

**3.** Exhibit — Ben is **Contributor** on `rg-web`. He must grant the `Web-Readers` group **Reader** on that resource group.

```bash
az role assignment create \
  --assignee "Web-Readers" \
  --role Reader \
  --scope "/subscriptions/6f1e8a52-c2a1/resourceGroups/rg-web"
```

What is the result for Ben?

A. Succeeds; Contributor may assign Reader at the same resource group.
B. Fails; Contributor cannot create role assignments.
C. Succeeds only if `Web-Readers` is a Microsoft 365 group.
D. Fails because `--assignee` cannot be a group; use `--assignee-object-id` only for users.

---

**4.** Complete each blank.

1. An Azure role assignment is ________ + ________ + ________.
2. Elevating a Global Administrator grants the Azure role ________ at the ________ management group.
3. Classic co-administrator ≈ ________, and only at ________ scope.
4. Custom role: restart a VM goes in ________; read a blob goes in ________.

---

**5.** A Global Administrator has **not** elevated access and holds **no** Azure role. Put the **minimum** steps in order so she can assign Reader on one subscription, then stop having standing Azure access.

- Assign Reader to the data-team group at that subscription.
- Turn off Access management for Azure resources (elevation).
- Turn on Access management for Azure resources (elevation).
- Sign in as Global Administrator.

---

**6.** Case study — Fabrikam. Lowest privilege that meets **all**:

- Helpdesk restarts VMs in `rg-app` only.
- A contractor must not create role assignments.
- Classic co-admin on the subscription is considered too wide and must not be used.

A. Make the helpdesk co-administrators on the subscription.
B. Virtual Machine Contributor at `rg-app` for a helpdesk security group.
C. Contributor at the subscription for each helpdesk user.
D. Owner at `rg-app` so they can also assign Reader if needed.

---

**7.** Exhibit — PowerShell:

```powershell
New-AzRoleAssignment -ObjectId $miPrincipalId `
  -RoleDefinitionName 'Storage Blob Data Reader' `
  -Scope '/subscriptions/.../resourceGroups/rg-pay/providers/Microsoft.Storage/storageAccounts/stpay001'
```

What is `$miPrincipalId`, and why is this scope correct?

A. A user's object ID; storage roles must be assigned at the subscription.
B. The VM's **managed identity** object ID; the role is data-plane, so the scope is the storage account.
C. The storage account resource ID; `-Scope` should be the resource group.
D. A Global Administrator object ID; blob roles can only be assigned to Entra roles.

---

**8.** Exhibit — custom role:

```json
{
  "Actions": [ "Microsoft.Storage/storageAccounts/read" ],
  "DataActions": [ "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read" ],
  "AssignableScopes": [ "/subscriptions/6f1e8a52-c2a1" ]
}
```

A user assigned this role at the subscription. They call `Get-AzStorageAccount` and then download a blob. Which calls succeed?

A. Both fail; custom roles cannot mix `Actions` and `DataActions`.
B. Account read succeeds; blob download succeeds.
C. Account read succeeds; blob download fails because `DataActions` are ignored at subscription scope.
D. Account read fails; blob download succeeds.

---

**9.** Select the **two** commands that list assignments **including** those inherited from a management group.

A. `az role assignment list --scope /subscriptions/<id>`
B. `az role assignment list --scope /subscriptions/<id> --include-inherited`
C. `az role assignment list --scope /subscriptions/<id> --include-groups`
D. `Get-AzRoleAssignment -Scope /subscriptions/<id>`
E. `az policy assignment list --scope /subscriptions/<id> --include-inherited`

---

**10.** Exhibit — which **one** line must change so Maria can restart VMs in `rg-app` and still cannot assign roles?

```powershell
New-AzRoleAssignment -SignInName maria@contoso.com `
  -RoleDefinitionName 'Contributor' `
  -Scope '/subscriptions/6f1e8a52-c2a1'
```

A. Change `Contributor` to `Owner` and keep the subscription scope.
B. Change `Contributor` to `Virtual Machine Contributor` and change `-Scope` to the `rg-app` resource ID.
C. Change `Contributor` to `User Access Administrator` and keep the subscription scope.
D. Change `-SignInName` to `-ObjectId` only; the role and scope are already least privilege.

---

## Submission — 2026-09-30

1. B, D
2. No, Yes, Yes, Yes
3. B
4. (1) who/what/where or principal + role + scope (2–4 not answered)
5. Sign in as GA → turn on elevation → assign Reader → turn off elevation
6. B
7. B
8. C
9. B, E
10. B

## Score: 7/10 (70%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 5 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — elevate = UAA at root, not Owner; without elevation GA has no Azure access |
| 2 | Correct | No / Yes / Yes / Yes — co-admin is subscription-only Owner-equivalent; DataActions vs Actions |
| 3 | Correct | B — Contributor cannot create role assignments |
| 4 | **Wrong** | Blank 1 is right (**principal** is the correct word). Blanks 2–4 were empty: UAA + **root** MG; **Owner** + **subscription**; **Actions** / **DataActions** |
| 5 | Correct | Elevate, assign, then turn elevation off so she has no standing Azure role |
| 6 | Correct | B — VM Contributor at `rg-app` |
| 7 | Correct | B — managed identity; data-plane role at the account |
| 8 | **Wrong** | **B** — both calls succeed. `DataActions` are **not** ignored at subscription scope. The assignment covers every storage account in the sub |
| 9 | **Wrong** | **B, D** — `--include-inherited` on `az role assignment list`, and `Get-AzRoleAssignment -Scope` (includes parents). **E is Policy**, wrong cmdlet family. C `--include-groups` expands group membership, not MG inheritance |
| 10 | Correct | B — VM Contributor + RG scope |

Quiz 1's conceptual holes (GA, co-admin, Actions/DataActions as Yes/No, elevation order) are closed. This fail is incomplete fill-ins plus two snippet traps: **data-plane at subscription still works**, and **`az policy` ≠ `az role`**.

**Principal** is the right term. Who / what / where is a valid memory hook for principal / role / scope.
