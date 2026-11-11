# Module 4 (Configure Azure Files) — Quiz 1

Date issued: 2026-11-11
Scope: this Learn module — file share tiers, SMB and NFS, identity and keys, snapshots, soft delete, Azure File Sync and cloud tiering. Not blob lifecycle. Not SAS parameter names.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Premium shares use a FileStorage account and only LRS or ZRS.
B. Hot, Cool, and Transaction Optimized are standard tiers on general-purpose v2.
C. A premium file share can use RA-GZRS for paired-region reads.
D. One file share can be mounted over SMB and NFS together.
E. A Cool file share is offline until you rehydrate it.

---

**2.** For each statement, answer **Yes** or **No**.

1. Soft delete for Azure Files can be turned on for an existing share.
2. The soft-delete retention period is fixed at 14 days.
3. A share snapshot can be used to restore a single file.
4. Cloud tiering sets how often the sync job runs.

---

**3.** Exhibit. You run this command.

```bash
az storage account create -g rg-stor -n stapp001 -l eastus --kind FileStorage --sku Standard_GRS
```

What is the result?

A. A geo-redundant premium file account is created.
B. Rejected. FileStorage takes Premium_LRS or Premium_ZRS only.
C. A general-purpose v2 account with GRS is created.
D. One share is created that mounts over SMB and NFS.

---

**4.** Fill in the blanks. No options.

On-premises SMB uses TCP port ________. Share soft delete keeps a deleted share for ________ to ________ days.

---

**5.** Put these in the order that syncs a Windows Server folder and then frees local disk. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Turn on cloud tiering on the server endpoint.
2. Create the Storage Sync Service in the same region as the file share.
3. Create a sync group, add the file share as the cloud endpoint, and add the server path as the server endpoint.
4. Install the Azure File Sync agent and register the server.

---

**6.** Case study. Warehouse servers must keep opening the stock files on a thin link. Files that nobody has opened in months are filling the local disk. Other offices need the same files. What meets that?

A. Move the share to Cool. That caches the warehouse files on the server.
B. Take a snapshot every hour. That cuts the bandwidth the warehouse uses.
C. Turn on cloud tiering on the server endpoint so infrequent files free local disk.
D. Set soft delete to 365 days. That keeps the warehouse volume small.

---

**7.** Exhibit.

```bash
az storage share snapshot --account-name stapp001 --name dept
```

What did this create?

A. A read-only point-in-time copy of the dept share. One file can be restored from it.
B. A soft-deleted copy of the storage account, kept for 14 days.
C. A cloud-tiered copy of dept on the warehouse server.
D. An account-level snapshot of every share and every blob container.

---

**8.** Exhibit. A domain-joined PC must mount this share. The user must not receive key1.

```text
\\stapp001.file.core.windows.net\dept
```

What do you give them?

A. A service SAS. Azure Files uses the SAS as the SMB password.
B. Identity-based SMB: a directory source and a share data role. The account key stays unused.
C. key1. It is the only credential that can mount an SMB share.
D. A user delegation SAS. Azure Files mounts with Entra the same way Blob does.

---

**9.** Select the **two** true statements.

A. Separate SMB and NFS shares can live in one storage account.
B. Port 443 is what an on-premises PC uses to mount the SMB share.
C. An access key is limited by the user’s NTFS permissions.
D. Soft delete on Azure Files applies to SMB shares as well as NFS.
E. A share snapshot is stored as a blob in the Archive tier.

---

**10.** Case study. A Windows team share must stay online, survive a region loss, and be readable in the paired region with no failover. Users authenticate with identity. The account key is not distributed. Which build meets every requirement?

A. Premium FileStorage, Premium_ZRS, NFS, storage account key.
B. General-purpose v2, Standard_RAGZRS, SMB Hot, identity-based auth.
C. General-purpose v2, Standard_ZRS, SMB Cool, SAS token as the mount password.
D. Premium FileStorage, Premium_LRS, SMB, identity-based auth.

---

## Submission 2026-11-11

1. AB
2. YNYY
3. B
4. 445, 1–365
5. 2431
6. C
7. A
8. B
9. AD
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — FileStorage is LRS or ZRS only; Hot, Cool, and Transaction Optimized are standard tiers on general-purpose v2 |
| 2 | **Wrong** | **Y N Y N** — soft delete works on an existing share; retention is not fixed at 14 days; a snapshot restores one file; cloud tiering does **not** set the sync schedule |
| 3 | Correct | B — `FileStorage` rejects `Standard_GRS`. Premium is `Premium_LRS` or `Premium_ZRS` |
| 4 | Correct | **445**, **1** to **365** |
| 5 | Correct | **2 → 4 → 3 → 1** — Storage Sync Service, register the server, sync group and endpoints, then cloud tiering on the server endpoint |
| 6 | Correct | C — cloud tiering frees local disk |
| 7 | Correct | A — share snapshot, and one file can be restored from it |
| 8 | Correct | B — identity-based SMB. A SAS is not the mount password |
| 9 | Correct | A, D — SMB and NFS shares can share an account; soft delete covers both |
| 10 | Correct | B — general-purpose v2, `Standard_RAGZRS`, SMB Hot, identity. Premium cannot be RA-GZRS |

Closed: premium SKU, soft-delete window, snapshot scope, SMB identity versus SAS, RA-GZRS on a standard share, File Sync order.

Open: cloud tiering frees disk on the server endpoint. It does not set how often sync runs.
