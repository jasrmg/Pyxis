# AZ-104 Skills Measured — snapshot

**Source:** [Study guide for Exam AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104)  
**As of:** 17 April 2026  
**Fetched:** 2026-10-14  
**Pearson pass:** 700  

Re-fetch the live page before a path-level exam, a mixed exam, or a new Learn path. If Microsoft changed bullets or weights, edit this file first.

Learn is the teaching order. This file is the **exam contract**. Related topics may still appear; most items are GA.

## Weights

| ID | Domain | Weight |
| --- | --- | --- |
| 1 | Manage Azure identities and governance | 20–25% |
| 2 | Implement and manage storage | 15–20% |
| 3 | Deploy and manage Azure compute resources | 20–25% |
| 4 | Implement and manage virtual networking | 15–20% |
| 5 | Monitor and maintain Azure resources | 10–15% |

## 1. Identities and governance

**1.1** Manage Microsoft Entra users and groups — create users/groups; properties; licenses; external users; SSPR  
**1.2** Manage access to Azure resources — built-in roles; assign at scopes; interpret access assignments  
**1.3** Subscriptions and governance — Policy; locks; tags; resource groups; subscriptions; costs (alerts, budgets, Advisor); management groups

## 2. Storage

**2.1** Configure access — Storage firewalls and VNets; SAS; stored access policies; access keys; identity-based access for Azure Files  
**2.2** Storage accounts — create/configure; redundancy; object replication; encryption; Storage Explorer and AzCopy  
**2.3** Azure Files and Blob — file share; blob container; tiers; blob soft delete; Files snapshots and soft delete; blob lifecycle; blob versioning

## 3. Compute

**3.1** ARM / Bicep — interpret; modify ARM; modify Bicep; deploy; export deployment as ARM or convert ARM → Bicep  
**3.2** Virtual machines — create; encryption at host; move RG/subscription/region; sizes; disks; availability zones and sets; VM Scale Sets  
**3.3** Containers (portal) — Container Registry; Container Instances; **Container Apps**; sizing/scaling for ACI and Container Apps  
**3.4** App Service — plan; scale plan; create app; certificates and TLS; map existing custom DNS; backup; networking; deployment slots

## 4. Virtual networking

**4.1** VNets — VNets and subnets; peering; public IPs; user-defined routes; troubleshoot connectivity  
**4.2** Secure access — NSGs and ASGs; effective NSG rules; **Bastion**; **service endpoints**; **private endpoints**  
**4.3** Name resolution and load balancing — Azure DNS; internal or public load balancer; troubleshoot load balancing

Not a skills-measured heading (Learn module / docs only — do not overweight on mixed exams): Application Gateway.

## 5. Monitor and maintain

**5.1** Monitor — metrics; log settings; query/analyze logs; alert rules, action groups, alert processing rules; Insights for VMs, storage, networks; Network Watcher and **Connection monitor**  
**5.2** Backup and recovery — Recovery Services vault; Azure Backup vault; backup policy; backup/restore; Site Recovery for Azure resources; failover to secondary region; backup reports and alerts

## Mentor use

- Module quiz: Learn module ∩ these bullets.  
- Path exam: that domain’s bullets only; tag skill IDs in the post-submit key.  
- Mixed exam: obey the weight table. Cover snapshot skills the matching Learn module skipped (Bastion, private/service endpoints, Container Apps, dual backup vaults, Connection monitor).
