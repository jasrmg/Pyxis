# Module 4 — Configure Azure Files

Learn module: [Configure Azure Files](https://learn.microsoft.com/en-us/training/modules/configure-azure-files-file-sync/) (9 units)

**Aim:** A mounted file share, plus the two ways you get a file back, plus Azure File Sync when a Windows Server still has to look local. Skills **2.3** (file share, snapshots, soft delete) and **2.1** (identity-based access for Azure Files). Storage Explorer is skill **2.2**.

A share is not a blob container. Clients mount it. Blob clients call HTTP. Azure Files has no Archive tier. Cool on a file share is still online.

---

## Where the share lives

Classic shares sit in a storage account. The endpoint is `https://stapp001.file.core.windows.net/dept`, and Windows mounts `\\stapp001.file.core.windows.net\dept`.

| Tier | Account | Media | Redundancy | Bill |
| --- | --- | --- | --- | --- |
| **Premium** | `FileStorage` | SSD | **LRS or ZRS only** | Provisioned capacity |
| **Transaction Optimized** | General-purpose v2 | HDD | LRS, ZRS, GRS, RA-GRS, GZRS, RA-GZRS | Pay as you go |
| **Hot** | General-purpose v2 | HDD | Same as Transaction Optimized | Pay as you go |
| **Cool** | General-purpose v2 | HDD | Same | Pay as you go |

Premium is `FileStorage` with **`Premium_LRS` or `Premium_ZRS`**. `Standard_GRS` on that kind is rejected. A share that must be read in the paired region without failover is a **standard** tier on general-purpose v2, **RA-GZRS**. Hot is the general team share. Transaction Optimized is the high-transaction standard tier. Cool is the cheap online share, not blob Archive.

One share is **SMB or NFS**, not both. One account can hold an SMB share and an NFS share side by side.

- **SMB** is the Windows mount. Also Linux and macOS. TCP **445**. Home ISPs often block 445 outbound. That is the usual on-premises mount failure. A VPN or ExpressRoute is the path around it.
- **NFS** is Linux. Premium SSD. Lock it with a private endpoint or a service endpoint. Windows does not mount it.

The unit also notes a newer file share that does not sit in a storage account. Exam items still use the account: general-purpose v2 or `FileStorage`.

---

## Who can mount it

| Method | Use |
| --- | --- |
| **Identity over SMB** | On-premises **AD DS**, **Microsoft Entra Domain Services**, or **Microsoft Entra Kerberos**. Then a share role. |
| **Account key** | Full control. Bypasses identity restrictions. Do not hand it to users. |
| **SAS** | REST calls from code. Not the password for an SMB mount. |

Share roles: **Storage File Data SMB Share Reader**, **Contributor**, **Elevated Contributor**. Elevated Contributor is the one that can change ownership and permissions.

Identity still has a second gate. The share role lets the user in. **NTFS** permissions on the folder decide which files they see. Both have to allow the user. The storage key skips both.

---

## Snapshots and soft delete

These fix different losses.

| | Snapshot | Soft delete |
| --- | --- | --- |
| What it is | Read-only point-in-time copy of **one share** | A deleted **share** stays recoverable |
| Where you turn it on | On that share | On the storage account’s file service. New or existing shares |
| How long | Until you delete it. Up to **200** per share | **1 to 365** days. Notff a fixed 14 |
| Restore | One file, one folder, or the whole share. The latest snapshot is enough for a full restore | The share, snapshots included, inside the retention window |
| SMB and NFS | Both | Both. Not NFS-only |

Snapshots are incremental and use the share’s redundancy. Deleting the share with soft delete **off** deletes its snapshots. Soft delete **on** means that delete is reversible until the retention ends.

A snapshot does not shrink a Windows Server disk. Soft delete does not put one overwritten file back while the share still exists. That file comes from a snapshot.

---

## Azure File Sync

Use this when offices need the same files and a local Windows Server has to serve them, including a site with a thin link.

| Piece | Role |
| --- | --- |
| **Storage Sync Service** | The Azure resource. Same region as the file share |
| **Registered server** | Windows Server with the File Sync agent |
| **Sync group** | One **cloud endpoint** (the Azure file share) and one or more **server endpoints** (folders on registered servers) |
| **Cloud tiering** | On a server endpoint. Infrequent files leave the local disk and stay in the Azure share. Opening the file brings the bytes back |

Cloud tiering frees space on the **local** volume. It does not set the sync schedule, and it is not a backup. The volume free-space policy keeps a percent of the disk empty. The date policy tiers files that have not been opened in N days.

Order that has to hold: create the Storage Sync Service, install the agent and register the server, create the sync group and add the cloud endpoint and the server endpoint, then turn on cloud tiering on that server endpoint.

---

## Commands

```bash
az storage share-rm create -g rg-stor --storage-account stapp001 -n dept \
  --quota 100 --access-tier Hot

az storage account file-service-properties update -g rg-stor --account-name stapp001 \
  --enable-delete-retention true --delete-retention-days 14

az storage share snapshot --account-name stapp001 -n dept --auth-mode login
```

Premium account, from module 1: `--kind FileStorage --sku Premium_LRS` or `Premium_ZRS`.

---

## Exam traps

- `FileStorage` plus `Standard_GRS` is illegal. Geo-redundant Azure Files is a standard tier on general-purpose v2.
- Cool on a file share is online. Archive is a blob tier.
- SAS does not mount SMB. Port 445 does. The account key mounts it and bypasses the share role and NTFS.
- A snapshot is not account-wide, and you can restore one file from it.
- Soft delete is 1–365 days, new or existing shares, SMB and NFS. The knowledge-check line that says “only 14 days” or “only NFS” is the distractor.
- Cloud tiering is the local-disk feature. It is not the sync frequency.
