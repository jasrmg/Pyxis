# AZ-104 Progress

Track: Azure Administrator (AZ-104)  
Exam contract: [Skills Measured](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104) as of **17 Apr 2026** — snapshot `AZ104-SKILLS.md`. Pearson pass **700**.  
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
- [x] **03 Configure and manage virtual networks for Azure administrators** — 8 of 8 modules quiz-passed; path exam 1 (2026-10-27) **10/10 (100%) PASS**
  - [x] Module 1 Configure virtual networks — read 2026-10-03; Quiz 1 6/10 FAIL; Quiz 2 7/10 FAIL; Quiz 3 **9/10 (90%) PASS**; verbal (2026-10-04) **4/4 PASS with nits** — `/22` containment closed; reserved five-per-subnet named; assigned vs created/associated; legal create order. Nit: still say **NIC IP config** as the associate target and set private **static** on that config.
  - [x] Module 2 Configure network security groups — read 2026-10-06; Quiz 1 7/10 FAIL; Quiz 2 **10/10 (100%) PASS**; verbal (2026-10-06) **4/4 PASS** — first-match stop; DenyAllInbound vs internet; inbound subnet then NIC; ASG on NIC, one VNet
  - [x] Module 3 Host your domain on Azure DNS — read 2026-10-14; Quiz 1 8/10 FAIL; Quiz 2 8/10 FAIL; Quiz 3 5/10 FAIL; Quiz 4 **9/10 (90%) PASS**; verbal (2026-10-16) **3/4 (75%) PASS with nits** — Closed after restatement: auto-reg = **VNet link**, writes **A** (primary NIC private IPv4), `$false` = resolution-only. Still sloppy if you skip: apex on TM is **alias A/AAAA at `@` targeting TM**; paste NS **at the registrar**.
  - [x] Module 4 Configure Azure Virtual Network peering — read 2026-10-19; Quiz 1 8/10 FAIL; Quiz 2 **10/10 (100%) PASS**; verbal (2026-10-19) **4/4 PASS with nits** — both-sides Initiated→Connected; hub transit true / remote false on hub object; not transitive. Nit: spoke-to-spoke fix is UDR **next hop = NVA** (and Allow forwarded traffic), or a **direct** spoke-spoke peering. The checkbox does not create the NVA.
  - [x] Module 5 Routes — read 2026-10-21; Quiz 1 **10/10 (100%) PASS**; verbal (2026-10-21) **4/4 PASS with nits** — subnet 0–1 table; longest prefix before UDR/BGP/system; NVA other subnet, forwarding NIC+OS. Nit: next hop **None** drops the **prefix on that UDR** (not only `0.0.0.0/0`); Virtual appliance = **NVA IP**, not “the VM” in general.
  - [x] Module 6 Azure Load Balancer — read 2026-10-23; Quiz 1 7/10 FAIL; Quiz 2 **10/10 (100%) PASS**; verbal (2026-10-23) **3/4 (75%) PASS with nits** — Closed: public vs ILB **type**, probe path/source/200, Standard closed until NSG, Deny AzureLoadBalancer breaks probes. Nit: ILB **frontend** is a **subnet private IP**, not a Standard PIP (that is public only). Attach **NIC IP config** (or IP), not “the VM.”
  - [x] Module 7 Azure Application Gateway — read 2026-10-26; Quiz 1 rescored **9/10 (90%) PASS**; verbal (2026-10-26) **3.5/4 PASS with nits**. Closed: DNS → frontend IP → listener (host + TLS) → WAF → path rule (`/images/*`) → HTTP settings → healthy pool; probe **200–399** from the gateway subnet; TCP 1433 = Load Balancer. Nit: WAF **Detection** logs and still forwards. Prevention is the mode that stops the request.
  - [x] Module 8 Azure Network Watcher — read 2026-10-27; Quiz 1 **9/10 (90%) PASS**; verbal (2026-10-27) **3.5/4 PASS with nits**, closed on restatement the same night. Next hop only reads. `DNSResolution` means fix DNS before any NSG change.
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
| 2026-10-06 | 03 Module 2 Configure NSGs — Quiz 1 | 7/10 (70%) | FAIL — NEEDS REVIEW |
| 2026-10-06 | 03 Module 2 Configure NSGs — Quiz 2 | 10/10 (100%) | PASS |
| 2026-10-06 | 03 Module 2 — NSG verbal | 4/4 (100%) | PASS |
| 2026-10-14 | 03 Module 3 Azure DNS — Quiz 1 | 8/10 (80%) | FAIL — NEEDS REVIEW |
| 2026-10-14 | 03 Module 3 Azure DNS — Quiz 2 | 8/10 (80%) | FAIL — NEEDS REVIEW — miss: record set vs two sets; auto-reg A not PTR |
| 2026-10-14 | 03 Module 3 Azure DNS — Quiz 3 | 5/10 (50%) | FAIL — NEEDS REVIEW — record set = name+type; EnableRegistration false; auto-reg is VNet link |
| 2026-10-14 | 03 Module 3 Azure DNS — Quiz 4 | 9/10 (90%) | PASS — miss: Q9 auto-reg = VNet link not PIP association |
| 2026-10-16 | 03 Module 3 — DNS verbal | 3/4 (75%) | PASS with nits — alias A at `@` to TM; NS at registrar; auto-reg = VNet link not NIC |
| 2026-10-19 | 03 Module 4 VNet peering — Quiz 1 | 8/10 (80%) | FAIL — NEEDS REVIEW — hub Allow gateway transit vs spoke Use remote gateways; Q10 both-true illegal |
| 2026-10-19 | 03 Module 4 VNet peering — Quiz 2 | 10/10 (100%) | PASS |
| 2026-10-19 | 03 Module 4 — peering verbal | 4/4 (100%) | PASS with nits — UDR next hop is the NVA |
| 2026-10-21 | 03 Module 5 Routes — Quiz 1 | 10/10 (100%) | PASS |
| 2026-10-21 | 03 Module 5 — Routes verbal | 4/4 (100%) | PASS with nits — None is per-prefix drop |
| 2026-10-23 | 03 Module 6 Load Balancer — Quiz 1 | 7/10 (70%) | FAIL — NEEDS REVIEW — probe source vs path; ILB = subnet not PIP |
| 2026-10-23 | 03 Module 6 Load Balancer — Quiz 2 | 10/10 (100%) | PASS |
| 2026-10-23 | 03 Module 6 — LB verbal | 3/4 (75%) | PASS with nits — ILB frontend is subnet private IP, not PIP |
| 2026-10-26 | 03 Module 7 Application Gateway — Quiz 1 | 9/10 (90%) | PASS — rescored; WAF is after the listener. Q5 still missed frontend IP before the listener |
| 2026-10-26 | 03 Module 7 — Application Gateway verbal | 3.5/4 | PASS with nits — Detection still forwards |
| 2026-10-27 | 03 Module 8 Network Watcher — Quiz 1 | 9/10 (90%) | PASS — Q9: Connection monitor, not effective security rules, is the ongoing check |
| 2026-10-27 | 03 Module 8 — Network Watcher verbal | 3.5/4 | PASS with nits — restated: next hop is read-only; fix DNS before an NSG change |
| 2026-10-27 | 03 Path exam 1 | 10/10 (100%) | PASS — domain 4 |
