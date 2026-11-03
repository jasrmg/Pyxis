# Module 1 (Configure storage accounts) — Quiz 1

Date issued: 2026-11-03
Scope: this Learn module — account kind, redundancy, endpoints, firewall and private endpoint. Not SAS, not object replication, not blob lifecycle.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A Standard general-purpose v2 account can hold blobs, files, queues, and tables.
B. Premium file shares can be geo-redundant (GRS).
C. You convert Standard to Premium in place, and the data stays put.
D. A private endpoint is a private IP for the storage account in your subnet.
E. Azure SQL Database lives inside the storage account.

---

**2.** For each statement, answer **Yes** or **No**.

1. LRS remains available if its datacenter is destroyed.
2. RA-GRS can be read from the secondary endpoint without a failover.
3. GRS serves reads from the secondary endpoint before any failover.
4. ZRS copies data synchronously to zones in the same region.

---

**3.** Exhibit. Goal: a **premium file share** account.

```bash
az storage account create -g rg-stor -n stfiles01 -l eastus \
  --kind FileStorage --sku Standard_GRS
```

What is true?

A. `Standard_GRS` is a valid premium file SKU.
B. Use kind `FileStorage` with `Premium_LRS` or `Premium_ZRS`.
C. Use kind `StorageV2` with `Standard_GZRS` for this premium share.
D. Change the kind to `BlobStorage` and keep `Standard_GRS`.

---

**4.** Fill in the blank. No options.

Account `stapp001`, container `images`, blob `logo.png`. Write the blob URL, including `https://`.

---

**5.** Put these in the order that makes `https://blobs.jasrmg-dev.com/images/logo.png` load. The zone `jasrmg-dev.com` already exists in Azure DNS. Reply with the numbers, like `2 → 4 → 1 → 3`.

1. On the storage account, add the custom domain `blobs.jasrmg-dev.com`.
2. Create the storage account `stapp001`.
3. Confirm the URL loads in a browser.
4. Create a CNAME from `blobs.jasrmg-dev.com` to `stapp001.blob.core.windows.net`.

---

**6.** Case study. Lowest redundancy that meets **all**:

- A zone loss in the primary region must not stop read/write.
- A regional outage must not destroy the data.
- Apps must read the paired region **without** a failover.

A. ZRS. Three zones, and geo-replication is included.
B. RA-GRS. The primary is zone-redundant and the secondary is readable.
C. GZRS. The secondary endpoint serves reads before failover.
D. RA-GZRS.

---

**7.** Exhibit. The account must accept only `snet-app` and one office public IP.

```bicep
networkAcls: {
  defaultAction: 'Allow'
  virtualNetworkRules: []
  ipRules: []
}
```

What do you change?

A. Leave `Allow`. Selected networks still override it.
B. Set `defaultAction` to `Deny`, then allow the subnet and that IP.
C. Delete `networkAcls`. Deleting it denies every network.
D. Set `defaultAction` to `Deny` and turn HTTPS off.

---

**8.** Exhibit. The account is RA-GZRS. A reader uses this host during a primary-region outage. No failover was started.

```text
https://stapp001-secondary.blob.core.windows.net/images/logo.png
```

What is true?

A. This host reads the secondary. It does not fail the account over.
B. This host is the primary. The word secondary is ignored.
C. Opening this host fails the account over and leaves it LRS.
D. This host is the Azure Files endpoint for the share.

---

**9.** Select the **two** true statements.

A. A premium block blob account also hosts queues and file shares.
B. Use Standard general-purpose v2 when one account must hold blobs, files, queues, and tables.
C. Leave a general-purpose v1 account as-is. It already has every current feature.
D. Every current storage account kind encrypts data at rest.
E. Change Premium to Standard on the same account. No copy is required.

---

**10.** The app subnet is in the same region as the account. One office public IP must still connect. The public endpoint stays up. No private endpoint.

A. Private endpoint in the subnet, and disable public network access.
B. Firewall set to selected networks: that subnet and the office public IP.
C. Firewall left open to all networks.
D. Peer the VNet to the storage account's public IP.

---

## Submission — 2026-11-03

1. A, D
2. No, Yes, No, Yes
3. A
4. `https://stapp001.blob.core.windows.net/images/logo.png`
5. 2 → 4 → 1 → 3
6. D
7. B
8. A
9. B, D
10. B

## Score: 9/10 (90%) — PASS (rescored 2026-11-03)

First mark was 8/9 with question 5 void. The stem printed `2 → 4 → 1 → 3`, which is the key. That leak is the writer's mistake. The submitted order is correct, so question 5 counts.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, D — general-purpose v2 holds all four services; a private endpoint is a private IP in the subnet |
| 2 | Correct | N Y N Y — LRS dies with the datacenter; RA-GRS reads `-secondary` with no failover; GRS does not; ZRS is sync across zones |
| 3 | **Wrong** | **B** — kind `FileStorage` with `Premium_LRS` or `Premium_ZRS`. `Standard_GRS` is not a premium file SKU |
| 4 | Correct | `https://stapp001.blob.core.windows.net/images/logo.png` |
| 5 | Correct | **2 → 4 → 1 → 3** — account, CNAME, custom domain on the account, then confirm. The stem leaked this order |
| 6 | Correct | D — **RA-GZRS** |
| 7 | Correct | B — `defaultAction: Deny`, then allow the subnet and the office IP |
| 8 | Correct | A — `-secondary` reads the paired region and does not fail the account over |
| 9 | Correct | B, D — one account for all four services is general-purpose v2; every current kind encrypts at rest |
| 10 | Correct | B — selected networks: the subnet and the office public IP |

Closed: kinds vs SQL, RA- vs GRS read, blob URL, custom-domain order, RA-GZRS, firewall Deny, secondary host, encryption at rest, selected networks.

Open: a premium file account is `FileStorage` plus **Premium_LRS** or **Premium_ZRS**. Not `Standard_GRS`.
