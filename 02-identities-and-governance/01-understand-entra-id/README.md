# Module 1 — Understand Microsoft Entra ID

Learn module: [Understand Microsoft Entra ID](https://learn.microsoft.com/en-us/training/modules/understand-azure-active-directory/) (8 units)

**Aim:** describe Entra ID, compare it to AD DS, explain it as the directory for cloud apps, compare P1 vs P2, and describe Entra Domain Services.

This module is almost entirely conceptual. It exists so you stop saying "Azure AD is AD in the cloud" — which is wrong and gets punished on the exam.

---

## What Entra ID is

A **cloud identity and access management service**. Microsoft-managed (PaaS): no domain controllers to patch, no schema to maintain. Multi-tenant by design.

The unit of isolation is the **tenant** (one directory, one organization). Every Azure subscription **trusts exactly one** Entra tenant for authentication. One tenant can hold **many** subscriptions.

That last sentence is an exam item. Moving a subscription to a different tenant breaks every RBAC assignment in it, because the principals (users, groups, service principals) live in the old tenant.

A Free tier of Entra ID comes with any Azure subscription or Microsoft 365 subscription. You do not "install" it.

## Entra ID vs AD DS — the comparison table they test

| | **AD DS** (on-premises) | **Microsoft Entra ID** |
| --- | --- | --- |
| Structure | Hierarchical, X.500-based: forests, domains, OUs | **Flat**. No OUs, no GPOs |
| Locating services | DNS (find the domain controller) | Internet endpoints over **HTTP/HTTPS** |
| Query protocol | **LDAP** | **Microsoft Graph** (REST/HTTPS) |
| Authentication | **Kerberos**, NTLM | **SAML**, **WS-Federation**, **OpenID Connect** |
| Authorization | Kerberos tickets / ACLs | **OAuth 2.0** |
| Devices | Computer objects, domain join | Registered / joined devices; no computer objects in the AD sense |
| Multi-org | **Trusts** between domains/forests | No trusts — **B2B collaboration** / federation instead |
| Group management | OUs + Group Policy | Groups only; policy via Intune / Conditional Access |
| Who runs it | You (DCs, backups, patching) | **Microsoft** |

Two phrasings to keep straight:

- **Authentication** protocols in Entra ID: SAML, WS-Fed, OpenID Connect.
- **Authorization** protocol: OAuth 2.0.

If an answer choice says "use Group Policy to configure Entra ID users," it is wrong. Entra ID has no GPOs.

**Hybrid:** you keep AD DS and sync identities up with **Microsoft Entra Connect Sync** (or Entra Cloud Sync) so users get one credential for on-prem and cloud. Sync direction is on-prem → cloud; password writeback (cloud → on-prem) is a **P1** feature.

## Entra ID as a directory for cloud apps

Entra ID is the identity provider in front of SaaS and your own apps: **single sign-on**, app registrations, enterprise applications, service principals, and managed identities. Apps trust the tenant; the tenant issues tokens.

## Editions — P1 vs P2

Cumulative. P1 includes Free; P2 includes Free and P1.

| Edition | What it adds (exam-relevant) |
| --- | --- |
| **Free** | Users, groups, **assigned** group membership, SSPR for **cloud-only** users, security defaults, basic reports (~7-day log retention) |
| **P1** | **Conditional Access**, **dynamic membership groups**, **group-based licensing**, self-service group management, **SSPR with on-prem password writeback**, administrative-unit admins, longer log retention (~30 days), Microsoft Identity Manager |
| **P2** | **Entra ID Protection** (risk-based Conditional Access), **Privileged Identity Management** (PIM — just-in-time admin, eligible vs active roles), access reviews |

Separate purchases, not tiers: **Entra ID Governance** (access reviews / lifecycle workflows), and pay-as-you-go features like **Entra Domain Services** and **External ID** (formerly B2C).

Memory hooks for exam questions:

- "Dynamic group based on the `department` attribute" → **P1**
- "Require MFA only when sign-in risk is high" → **P2** (risk = Identity Protection)
- "Require MFA for all admins" (static condition) → **P1** Conditional Access
- "Make someone eligible for Global Administrator, activated on request with approval" → **P2** PIM
- "Let cloud users reset their own password" → **Free**; "…and write it back to on-prem AD" → **P1**

## Microsoft Entra Domain Services

A **Microsoft-managed domain** that is **AD DS-compatible**. You get domain join, **Kerberos and NTLM**, **LDAP**, and **Group Policy** — without deploying or patching domain controllers.

Use it for **legacy / lift-and-shift** workloads that need real AD protocols: an app that does LDAP binds, a VM that must be domain-joined, software that needs Kerberos.

Constraints worth remembering:

- It is a **separate namespace** from your Entra tenant domain, not the same domain.
- **No two-way trust** to your on-prem forest.
- You get no Domain Admin / Enterprise Admin rights; Microsoft manages the DCs.
- You cannot extend the schema.
- Objects sync **one way** into the managed domain.

**The trap:** "Join Azure VMs to a domain without deploying domain controllers" → **Entra Domain Services**. Plain Entra ID cannot do Kerberos/LDAP domain join. Conversely, if a question wants full control (schema extensions, two-way trust, Domain Admin), the answer is **AD DS on Azure VMs**, not Domain Services.

---

## Enterprise scenarios

### 1. Acquisition: two tenants, one subscription

Contoso buys Fabrikam. Fabrikam's production subscription must move under Contoso's tenant. Transferring the subscription to the new tenant **removes all existing role assignments**, because the users and groups were Fabrikam-tenant principals. Plan: inventory assignments first, recreate them against Contoso principals after the move, and expect managed identities to need recreation.

### 2. "Just use Group Policy"

A Windows admin asks you to push a registry setting to laptops "via Entra ID." Entra ID has no GPOs. Correct answers: Intune configuration profiles for cloud-managed devices, or Entra Domain Services + GPO if the device is joined to that managed domain, or keep AD DS for those machines.

### 3. Licensing a dynamic HR-driven group

HR wants group membership driven by the `department` attribute so new hires get access automatically. Dynamic membership is **P1 minimum**, per user in the tenant. Costing this as "Free tier, we already have Azure" is the mistake; someone has to buy P1 for the affected users.

### 4. Legacy LDAP app moving to Azure

A 12-year-old line-of-business app authenticates users with LDAP binds and must stay unmodified. Entra ID cannot serve it. Options: **Entra Domain Services** (managed, no DCs to run, but no two-way trust and no schema changes) or **AD DS on IaaS VMs** (full control, you own patching and availability). Pick based on whether they need schema/trust control.

---

## Exam traps from this module

1. Entra ID is **flat** — no OUs, no GPOs, no LDAP, no Kerberos.
2. A subscription trusts **one** tenant; a tenant can hold **many** subscriptions.
3. Authentication = SAML / WS-Fed / OpenID Connect. Authorization = **OAuth 2.0**. Query = **Microsoft Graph**.
4. Dynamic groups, Conditional Access, group-based licensing, SSPR writeback = **P1**.
5. Identity Protection (risk-based) and PIM = **P2**.
6. Domain join / Kerberos / LDAP / GPO without running DCs = **Entra Domain Services** (separate namespace, no two-way trust).
7. Entra Connect Sync syncs on-prem → cloud; **password writeback is P1**.

## Lab in this folder

`poc/inspect-tenant.sh` — read-only Azure CLI reconnaissance of your tenant, subscription, and tenant↔subscription relationship. It creates nothing. Cloud Shell or a local CLI both work.
