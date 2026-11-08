# Module 2 — Configure Azure Blob Storage

Learn module: [Configure Azure Blob Storage](https://learn.microsoft.com/en-us/training/modules/configure-blob-storage/) (11 units)

**Aim:** Containers, access tiers, lifecycle rules, and object replication. Skills **2.3** (container, tiers, soft delete, lifecycle, versioning) and **2.2** (object replication). SAS and access keys are the next module.

---

## Where a blob lives

A blob cannot exist on its own. The path is **account → container → blob**.

`https://stapp001.blob.core.windows.net/images/logo.png`

A container name is 3–63 characters, lowercase letters, numbers, and hyphens, unique inside that account. An account can hold any number of containers. A container can hold any number of blobs.

| Blob type | Shape | Typical use |
| --- | --- | --- |
| **Block** | Uploaded in blocks | Files, images, video. The tiers below apply to block blobs |
| **Append** | Add only at the end | Logs |
| **Page** | Random read/write, 512-byte pages | Old unmanaged disks. New VM disks are managed disks |

---

## Access tiers (block blobs)

The account default tier can be **Hot, Cool, or Cold**. **Archive is not an account default.** You set Archive on a blob.

| Tier | Access | Minimum stay | Time to first byte |
| --- | --- | --- | --- |
| **Hot** | Frequent reads and writes. Highest storage price, lowest access price | None | Milliseconds |
| **Cool** | Infrequent, still immediate | **30** days | Milliseconds |
| **Cold** | Less frequent than Cool. Cheaper to store, costlier to read | **90** days | Milliseconds |
| **Archive** | Rare. Offline | **180** days | **Hours** |

Leaving Cool, Cold, or Archive before that minimum is an **early deletion** charge.

Moving among **Hot, Cool, and Cold** is immediate. Putting a blob in **Archive** takes it offline. Bringing it back is a **rehydrate**: standard priority up to **15 hours**, or high priority within **1 hour** for objects under 10 GB. Rehydrate is not a lifecycle “move Archive to Hot after N days.”

A library read thousands of times a day belongs on **Hot**. Cool’s cheaper storage price loses to the access price.

---

## Lifecycle

A rule on a **general-purpose v2** or **premium block blob** account. Filters can be the whole account, a container, a **prefix** (`images/`), or a blob index tag.

- Move to a **cooler** tier: Hot → Cool, Cold, or Archive; Cool → Cold or Archive; Cold → Archive.
- Delete the current blob, a previous **version**, or a **snapshot**.
- Cool can be set to return to Hot **when the blob is accessed**. That is access, not “after 10 more days.”

A blob 100 days old with “cool after 30, archive after 90, delete after 365” is **archived**, not deleted.

---

## Versioning, soft delete, snapshots

| Feature | What it keeps | Exam use |
| --- | --- | --- |
| **Versioning** | The previous bytes when you **overwrite**. A delete leaves that version | **Required on source and destination** for object replication |
| **Soft delete** | A **deleted** blob or container for the retention you set (1–365 days) | “Recover an accidental delete for 14 days” |
| **Snapshot** | A read-only point-in-time copy you asked for | **Not** copied by object replication |

Overwrite history is versioning. A retention window on a delete is soft delete. One of them does not do the other job.

---

## Object replication

Async copy of block blobs from a source container to a destination container. The accounts can be in different regions. The copy includes content, metadata, and **versions**. It does **not** include snapshots.

- **Versioning on both accounts** before the policy.
- Source and destination tiers **Hot, Cool, or Cold**. Not Archive. After the copy lands you can lifecycle the destination into Archive.
- A read of the destination does not fail the storage account over. This is not GRS. GRS copies the whole account to the paired region. Object replication copies the containers you name, to the region you pick.

---

## Anonymous access

Container access has three settings. They do nothing unless the **account** allows blob anonymous access.

| Container setting | Anonymous caller |
| --- | --- |
| **Private** (default) | Nothing |
| **Blob** | Read a blob if they know the URL. No list |
| **Container** | Read and list |

Microsoft’s default for new accounts is anonymous access **off**. A container set to Blob still stays private.

---

## Create (exam stack)

```bash
az storage container create --account-name stapp001 -n images --auth-mode login

az storage account blob-service-properties update -g rg-stor --account-name stapp001 \
  --enable-versioning true --enable-delete-retention true --delete-retention-days 14
```

Lifecycle policy (block blobs under `images/`, then cooler, then delete):

```json
{
  "rules": [{
    "name": "images-age",
    "enabled": true,
    "type": "Lifecycle",
    "definition": {
      "filters": { "blobTypes": ["blockBlob"], "prefixMatch": ["images/"] },
      "actions": {
        "baseBlob": {
          "tierToCool": { "daysAfterModificationGreaterThan": 30 },
          "tierToArchive": { "daysAfterModificationGreaterThan": 90 },
          "delete": { "daysAfterModificationGreaterThan": 365 }
        }
      }
    }
  }]
}
```

```powershell
Set-AzStorageBlobServiceProperty -ResourceGroupName rg-stor -AccountName stapp001 `
  -IsVersioningEnabled $true
```

Bicep lifecycle is `Microsoft.Storage/storageAccounts/managementPolicies`, name `default`. One policy resource per account. Object replication is an object-replication policy on the account: source account, destination account, one rule per container pair.

| Flag | Meaning |
| --- | --- |
| `--enable-versioning true` | Required on **both** accounts before object replication |
| `--delete-retention-days 14` | Soft delete window |
| `tierToArchive` | Lifecycle. Not a rehydrate |
| `prefixMatch` | Only blobs under that prefix |
| Container `publicAccess: Blob` | Ignored when the account disallows anonymous access |

---

## Enterprise scenarios

### 1. “Videos are watched all day. Don’t put them in Cool to save the storage line”

**Hot.** Cool’s access price is the wrong bill for thousands of reads a day.

### 2. “After 90 days nobody opens the images, but legal hold is seven years”

Lifecycle: archive after 90 days, delete after the hold. Archive is offline. A restore is a rehydrate, up to 15 hours on standard priority.

### 3. “The same product images must be readable in West Europe without waiting for a storage-account failover”

Object replication from the East US container to a West Europe container. Versioning on **both** accounts. That is not an RA-GRS `-secondary` read, and it does not copy snapshots.

### 4. “The container is set to Blob, and anonymous GET still returns 404”

The account’s **allow blob public access** is off. The container setting cannot override that.

---

## Exam traps from this module

1. Blob → **container** → blob. Container access **Blob** is not list. Account anonymous access off wins.
2. **Hot / Cool / Cold** are online. **Archive** is hours, 180-day minimum, not an account default.
3. Hot ↔ Cool ↔ Cold is immediate. Archive → online is a **rehydrate**.
4. Lifecycle moves **cooler** or deletes. Prefix filters. Cool → Hot on **access** is the exception, not an age rule back to Hot.
5. Object replication **requires versioning on both accounts**. It does **not** copy snapshots. It does not run on Archive blobs.
6. Soft delete is the delete window. Versioning is the overwrite history.
7. Object replication is the containers you choose. Account GRS/RA-GRS is the whole account and the paired region.

## Lab in this folder

```bash
cd 04-implement-and-manage-storage/02-configure-azure-blob-storage/poc
./blob.sh            # prints the plan (no deploy)
APPLY=1 ./blob.sh    # general-purpose v2, a private container, versioning, then deletes the lab group
```
