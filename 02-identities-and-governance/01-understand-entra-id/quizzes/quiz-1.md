# Module 1 (Understand Microsoft Entra ID) — Quiz 1

Date issued: 2026-09-22  
Scope: this module only — Entra ID, Entra ID vs AD DS, directory for cloud apps, P1 vs P2, Entra Domain Services.  
Pass: **9/10**. Closed notes. Wrong terminology counts as wrong.

Reply `1.` through `10.` in chat. No hints. I grade after you submit.

---

**1.** A colleague says "Entra ID is just Active Directory hosted in Azure, so we can move our OUs and GPOs up there." Which correction is accurate?

A. Correct — Entra ID supports OUs and GPOs, only the DCs are managed by Microsoft.  
B. Entra ID is a **flat** directory: no OUs, no GPOs. It is queried over **Microsoft Graph (HTTPS)**, not LDAP, and does not use Kerberos.  
C. Entra ID supports OUs but not GPOs; device policy comes from Group Policy anyway.  
D. Entra ID is AD DS plus LDAP over TLS, so existing LDAP apps work unchanged.

---

**2.** Match each protocol to its job in Entra ID.

- SAML, WS-Federation, OpenID Connect → ________  
- OAuth 2.0 → ________  
- Kerberos and LDAP → ________

A. authentication / authorization / not used by Entra ID (they are AD DS, or Entra Domain Services)  
B. authorization / authentication / used by Entra ID for device join  
C. encryption / authentication / authorization  
D. authentication / directory queries / authorization

---

**3.** Exhibit — output from a Cloud Shell session:

```json
{
  "subscription": "sub-contoso-prod",
  "subscriptionId": "6f1e...c2a1",
  "tenantId": "9b2d...44f7",
  "user": "admin@contoso.onmicrosoft.com"
}
```

Which statement about the tenant↔subscription relationship is correct?

A. A subscription can trust multiple tenants, which is how multi-tenant apps work.  
B. A subscription trusts exactly **one** tenant, and one tenant can contain **many** subscriptions.  
C. Each tenant contains exactly one subscription; more subscriptions need more tenants.  
D. `tenantId` is the same as `subscriptionId` in single-tenant directories.

---

**4.** Fabrikam is acquired. Its production subscription is transferred to Contoso's Entra tenant. What should you plan for?

A. Nothing; role assignments follow the subscription automatically.  
B. **Existing RBAC role assignments are lost**, because the users, groups, and service principals were principals in the old tenant. Inventory first, recreate against Contoso principals after the move.  
C. Only Owner assignments are lost; Reader and Contributor survive.  
D. The subscription must be deleted and rebuilt; transfer between tenants is not supported.

---

**5.** For each requirement, pick the minimum edition: **Free**, **P1**, or **P2**.

- Let cloud-only users reset their own password → ________  
- Group membership driven by the `department` attribute → ________  
- Require MFA when a sign-in is flagged as **risky** → ________  
- Make an engineer *eligible* for Global Administrator, activated on request with approval → ________

---

**6.** Which set is entirely **P1** (not Free, not P2-only)?

A. Conditional Access, dynamic membership groups, group-based licensing, SSPR with on-prem password writeback  
B. Identity Protection, Privileged Identity Management, access reviews  
C. Users, groups, assigned membership, security defaults  
D. Entra Domain Services, External ID, Entra ID Governance

---

**7.** A 12-year-old line-of-business app performs **LDAP binds** and must run unmodified on an Azure VM that is **domain-joined**. The team refuses to build and patch domain controllers. What do you recommend, and what is the main limitation?

A. Plain Entra ID — it supports LDAP and Kerberos natively; no real limitation.  
B. **Entra Domain Services** — managed domain with domain join, Kerberos/NTLM, LDAP, and Group Policy. Limitations: **separate namespace**, **no two-way trust**, no schema extension, no Domain Admin rights.  
C. Entra Connect Sync — it projects LDAP into the cloud.  
D. Conditional Access with legacy authentication enabled.

---

**8.** Exhibit — a Windows admin's plan for configuring 400 cloud-only laptops:

```text
1. Create an OU named "Laptops" in Entra ID
2. Link a GPO to that OU to set the screen-lock timeout
3. Force gpupdate from Cloud Shell
```

How many of these three steps are possible in Entra ID, and what is the correct approach?

A. All three; run `az ad ou create` first.  
B. **None.** Entra ID has no OUs and no GPOs, and there is no `gpupdate` for it. Use **Intune** configuration profiles for cloud-managed devices — or Entra Domain Services / AD DS if GPO is mandatory.  
C. Steps 1 and 2 only; step 3 must be done from the portal.  
D. Step 2 only, because GPOs attach to the tenant root rather than an OU.

---

**9.** Exhibit — a Microsoft Graph request body:

```json
{
  "displayName": "Finance-Dynamic",
  "mailNickname": "financedyn",
  "securityEnabled": true,
  "groupTypes": ["DynamicMembership"],
  "membershipRule": "(user.department -eq \"Finance\")",
  "membershipRuleProcessingState": "On"
}
```

The tenant is on Entra ID **Free**. What happens, and why?

A. It works; dynamic membership is a Free feature because the rule runs in Graph.  
B. It is **not licensed** — dynamic membership groups require **P1** for the affected users. Either buy P1 or use an **assigned** group.  
C. It works but only for guests.  
D. It fails because dynamic rules must be created with `az ad group create`.

---

**10.** Which single statement is **true**?

A. Entra Connect Sync replicates cloud users down into on-prem AD DS by default, and password writeback is a Free feature.  
B. Entra ID uses trust relationships between tenants the same way AD DS uses forest trusts.  
C. Entra Connect Sync syncs **on-premises → cloud**, and **password writeback** (cloud → on-prem) requires **P1**.  
D. Microsoft Entra Domain Services replaces AD DS entirely, including two-way trusts and schema extensions.

---

## Submission — 2026-09-22

1. B  
2. A  
3. B  
4. B  
5. Free, P1, P2, P2  
6. A  
7. B  
8. B  
9. B  
10. C

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B — flat directory, Graph over HTTPS, no Kerberos |
| 2 | Correct | A — SAML/WS-Fed/OIDC authenticate, OAuth 2.0 authorizes, Kerberos/LDAP are AD DS |
| 3 | Correct | B — one tenant per subscription, many subscriptions per tenant |
| 4 | Correct | B — tenant transfer drops role assignments |
| 5 | Correct | Free / P1 / P2 / P2 |
| 6 | Correct | A |
| 7 | Correct | B — Entra Domain Services, separate namespace, no two-way trust |
| 8 | Correct | B — no OUs, no GPOs; Intune for cloud-managed devices |
| 9 | Correct | B — dynamic membership needs P1 |
| 10 | Correct | C — sync is on-prem → cloud; writeback is P1 |

Clean sweep. Notably you did not fall for the two most common Entra ID errors: treating it as AD DS with a cloud front end, and assuming risk-based Conditional Access (P2) is the same as plain Conditional Access (P1).

Module 1 passed. Moving to module 2.

