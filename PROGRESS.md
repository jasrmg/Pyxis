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
- [ ] **02 Manage identities and governance in Azure** — 3 of 6 modules read, 3 passed
  - [x] Module 1 Understand Microsoft Entra ID — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**
  - [x] Module 2 Create, configure, and manage identities — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**
  - [x] Module 3 Describe the core architectural components of Azure — read 2026-09-22; Quiz 1 8.5/10 (85%) FAIL; Quiz 2 **10/10 (100%) PASS**
  - [ ] Module 4 Azure Policy initiatives — not started
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
