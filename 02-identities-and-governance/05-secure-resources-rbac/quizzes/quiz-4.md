# Module 5 (Azure RBAC) — Quiz 4

Date issued: 2026-10-01
Prerequisite: Quizzes 1–3 FAIL. Drills closed: triple; UAA at root MG; co-admin; Actions vs DataActions; Azure Reader ≠ blob download.
Pass: **9/10**. Closed notes.

Answer **every** numbered part of Q2 and Q4 before you open Q5.

---

**1.** Select the **two** true statements.

A. Azure Reader on a storage account allows downloading blobs.
B. Storage Blob Data Reader on a storage account allows reading blob bytes.
C. Elevating a Global Administrator grants User Access Administrator at the root management group.
D. Elevating a Global Administrator grants Reader at the tenant.
E. Contributor on a resource group can create role assignments in that group.

---

**2.** For each statement, answer **Yes** or **No**.

1. Classic co-administrator can be scoped to one resource group.
2. `Get-AzRoleAssignment -Scope /subscriptions/<id>` includes assignments inherited from a management group.
3. `az policy assignment list` is the cmdlet that lists Azure RBAC assignments.
4. A `DataActions` blob-read granted at subscription scope can apply to `stpay001` in that subscription.

---

**3.** Exhibit:

```bash
az role assignment create \
  --assignee $miObjectId \
  --role "Reader" \
  --scope "/subscriptions/.../resourceGroups/rg-pay/providers/Microsoft.Storage/storageAccounts/stpay001"
```

The VM's managed identity must **download** blobs from `stpay001`. Result?

A. Succeeds; Reader includes data-plane read.
B. The assignment is created, but the app cannot download; the role must be Storage Blob Data Reader.
C. Fails; managed identities cannot be `--assignee`.
D. Succeeds only if the identity is also Contributor on `rg-pay`.

---

**4.** Complete **all four**.

1. Assignment triple: ________ + ________ + ________.
2. Elevate Global Admin: ________ at the ________ management group.
3. Co-admin ≈ ________, only at ________ scope.
4. Restart VM → ________; download blob → ________.

---

**5.** Order these. Elevation is off. GA has no Azure role. Goal: data-team group gets Reader on one subscription; GA must not keep standing Azure access.

- Assign Reader to the data-team group at the subscription.
- Turn on Access management for Azure resources.
- Sign in as Global Administrator.
- Turn off Access management for Azure resources.

---

**6.** Case study — Fabrikam. All must hold, lowest privilege:

- Helpdesk restarts VMs in `rg-app` only and must not assign roles.
- Operators **see** `stlogs` in the portal and must **not** download logs.
- The app identity **downloads** logs from `stlogs` only.

A. VM Contributor at `rg-app` for helpdesk; Azure Reader at `stlogs` for operators; Storage Blob Data Reader at `stlogs` for the managed identity.
B. Contributor at the subscription for helpdesk; Storage Blob Data Reader at `stlogs` for operators; Azure Reader at `stlogs` for the identity.
C. Co-admin for helpdesk; Azure Reader at the subscription for operators and the identity.
D. Owner at `rg-app` for helpdesk; Storage Blob Data Reader at `stlogs` for operators; Azure Reader for the identity.

---

**7.** Exhibit — which **two** commands show a Reader assignment whose `scope` is `mg-corp` when you query the child subscription?

A. `az role assignment list --scope /subscriptions/<id>`
B. `az role assignment list --scope /subscriptions/<id> --include-inherited`
C. `az policy assignment list --scope /subscriptions/<id> --include-inherited`
D. `Get-AzRoleAssignment -Scope /subscriptions/<id>`
E. `az ad user get-member-groups --id <upn>`

---

**8.** Exhibit:

```json
{
  "Actions": [ "Microsoft.Compute/virtualMachines/read", "Microsoft.Compute/virtualMachines/restart/action" ],
  "DataActions": [ "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read" ],
  "AssignableScopes": [ "/subscriptions/6f1e8a52-c2a1/resourceGroups/rg-app" ]
}
```

You assign this role at `rg-other` in the same subscription. Result?

A. Succeeds; `DataActions` make `AssignableScopes` optional.
B. Fails; `rg-other` is not in `AssignableScopes`.
C. Succeeds for VM restart only; blob read is ignored outside `rg-app`.
D. Succeeds; custom roles can be assigned anywhere in the subscription.

---

**9.** A teammate says “give them Reader so they can pull files from the container.” What do you assign instead, and at what scope if they only need one account?

A. Azure Reader at the subscription.
B. Storage Blob Data Reader at that storage account.
C. Contributor at the resource group.
D. User Access Administrator at the storage account.

---

**10.** Exhibit — Ben is **User Access Administrator** on the subscription (not Owner). He runs:

```powershell
New-AzRoleAssignment -SignInName maria@contoso.com `
  -RoleDefinitionName 'Virtual Machine Contributor' `
  -ResourceGroupName 'rg-app'
```

Result?

A. Fails; only Owner can create role assignments.
B. Succeeds; UAA can assign Azure roles at this subscription and below.
C. Fails; UAA cannot assign at resource group scope.
D. Succeeds, but Maria also becomes able to assign roles.

---

## Submission — 2026-10-01

1. B, C
2. No, Yes, No, Yes
3. B
4. (1) security principal, role, scope (2) UAA, root (management group) (3) Owner, subscription (4) Actions, DataActions
5. Sign in as GA → turn on elevation → assign Reader → turn off elevation
6. A
7. B, D
8. B
9. B
10. B

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — Blob Data Reader = bytes; elevate = UAA at root MG |
| 2 | Correct | No / Yes / No / Yes — co-admin not RG-scoped; Get-AzRoleAssignment includes inherited; policy cmdlet ≠ RBAC; DataActions at sub still cover `stpay001` |
| 3 | Correct | B — Azure Reader assignment can exist and still not download |
| 4 | Correct | Triple; UAA at **root management group**; Owner / subscription; Actions / DataActions |
| 5 | Correct | Elevate, assign, de-elevate |
| 6 | Correct | A — three different roles, three planes/scopes |
| 7 | Correct | B, D — `az role assignment list --include-inherited` and `Get-AzRoleAssignment` |
| 8 | Correct | B — `AssignableScopes` is enforced |
| 9 | Correct | B — Storage Blob Data Reader at the account |
| 10 | Correct | B — UAA at the subscription can assign at `rg-app`; Maria does not inherit UAA |

Module 5 passed. You answered every Q4 blank, and you did not treat “Reader” as blob download. Keep that split: **Reader** = ARM; **Storage Blob Data Reader** = bytes.
