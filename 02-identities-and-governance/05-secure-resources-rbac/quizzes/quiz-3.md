# Module 5 (Azure RBAC) — Quiz 3

Date issued: 2026-10-01
Prerequisite: Quiz 1 8/10 FAIL, Quiz 2 7/10 FAIL. Closed in drills: principal + role + scope; co-admin ≈ Owner at subscription; Actions vs DataActions; elevate = UAA at root MG.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer **every** numbered blank. Do not skip ahead.

---

**1.** Select the **two** true statements.

A. Elevating a Global Administrator grants Reader at the tenant.
B. Elevating a Global Administrator grants User Access Administrator at the root management group.
C. Elevation makes the Global Administrator Owner on every subscription until they sign out.
D. Control-plane `Microsoft.Storage/storageAccounts/read` is enough to download a blob.
E. `Storage Blob Data Reader` (or `DataActions` on blobs/read) is what allows reading blob bytes.

---

**2.** For each statement, answer **Yes** or **No**.

1. `az policy assignment list --include-inherited` lists Azure RBAC assignments inherited from a management group.
2. `az role assignment list --scope /subscriptions/<id> --include-inherited` lists RBAC assignments inherited from a parent management group.
3. A `DataActions` permission assigned at subscription scope applies to storage accounts in that subscription.
4. Azure Reader on a storage account lets you download blobs.

---

**3.** Exhibit:

```bash
az role assignment list --scope /subscriptions/6f1e8a52-c2a1
```

A Reader assignment exists at `mg-corp`, parent of this subscription. The caller is Owner on the subscription. What does this command show, and which switch would include the `mg-corp` assignment?

A. It shows the MG assignment; no switch needed.
B. It omits the MG assignment; add `--include-inherited`.
C. It omits the MG assignment; add `--include-groups`.
D. It fails because Owner cannot list inherited assignments.

---

**4.** Complete each blank.

1. An Azure role assignment is ________ + ________ + ________.
2. Elevating a Global Administrator grants ________ at the ________ management group.
3. Classic co-administrator ≈ ________, only at ________ scope.
4. Restart a VM goes in ________; download a blob goes in ________.

---

**5.** Put these in order. A Global Administrator has elevation **off** and no Azure role. She must grant Reader to a group on one subscription, then have no standing Azure access.

- Turn off Access management for Azure resources.
- Assign Reader to the group at the subscription.
- Turn on Access management for Azure resources.
- Sign in as Global Administrator.

---

**6.** Case study — Contoso. Lowest privilege that meets all:

- An app on a VM must **download blobs** from `stpay001` only.
- Operators must **see** the storage account in the portal but must **not** download blobs.
- Nobody on this team may assign Azure roles.

A. Storage Blob Data Reader on the VM's managed identity at `stpay001`; Azure Reader on an operators group at `stpay001`; no Owner/UAA on that team.
B. Azure Reader on the managed identity at the subscription; Contributor on operators at `stpay001`.
C. Storage Blob Data Reader on operators at the subscription; Azure Reader on the managed identity at `stpay001`.
D. Owner on both the identity and the operators at `rg-pay`.

---

**7.** Exhibit — PowerShell:

```powershell
Get-AzRoleAssignment -Scope '/subscriptions/6f1e8a52-c2a1'
```

Which statement is correct?

A. This lists Policy assignments only.
B. This lists Azure role assignments at that subscription **and** inherited from parent scopes.
C. This lists only assignments whose `scope` property equals the subscription, never a management group.
D. You must add `-IncludeInherited` or the cmdlet returns nothing.

---

**8.** Exhibit — custom role assigned at the **subscription**:

```json
{
  "Actions": [ "Microsoft.Storage/storageAccounts/read" ],
  "DataActions": [],
  "AssignableScopes": [ "/subscriptions/6f1e8a52-c2a1" ]
}
```

The user runs `Get-AzStorageAccount`, then tries to download a blob. Result?

A. Both succeed because the assignment is at subscription scope.
B. Account read succeeds; blob download fails — no `DataActions`.
C. Both fail; `Actions` are ignored at subscription scope.
D. Account read fails; blob download succeeds.

---

**9.** Select the **two** identities that can run `az role assignment create` at `rg-app`.

A. Contributor on `rg-app`
B. Owner on `rg-app`
C. User Access Administrator on the parent subscription
D. Entra User Administrator (no Azure role)
E. Virtual Machine Contributor on `rg-app`

---

**10.** Exhibit — which **one** change is required?

```powershell
New-AzRoleAssignment -SignInName maria@contoso.com `
  -RoleDefinitionName 'Reader' `
  -Scope '/subscriptions/6f1e8a52-c2a1'
```

Requirement: Maria downloads blobs in `stpay001` only, and must not manage the account in ARM.

A. Change `Reader` to `Storage Blob Data Reader` and `-Scope` to the storage account resource ID.
B. Change `Reader` to `Contributor` and keep the subscription scope.
C. Change `Reader` to `Owner` and `-Scope` to `rg-pay`.
D. Keep `Reader`; data-plane read is included in Azure Reader.

---

## Submission — 2026-10-01

1. B, E
2. No, Yes, Yes, Yes
3. B
4. (1) security principal, role, scope (2–4 not answered)
5. Sign in as GA → turn on elevation → assign Reader → turn off elevation
6. A
7. B
8. B
9. B, C
10. A

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 5 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, E — elevate = UAA at root MG; blob bytes = data-plane read |
| 2 | **Wrong** | No / Yes / Yes / **No** — Azure **Reader** on the account does **not** download blobs. You answered Yes on statement 4 |
| 3 | Correct | B — without `--include-inherited`, the MG assignment is omitted |
| 4 | **Wrong** | Blank 1 correct. Blanks 2–4 empty again: **UAA** + **root**; **Owner** + **subscription**; **Actions** / **DataActions** |
| 5 | Correct | Elevate → assign → turn off |
| 6 | Correct | A — data-plane on the MI; control-plane Reader on operators; no IAM roles on that team |
| 7 | Correct | B — `Get-AzRoleAssignment -Scope` includes inherited |
| 8 | Correct | B — `Actions` read only; download needs `DataActions` |
| 9 | Correct | B, C — Owner at the RG, or UAA at a parent (inherits). Contributor and Entra User Admin cannot |
| 10 | Correct | A — `Storage Blob Data Reader` at the account, not Azure Reader |

Same two failure modes as quiz 2: **empty fill-ins**, and **Reader ≠ download**. Q8 you got right on an exhibit; Q2 statement 4 you contradicted that fact. Treat Azure Reader as portal/ARM visibility only.
