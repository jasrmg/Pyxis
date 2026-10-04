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
- [x] **02 Manage identities and governance in Azure** — 6 of 6 modules read, 6 passed
  - Path exam 1 (2026-10-02): **9/10 (90%) PASS** — miss: Policy blank (assignment evaluates; DoNotEnforce evaluates and does not block)
  - Interview modules 1–3 (2026-09-23, cold): **3/6 (50%) NEEDS REVIEW**
  - Interview modules 1–3 (2026-09-27, after notes + hard quizzes): **4/6 (67%) NEEDS REVIEW**. Closed since cold pass: authn/authz split, Domain Services killers (schema + two-way trust), discard-then-repopulate, nested licensing vs nested RBAC, VM untagged + mixed region, Policy `modify` vs Cost Management. Still open after that paper: object-ID mechanism, region pair as product, RTO/RPO.
  - AU verbal drill (2026-09-27): **4/4 PASS** — group-object-vs-members and AU-is-not-a-fence both closed after a restatement. Exam wording to keep: role is `Password Administrator` or `User Administrator` **scoped to the AU**; stop Ben by changing **his assignment**, not the AU membership.
  - [x] Module 1 Understand Microsoft Entra ID — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**; notes re-read 2026-09-23; Quiz 2 (hard format, balanced distractors) **10/10 (100%) PASS** — interview gaps for this module closed
  - [x] Module 2 Create, configure, and manage identities — read 2026-09-22; Quiz 1 **10/10 (100%) PASS**; notes re-read 2026-09-23; Quiz 2 (hard format) **9/10 (90%) PASS** — miss was nested group-based licensing vs nested RBAC; AU / conversion interview gaps closed
  - [x] Module 3 Describe the core architectural components of Azure — read 2026-09-22; Quiz 1 8.5/10 (85%) FAIL; Quiz 2 **10/10 (100%) PASS**; notes re-read 2026-09-27; Quiz 3 (hard format) **9/10 (90%) PASS** — miss: exhibit still applied tag inheritance to a child resource (location correct, tags wrong)
  - [x] Module 4 Azure Policy initiatives — read 2026-09-28; Quiz 1 8/10 (80%) FAIL; notes written; Quiz 2 **9/10 (90%) PASS** — miss: Indexed still evaluates tagged resources (RGs are the skip); append/modify reason inverted
  - Policy verbal (2026-09-29): **3/4 (75%) PASS with nits**. Closed: initiative at MG, DoNotEnforce then Default, remediation, mode vs enforcementMode, Indexed skips RG, `notScopes` vs dated exemption, effect order, append/modify mutate before deny, parent Deny not canceled. Still sloppy: said **exemption** produces the compliance count (that is DoNotEnforce); did not punch "only the **assignment** evaluates"; VM "gets tagged" assumed modify (deny would reject the create); role named as Contributor instead of **Tag Contributor**; answered "RG won't be created" when the denied object was the **NIC**.
  - RBAC verbal (2026-10-01): **3.5/4 (88%) PASS with nits**. Closed: triple (principal is the right word); VM Contributor at RG; GA has no Azure access until elevate; elevate = UAA at root MG then assign then turn off; Blob Data Reader on MI vs Azure Reader on operators; inherited assignment not deletable at child; policy list ≠ RBAC. Nits: best-practice principal is a **group**; Contributor is the wrong **role** as well as the wrong scope; Azure **Reader** on the MI does **not** download — only ARM visibility.
  - SSPR verbal (2026-10-02): **3.5/4 (88%) PASS with nits**. Closed: None/Selected/All; P1+writeback for hybrid; reset 1 or 2; Lea cannot with one method when two required; admins no security questions; test non-admin; writeback off = cloud only. Nits: name **both** writeback places (Connect **and** SSPR On-premises integration); admins need **two** methods even if tenant policy is 1; unlock-without-reset clears an **AD lockout**, it is not a general “log in without a password.”
- [ ] **03 Configure and manage virtual networks for Azure administrators** — 1 of 8 modules read
  - [x] Module 1 Configure virtual networks — read 2026-10-03; Quiz 1 6/10 FAIL; Quiz 2 7/10 FAIL; Quiz 3 **9/10 (90%) PASS**; verbal (2026-10-04) **4/4 PASS with nits** — `/22` containment closed; reserved five-per-subnet named; assigned vs created/associated; legal create order. Nit: still say **NIC IP config** as the associate target and set private **static** on that config.
  - [ ] Module 2 Configure network security groups — not started
  - [ ] Module 3 Host your domain on Azure DNS — not started
  - [ ] Module 4 Configure Azure Virtual Network peering — not started
  - [ ] Module 5 Routes — not started
  - [ ] Module 6 Azure Load Balancer — not started
  - [ ] Module 7 Azure Application Gateway — not started
  - [ ] Module 8 Azure Network Watcher — not started
- [ ] **04 Implement and manage storage in Azure** — not started
- [ ] **05 Deploy and manage Azure compute resources** — not started
- [ ] **06 Monitor and back up Azure resources** — not started

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
| 2026-09-29 | 02 Module 4 — Policy verbal | 3/4 (75%) | PASS with nits — exemption≠compliance count; assignment evaluates |
| 2026-09-30 | 02 Module 5 Azure RBAC — Quiz 1 | 8/10 (80%) | FAIL — NEEDS REVIEW |
| 2026-09-30 | 02 Module 5 Azure RBAC — Quiz 2 | 7/10 (70%) | FAIL — NEEDS REVIEW |
| 2026-10-01 | 02 Module 5 Azure RBAC — Quiz 3 | 8/10 (80%) | FAIL — NEEDS REVIEW |
| 2026-10-01 | 02 Module 5 Azure RBAC — Quiz 4 | 10/10 (100%) | PASS |
| 2026-10-01 | 02 Module 5 — RBAC verbal | 3.5/4 (88%) | PASS with nits |
| 2026-10-02 | 02 Module 6 SSPR — Quiz 1 | 8/10 (80%) | FAIL — NEEDS REVIEW |
| 2026-10-02 | 02 Module 6 SSPR — Quiz 2 | 9/10 (90%) | PASS |
| 2026-10-02 | 02 Module 6 — SSPR verbal | 3.5/4 (88%) | PASS with nits |
| 2026-10-02 | 02 Path cumulative exam 1 | 9/10 (90%) | PASS |
| 2026-10-03 | 03 Module 1 Configure virtual networks — Quiz 1 | 6/10 (60%) | FAIL — NEEDS REVIEW |
| 2026-10-04 | 03 Module 1 Configure virtual networks — Quiz 2 | 7/10 (70%) | FAIL — NEEDS REVIEW |
| 2026-10-04 | 03 Module 1 Configure virtual networks — Quiz 3 | 9/10 (90%) | PASS — miss: `/22` range right, containment Yes inverted |
| 2026-10-04 | 03 Module 1 — VNet verbal | 4/4 (100%) | PASS with nits — name NIC IP config |
