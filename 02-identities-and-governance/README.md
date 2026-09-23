# 02 — Manage identities and governance in Azure

Microsoft Learn path: [AZ-104: Manage identities and governance in Azure](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/) — 6 modules.

This is the **largest exam domain: 20–25%** of AZ-104. It is also the domain where wrong answers are usually *scope* mistakes, not vocabulary mistakes.

## Module status

| # | Learn module | Folder | Read | Quiz |
| --- | --- | --- | --- | --- |
| 1 | Understand Microsoft Entra ID | `01-understand-entra-id/` | ✅ 2026-09-22 | ✅ 10/10 |
| 2 | Create, configure, and manage identities | `02-create-configure-manage-identities/` | ✅ 2026-09-22 | ✅ 10/10; ✅ 9/10 (hard) |
| 3 | Describe the core architectural components of Azure | `03-core-architectural-components/` | ✅ 2026-09-22 | ✅ 10/10 (retake) |
| 4 | Azure Policy initiatives | — | ⬜ | — |
| 5 | Secure your Azure resources with Azure RBAC | — | ⬜ | — |
| 6 | Allow users to reset their password with Entra SSPR | — | ⬜ | — |

Folders are scaffolded only for modules you have finished.

## Skills measured this path maps to

**Manage Microsoft Entra users and groups** — create users and groups, manage user/group properties, manage licenses, manage external users, configure SSPR.  
**Manage access to Azure resources** — built-in roles, assign roles at different scopes, interpret access assignments.  
**Manage Azure subscriptions and governance** — Azure Policy, resource locks, tags, resource groups, subscriptions, cost alerts/budgets/Advisor, management groups.

Modules 1–3 cover the **identity objects** and the **scope hierarchy**. Modules 4–6 add Policy, RBAC, and SSPR — that is where the governance verbs land.

## Layout

```
02-identities-and-governance/
  README.md                 ← you are here
  exam/commands.md          ← CLI ↔ PowerShell pairs, grows per module
  quizzes/                  ← path-level exams (all 6 modules)
  NN-module-name/
    README.md               ← that module's notes
    poc/                    ← CLI / PowerShell / Bicep for that module
    quizzes/                ← that module's quizzes
```

## The one thing to carry from path 01

Scope. Path 01 taught you that a deployment targets a resource group and that `--mode Complete` respects RG boundaries. This path is the same idea applied to **identity and governance**: a tenant is not a subscription, a subscription is not a resource group, and an RBAC assignment or policy at one level **inherits downward**. Almost every exam question in this domain is asking "at which scope?"
