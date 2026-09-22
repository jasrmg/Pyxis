# Module 2 (Create, configure, and manage identities) — Quiz 1

Date issued: 2026-09-22  
Scope: this module only — users, groups, administrative units, device registration, licenses, custom security attributes, automatic provisioning.  
Pass: **9/10**. Closed notes.

Reply `1.` through `10.` in chat. I grade after you submit.

---

**1.** Exhibit:

```bash
az ad user create \
  --display-name "Abby Brown" \
  --user-principal-name "abby@fabrikam.com" \
  --password "<pw>"
```

The tenant is `contoso.onmicrosoft.com` and `fabrikam.com` has **not** been added or verified. Result?

A. Succeeds; Entra ID creates `fabrikam.com` automatically.  
B. **Fails** — the UPN suffix must be a **verified domain** in the tenant. Use `contoso.onmicrosoft.com`, or add and verify `fabrikam.com` first.  
C. Succeeds but the user is created as a Guest.  
D. Succeeds; the UPN domain is cosmetic and never validated.

---

**2.** A user is deleted Friday. On Monday you need them back with group memberships and licenses. Separately, a **security group** was deleted the same day. What can you recover?

A. Both, indefinitely.  
B. Neither — deletion is immediate and permanent in Entra ID.  
C. The **user** (soft-deleted for **30 days**, restorable). The **security group is not recoverable** that way — recreate it and rebuild its role assignments.  
D. The group only; users are purged immediately for security reasons.

---

**3.** A helpdesk admin cannot change a user's job title in the Entra portal — the fields are greyed out. The user signs in with on-prem credentials. Most likely cause and fix?

A. The admin lacks Global Administrator; elevate them.  
B. The user is **directory-synchronized**; most attributes are **read-only in the cloud**. Change it in **on-prem AD DS** and let Entra Connect Sync carry it up.  
C. The user is a Guest; convert to Member first.  
D. The tenant is on Free; attribute editing needs P1.

---

**4.** Manila branch helpdesk must reset passwords **only** for Manila staff — nothing at HQ. Best design, and who needs which license?

A. Assign them User Administrator at the tenant; filter the portal view by city.  
B. Create an **administrative unit** for Manila, add those users, assign **User Administrator scoped to the AU**. The **scoped admins need P1**; AU **members** need only Free.  
C. Create a dynamic security group for Manila and assign User Administrator to the group at tenant scope.  
D. Create a separate tenant for Manila.

---

**5.** An admin adds the group `grp-manila-staff` to the `AU-Manila` administrative unit, then tells a scoped User Administrator "you can now reset passwords for everyone in that group." Correct?

A. Yes — adding a group to an AU brings its members into scope.  
B. **No.** Adding a group to an AU scopes the **group object** only (rename it, change its membership). To manage those users' own properties, the **users must be AU members** too.  
C. Yes, but only for members who are also licensed P1.  
D. No — groups cannot be added to administrative units at all.

---

**6.** A 400-member **assigned** security group is converted to **dynamic** with the rule `(user.department -eq "Finance")`. Only 120 users match. What happens?

A. All 400 stay; the rule adds anyone else who matches.  
B. Conversion is blocked while manual members exist.  
C. The **manual members are discarded** — the rule becomes the source of truth, so membership drops to the 120 matches and everyone else loses access. No undo.  
D. Nothing changes until the next sync cycle, then both sets merge permanently.

---

**7.** Which statement about group membership is **true**?

A. A dynamic group's rule can target other **groups** as members.  
B. One dynamic group can mix **Dynamic User** and **Dynamic Device** rules.  
C. **Microsoft 365 groups support Dynamic User but not Dynamic Device**, and `isAssignableToRole` must be set **at creation** and cannot be dynamic.  
D. Azure RBAC ignores nested groups, so nesting is useless for access.

---

**8.** Exhibit — attempting a dynamic group with Azure CLI:

```bash
az ad group create \
  --display-name "Finance-Dynamic" \
  --mail-nickname "financedyn" \
  --membership-rule '(user.department -eq "Finance")'
```

What is wrong, and what are the two legal routes?

A. Nothing is wrong; this is the documented syntax.  
B. `--membership-rule` **does not exist** on `az ad group create`. Use PowerShell `New-AzADGroup -GroupType DynamicMembership -MembershipRule ... -MembershipRuleProcessingState On`, or POST to **Microsoft Graph** via `az rest`.  
C. The rule syntax needs single quotes inside; otherwise correct.  
D. You must add `--security-enabled true` and it will work.

---

**9.** A license assignment to a user fails. Which three causes are the ones this module points at?

A. The user is a Guest; guests can never be licensed.  
B. **Missing `usageLocation`**, **conflicting service plans** between two products, and **no remaining seats** in the SKU.  
C. The tenant lacks a verified domain, the user is disabled, and MFA is off.  
D. The user is in a nested group, licenses are direct-only, and P2 is required.

---

**10.** Two claims about scale features. Which pairing is correct?

A. **Group-based licensing** requires **P1**; **custom security attributes** need dedicated roles (such as Attribute Definition Administrator) and are **not** granted to Global Administrator by default.  
B. Group-based licensing is Free; Global Administrator automatically reads and writes all custom security attributes.  
C. Group-based licensing requires P2; custom security attributes are a Free feature available to all admins.  
D. Both require P2, and automatic user provisioning uses LDAP rather than SCIM.

---

## Submission — 2026-09-22

1. B  
2. C  
3. B  
4. B  
5. B  
6. C  
7. C  
8. B  
9. B  
10. A

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B — UPN needs a verified domain |
| 2 | Correct | C — user 30-day soft delete; security group not recoverable |
| 3 | Correct | B — synced attributes are read-only in the cloud |
| 4 | Correct | B — AU-scoped User Administrator; P1 for the admin, Free for members |
| 5 | Correct | B — a group in an AU scopes the group object, not its members |
| 6 | Correct | C — Assigned → Dynamic discards manual members |
| 7 | Correct | C — M365 groups: Dynamic User only; isAssignableToRole set at creation |
| 8 | Correct | B — no `--membership-rule` on `az ad group create`; PowerShell or Graph |
| 9 | Correct | B — usageLocation, conflicting service plans, no seats |
| 10 | Correct | A — group-based licensing is P1; custom security attributes need their own roles |

The two hardest items on this paper were 5 and 7, and both landed. Q5 (group in an AU scopes the object, not the members) and Q7 (`isAssignableToRole` is immutable and excludes dynamic membership) are the kind of constraint questions that separate a pass from a fail in this domain.

Module 2 passed. Moving to module 3.

