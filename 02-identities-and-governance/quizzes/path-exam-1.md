# Path 02 — Cumulative exam (modules 1–6)

Date issued: 2026-10-02
Scope: entire path — Entra ID, identities, hierarchy, Policy, Azure RBAC, SSPR.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, mixed types, at least three exhibits. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every blank.

---

**1.** Select the **two** true statements.

A. Entra ID is a flat directory queried over Microsoft Graph; it has no OUs or GPOs.
B. A subscription can trust two Entra tenants so that users from both directories keep their role assignments.
C. Elevating a Global Administrator grants User Access Administrator at the root management group, not Owner.
D. Azure Reader on a storage account allows downloading blobs.
E. SSPR Properties **None** means reset requires no extra methods.

---

**2.** For each statement, answer **Yes** or **No**.

1. Adding a group to an administrative unit lets the scoped User Administrator reset those members' passwords.
2. Converting an assigned group to dynamic discards the manual list, then repopulates from the rule.
3. Tags on a resource group are copied onto child resources by default.
4. A child Audit policy assignment cancels a parent Deny assignment.

---

**3.** Exhibit:

```bash
az role assignment create \
  --assignee $miObjectId \
  --role Reader \
  --scope "/subscriptions/.../resourceGroups/rg-pay/providers/Microsoft.Storage/storageAccounts/stpay001"
```

The app must **download** blobs from `stpay001`. What is wrong?

A. Nothing; Reader includes data-plane read.
B. Use **Storage Blob Data Reader** on the managed identity at the storage account.
C. Use Contributor at the subscription.
D. Use Entra User Administrator; blob access is a directory role.

---

**4.** Complete each blank.

1. An Azure role assignment is ________ + ________ + ________.
2. Policy: only an ________ evaluates a scope; `DoNotEnforce` still ________ and does not ________.
3. SSPR methods required to reset: ________ or ________. Properties: ________ / ________ / ________.
4. Synced password writeback minimum edition: ________. Admins cannot use ________ for SSPR.

---

**5.** Order, smallest Azure RBAC / Policy scope to largest. Then one sentence: what inherits down, and what does not (tags).

- Subscription
- Resource
- Management group
- Resource group

---

**6.** Case study — Contoso. Lowest cost / least privilege that meets **all**:

- 12 production subscriptions under `mg-prod` need the same allowed-locations rule. This week do not block; still need a compliance score. Next week, block.
- Data team needs Reader on those subscriptions, including ones added later.
- 400 Finance users must land in a group automatically from `department`. That group will get licenses.
- Hybrid staff must reset forgotten passwords and sign in on-prem the same day.
- Manila helpdesk resets Manila passwords only.

A. Initiative at `mg-prod` with `DoNotEnforce` then Default; Reader at `mg-prod` for a data group; dynamic group (P1) + group-based licensing; SSPR writeback P1; User Administrator **scoped to a Manila AU** (P1 for those helpdesk admins).
B. Deny policy on each subscription; Owner at each subscription for data; assigned group on Free; SSPR None; tenant-wide User Administrator.
C. Initiative at tenant root with `notScopes` on all 12; Contributor at `mg-prod`; P2 PIM for Finance; SSPR security questions for Global Admin; add Manila users to a security group only.
D. Locks on every RG; Azure Reader for helpdesk; Free dynamic groups; writeback off; elevate every helpdesk user to Global Administrator.

---

**7.** Exhibit:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": { "field": "tags['costCenter']", "exists": "false" },
    "then": { "effect": "deny" }
  }
}
```

Assigned at the subscription, `enforcementMode` Default. A **resource group** and a **VM** are created with no `costCenter`. Outcome?

A. Both denied.
B. RG created (Indexed skips it); VM request denied.
C. Both created and tagged because modify runs first.
D. Both created; Default never denies.

---

**8.** Exhibit — group `All-Eng` members: nested groups Platform (28) and QA (16), plus user Lea.

E3 is assigned to `All-Eng`. Contributor on a subscription is assigned to `All-Eng`.

How many users get the **license**, and how many get **Contributor**?

A. 45 and 45
B. 1 and 45
C. 45 and 1
D. 1 and 1

---

**9.** Select the **two** correct SSPR / writeback statements.

A. Writeback is enabled in Microsoft Entra Connect and on Password reset → On-premises integration.
B. Unlock without reset lives on the Properties blade next to None/Selected/All.
C. Test SSPR with a non-admin account.
D. Password writeback requires P2 and a deny assignment at the subscription.
E. A Global Administrator may use security questions as one of two SSPR methods.

---

**10.** Exhibit — Ben is Contributor on `rg-web`. He runs:

```bash
az role assignment create --assignee "Web-Readers" --role Reader \
  --scope "/subscriptions/.../resourceGroups/rg-web"
```

Result, and who *can* run that command?

A. Succeeds; Contributor may assign Reader at the same RG.
B. Fails; Contributor cannot create role assignments. Owner or User Access Administrator at `rg-web` or above can.
C. Fails because groups cannot be principals.
D. Succeeds; Policy `DoNotEnforce` allows it.

---

## Submission — 2026-10-02

1. A, C
2. No, Yes, No, No
3. B
4. (1) principal, role, scope (2) default, run, modify (3) 1 or 2; None/Selected/All (4) P1; security questions
5. 2, 4, 1, 3 (resource → RG → subscription → MG)
6. A
7. B
8. B
9. A, C
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — flat Graph directory; elevate = UAA at root MG |
| 2 | Correct | AU group ≠ password reset; Assigned→Dynamic discard-then-repopulate; tags do not inherit; child Audit cannot cancel parent Deny |
| 3 | Correct | B — Storage Blob Data Reader on the MI |
| 4 | **Wrong** | Triple and SSPR blanks were right. Policy sentence is: only an **assignment** evaluates; `DoNotEnforce` still **evaluates** (compliance) and does not **block** |
| 5 | Correct | Order is right. Inheritance sentence (you asked for it): **RBAC, Policy, and locks inherit downward. Tags do not.** |
| 6 | Correct | A — initiative + DoNotEnforce then Default; Reader at MG; dynamic + group licensing P1; SSPR writeback P1; AU-scoped helpdesk |
| 7 | Correct | B — Indexed skips the RG; VM is denied |
| 8 | Correct | B — 1 license (Lea only); 45 Contributor (RBAC follows nesting) |
| 9 | Correct | A, C — Connect + On-premises integration; test as non-admin |
| 10 | Correct | B — Contributor cannot assign roles |

Path 02 cumulative passed. The only miss is the Policy **object** again: definition / initiative do nothing until assigned; `DoNotEnforce` is not `Default` / `modify`.
