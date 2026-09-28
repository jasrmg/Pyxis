# AZ-104 Progress

Track: Azure Administrator (AZ-104)  
Tooling: Azure portal, Azure CLI, Azure PowerShell, ARM templates, Bicep. No Terraform.  
Environment: MS Learn sandboxes, Azure Cloud Shell, or `az deployment group what-if` / `New-AzResourceGroupDeployment -WhatIf`. Azurite for storage labs.

Scoring rule: a module is checked off only after a `/quiz` score of **90% or higher**. Below 90% is marked `NEEDS REVIEW`.

Layout: path 01 is a single folder (2 modules). Path 02 onward uses **one subfolder per Learn module**, each with its own notes, `poc/`, and `quizzes/`, plus a path-level `exam/` and `quizzes/`.

## Learning paths

- [x] **01 Prerequisites for Azure administrators**
  - MS Learn: completed 2026-09-21
  - Interview: completed 2026-09-21 — definitions solid; initial gaps on persistence, idle timeout, incremental vs complete
  - Quiz 1 (2026-09-21): 7/10 (70%) FAIL — NEEDS REVIEW
  - Quiz 2 (2026-09-21): **10/10 (100%) PASS** — prior misses closed; path checked off
  - Quiz 3 snippets (2026-09-21): **10/10 (100%) PASS** — CLI/ARM/Bicep exhibits closed
- [ ] **02 Manage identities and governance in Azure** — 4 of 6 modules read, 4 passed
  - Interview modules 1–3 (2026-09-23, cold): **3/6 (50%) NEEDS REVIEW**
  - Interview modules 1–3 (2026-09-27, after notes + hard quizzes): **4/6 (67%) NEEDS REVIEW**. Closed since cold pass: authn/authz split, Domain Services killers (schema + two-way trust), discard-then-repopulate, nested licensing vs nested RBAC, VM untagged + mixed region, Policy `modify` vs Cost Management. Still open after that paper: object-ID mechanism, region pair as product, RTO/RPO.
  - AU verbal drill (2026-09-27): **4/4 PASS** — group-object-vs-members and AU-is-not-a-fence both closed after a restatement. Exam wording to keep: role is `Password Administrator` or `User Administrator` **scoped to the AU**; stop Ben by changing **his assignment**, not the AU membership.
  - [x] Module 1 Understand Microsoft Entra ID — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**; notes re-read 2026-09-23; Quiz 2 (hard format, balanced distractors) **10/10 (100%) PASS** — interview gaps for this module closed
  - [x] Module 2 Create, configure, and manage identities — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**; notes re-read 2026-09-23; Quiz 2 (hard format) **9/10 (90%) PASS** — miss was nested group-based licensing vs nested RBAC; AU / conversion interview gaps closed
  - [x] Module 3 Describe the core architectural components of Azure — read 2026-09-22; Quiz 1 8.5/10 (85%) FAIL; Quiz 2 **10/10 (100%) PASS**; notes re-read 2026-09-27; Quiz 3 (hard format) **9/10 (90%) PASS** — miss: exhibit still applied tag inheritance to a child resource (location correct, tags wrong)
  - [x] Module 4 Azure Policy initiatives — read 2026-09-28; Quiz 1 8/10 (80%) FAIL; notes written; Quiz 2 **9/10 (90%) PASS** — miss: Indexed still evaluates tagged resources (RGs are the skip); append/modify reason inverted
  - [ ] Module 5 Secure your Azure resources with Azure RBAC — not started
  - [ ] Module 6 Entra self-service password reset (SSPR) — not started
- [ ] **03 Implement and manage storage in Azure**
- [ ] **04 Deploy and manage Azure compute resources**
- [ ] **05 Configure and manage virtual networks**
- [ ] **06 Monitor and back up Azure resources**

## Quiz log

| Date | Module | Score | Result |
| --- | --- | --- | --- |
| 2026-09-21 | 01 Prerequisites — Quiz 1 | 7/10 (70%) | FAIL — NEEDS REVIEW |
| 2026-09-21 | 01 Prerequisites — Quiz 2 | 10/10 (100%) | PASS |
| 2026-09-21 | 01 Prerequisites — Quiz 3 snippets | 10/10 (100%) | PASS |
| 2026-09-22 | 02 Module 1 Understand Entra ID — Quiz 1 | 10/10 (100%) | PASS |
| 2026-09-22 | 02 Module 2 Create/manage identities — Quiz 1 | 10/10 (100%) | PASS |
| 2026-09-22 | 02 Module 3 Core architecture — Quiz 1 | 8.5/10 (85%) | FAIL — NEEDS REVIEW |
| 2026-09-22 | 02 Module 3 Core architecture — Quiz 2 | 10/10 (100%) | PASS |
| 2026-09-23 | 02 Modules 1–3 — verbal interview (cold) | 3/6 (50%) | FAIL — NEEDS REVIEW |
| 2026-09-23 | 02 Module 1 Understand Entra ID — Quiz 2 (hard format) | 10/10 (100%) | PASS |
| 2026-09-23 | 02 Module 2 Create/manage identities — Quiz 2 (hard format) | 9/10 (90%) | PASS — miss: nested licensing vs nested RBAC |
| 2026-09-27 | 02 Module 3 Core architecture — Quiz 3 (hard format) | 9/10 (90%) | PASS — miss: tags on a mixed-region exhibit |
| 2026-09-27 | 02 Modules 1–3 — verbal interview (retake) | 4/6 (67%) | FAIL — NEEDS REVIEW — AU fence + group-scoping still inverted |
| 2026-09-28 | 02 Module 4 Azure Policy initiatives — Quiz 1 | 8/10 (80%) | FAIL — NEEDS REVIEW |
| 2026-09-28 | 02 Module 4 Azure Policy initiatives — Quiz 2 | 9/10 (90%) | PASS — miss: Indexed vs resource groups |
