# Module 1 (Understand Microsoft Entra ID) — Quiz 2

Date issued: 2026-09-23
Scope: this module only — Entra ID, Entra ID vs AD DS, directory for cloud apps, editions, Entra Domain Services.
Pass: **9/10**. Closed notes.

Format note: option lengths are deliberately balanced and distractors are plausible. The longest answer is not the key. Question types mirror the exam: single best answer, multiple-select, yes/no series, hot area fill-in, ordering, case study, and snippet exhibits.

Reply `1.` through `10.` in chat. For multi-part questions answer every part. No hints until you submit.

---

**1.** Litware runs a payroll application that performs LDAP binds, requires a custom schema attribute named `payrollRegion`, and must authenticate users from a two-way trusted partner forest. The app cannot be modified. The team does not want to patch domain controllers.

Which solution meets the requirements?

A. Microsoft Entra Domain Services, using secure LDAP and the built-in managed domain schema.
B. AD DS on Azure virtual machines, placed in a virtual network peered to the app subnet.
C. Microsoft Entra ID with Entra Connect Sync, exposing synced attributes to the application.
D. Microsoft Entra Domain Services, with a one-way outbound trust to the partner forest.

---

**2.** Select the **two** requirements whose minimum edition is **P1**.

A. Allow cloud-only users to reset a forgotten password themselves.
B. Assign Microsoft 365 licenses by adding users to a security group.
C. Require multi-factor authentication for everyone holding the Global Administrator role.
D. Review and attest to privileged role membership on a recurring 90-day cycle.
E. Enforce MFA registration for all users through security defaults.

---

**3.** For each statement about Microsoft Entra Domain Services, answer **Yes** or **No**.

1. The managed domain uses the same DNS namespace as the Entra tenant's primary domain.
2. A two-way forest trust can be configured between the managed domain and an on-premises AD DS forest.
3. Objects from the Entra tenant synchronize one way into the managed domain.
4. You can add a custom attribute to the managed domain's schema.

---

**4.** Exhibit — a script run against the Contoso tenant:

```bash
az login --tenant contoso.onmicrosoft.com
az ad user list --filter "department eq 'Finance'" --query "[].userPrincipalName" -o tsv
ldapsearch -H ldaps://contoso.onmicrosoft.com -b "OU=Finance,DC=contoso,DC=com" "(objectClass=user)"
az ad group member add --group Finance-Access --member-id 8c31d0a4-1f77-4c6e-9a20-0b5f2c9ad311
```

Which line cannot succeed, and why?

A. Line 2, because `--filter` is not supported for directory objects.
B. Line 3, because Entra ID publishes no LDAP endpoint for the tenant namespace.
C. Line 3, because the base DN must reference the `onmicrosoft.com` suffix.
D. Line 4, because group membership changes require Microsoft Graph directly.

---

**5.** Exhibit — two Cloud Shell sessions run by the same administrator:

```json
{ "name": "sub-contoso-prod", "id": "6f1e8a52-...-c2a1", "tenantId": "9b2d47c8-...-44f7" }
{ "name": "sub-contoso-dev",  "id": "d40b71fe-...-9e33", "tenantId": "9b2d47c8-...-44f7" }
```

Contoso now transfers `sub-contoso-dev` to a different Entra tenant. Which statement describes both the exhibit and the outcome of the transfer?

A. The subscriptions trust one directory; after the transfer its role assignments are preserved by object ID.
B. The subscriptions trust one directory; after the transfer its role assignments no longer resolve and are removed.
C. Each subscription trusts its own directory; the shared `tenantId` reflects the billing account, not the directory.
D. The subscriptions trust one directory; after the transfer only assignments held by groups survive.

---

**6.** Complete each blank.

1. The default synchronization direction for Microsoft Entra Connect Sync is ________ to ________.
2. Self-service password reset with on-premises password writeback pushes the change from ________ to ________, and requires the ________ edition.
3. Applications and scripts query the Entra ID directory through the ________ API, over ________.
4. Entra ID's authorization protocol is ________.

---

**7.** Case study — Adatum.

Adatum has an Entra tenant with 900 users, all licensed Entra ID Free. Requirements:

- A file-transfer appliance must join a domain and authenticate service accounts with Kerberos. Adatum will not operate domain controllers.
- New hires must land in an access group automatically based on their `department` attribute.
- Sign-ins from anonymous IP addresses must trigger MFA; normal sign-ins must not.

Which combination meets all three requirements at the lowest licensing cost?

A. Entra Domain Services; P1 for the affected users; P1 Conditional Access for the sign-in condition.
B. AD DS on Azure VMs; P1 for the affected users; P2 for the affected users.
C. Entra Domain Services; P1 for the affected users; P2 for the affected users.
D. Entra Domain Services; Free tier assigned groups; P2 for the affected users.

---

**8.** Exhibit — license inventory from the Fabrikam tenant:

```bash
az rest --method get \
  --url "https://graph.microsoft.com/v1.0/subscribedSkus?\$select=skuPartNumber,prepaidUnits,consumedUnits"
```

```json
{
  "value": [
    { "skuPartNumber": "AAD_PREMIUM",   "prepaidUnits": { "enabled": 50 }, "consumedUnits": 50 },
    { "skuPartNumber": "ENTERPRISEPACK", "prepaidUnits": { "enabled": 90 }, "consumedUnits": 64 }
  ]
}
```

Fabrikam now wants attribute-driven group membership for 12 additional users, and risk-based Conditional Access for those same 12 users. What must be purchased?

A. Nothing; 26 Enterprise Pack seats remain and include both capabilities.
B. 12 additional AAD_PREMIUM seats only.
C. 12 AAD_PREMIUM_P2 seats only.
D. 12 additional AAD_PREMIUM seats and 12 AAD_PREMIUM_P2 seats.

---

**9.** Contoso is acquiring Fabrikam and will move Fabrikam's production subscription into the Contoso tenant. Put these actions in the correct order.

- Recreate role assignments against Contoso principals.
- Export the existing role assignments and their principal object IDs.
- Recreate managed identities and re-grant their access.
- Change the subscription's directory to the Contoso tenant.
- Confirm which Fabrikam principals have equivalents in the Contoso tenant.

---

**10.** Northwind requires that the Global Administrator role be held by nobody on a standing basis. An engineer may request the role, which must be approved by a second administrator and expire automatically after four hours, with every activation recorded.

What is the minimum edition, and which capability delivers it?

A. P1, using a Conditional Access policy scoped to the directory role.
B. P1, using an access review scheduled against the role.
C. P2, using Privileged Identity Management with approval and time-bound activation.
D. P2, using Entra ID Protection to gate the role on sign-in risk.

---

## Submission — 2026-09-23

1. B
2. B, C
3. No, No, Yes, No
4. B
5. B
6. (1) on-prem, cloud (2) cloud, on-prem, P1 (3) Graph, HTTP/HTTPS (4) OAuth 2.0
7. C
8. C
9. Export the existing role assignments and their principal object IDs → Confirm which Fabrikam principals have equivalents in the Contoso tenant → Change the subscription's directory to the Contoso tenant → Recreate role assignments against Contoso principals → Recreate managed identities and re-grant their access
10. C

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B — schema extension and two-way trust rule out Domain Services; AD DS on IaaS despite the DC-patching burden |
| 2 | Correct | B, C — group-based licensing and Conditional Access are P1; SSPR cloud-only and security defaults are Free; access reviews are P2 |
| 3 | Correct | No / No / Yes / No — separate namespace, no two-way trust, one-way object sync, no schema extension |
| 4 | Correct | B — Entra ID exposes no LDAP endpoint; LDAP requires Entra Domain Services on its own namespace |
| 5 | Correct | B — one directory for many subscriptions; assignments bind to principal object IDs that do not exist in the new tenant |
| 6 | Correct | on-prem → cloud; writeback cloud → on-prem, P1; Microsoft Graph over HTTPS; OAuth 2.0 |
| 7 | Correct | C — Domain Services for Kerberos domain join, P1 for dynamic membership, P2 because "anonymous IP" is an Identity Protection risk detection |
| 8 | Correct | **C** — P2 is cumulative and includes P1, so 12 P2 seats cover both dynamic membership and risk-based Conditional Access. Option D was drafted as the key on the false premise that P1 and P2 seats stack; it does not. |
| 9 | Correct | Export → confirm principal equivalents → change directory → recreate assignments → recreate managed identities |
| 10 | Correct | C — approval plus time-bound activation plus audit is Privileged Identity Management, P2 |

Second clean sweep, this time against balanced distractors and mixed question formats, so the verbosity tell that inflated quiz 1 was not available.

Question 8 is worth keeping: the drafted key (D) was wrong and C is correct, because Entra ID editions are cumulative rather than additive. Buying P1 alongside P2 for the same user is double-paying for the P1 feature set.

Interview gaps for this module are closed. Q1 forced the Entra Domain Services trade-offs to drive the design instead of being handed over, and Q5 required the role-assignment-to-object-ID mechanism rather than just the outcome. Both landed.
