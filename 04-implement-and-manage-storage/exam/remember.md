# Path 04 — What to remember

## Account kinds (module 1)

- **Standard general-purpose v2** (`StorageV2`): blobs (including Data Lake), files, queues, tables. The default choice. Redundancy: LRS, ZRS, GRS, RA-GRS, GZRS, RA-GZRS.
- **Premium block blobs** (`BlockBlobStorage`): block and append blobs only. **Premium_LRS** or **Premium_ZRS**. Not GRS.
- **Premium file shares** (`FileStorage`): Azure Files only. SMB and NFS. **Premium_LRS** or **Premium_ZRS**. Not GRS.
- **Premium page blobs**: page blobs only. Legacy pattern for unmanaged VM disks. New VM disks are **managed disks**, a separate resource.
- **GPv1** upgrades **in place** to general-purpose v2. **Standard ↔ Premium does not.** Create a new account and copy.
- Every current kind encrypts data at rest (storage service encryption).

One account is one policy: region, performance, redundancy, subscription. A second policy means a second account. Deleting the account deletes the data inside it. Azure SQL and Cosmos DB are not services inside a storage account.

## Endpoints

| Service | Host |
| --- | --- |
| Blob | `<account>.blob.core.windows.net/<container>/<blob>` |
| File | `<account>.file.core.windows.net/<share>` |
| Queue | `<account>.queue.core.windows.net/<queue>` |
| Table | `<account>.table.core.windows.net/<table>` |
| RA-GRS / RA-GZRS read | `<account>-secondary.blob.core.windows.net/...` |

Custom domain for blobs is a **CNAME on a subdomain** (for example `blobs.jasrmg-dev.com`) aimed at the blob host. Not the zone apex.

Name: **3–24** characters, lowercase letters and numbers, globally unique.

## Redundancy

Primary copies are synchronous. Geo copy is asynchronous, to the **paired** region.

| | Zone loss, still read/write | Region loss | Read secondary with no failover |
| --- | --- | --- | --- |
| **LRS** | No. Three copies, one datacenter | No | No |
| **ZRS** | Yes. Three zones, one region | No | No |
| **GRS** | No. Primary is LRS | Data is in the pair. Primary endpoint is down until **failover** | No |
| **RA-GRS** | No | Same as GRS | **Yes**, `-secondary` host |
| **GZRS** | Yes. Primary is ZRS | Failover for the other region | No |
| **RA-GZRS** | Yes | Failover for writes in the other region | **Yes**, `-secondary` host |

Reading `-secondary` does **not** fail the account over. Failover is a separate action. After failover the account is **LRS** until you turn geo-redundancy back on.

Lowest option that survives a zone, survives a region, and can be read in the other region without failover: **RA-GZRS**.

## Network access (skill 2.1, this module’s endpoint unit)

- **Service endpoint** on the subnet: the account **keeps its public IP**. The firewall allows that subnet. Subnet is in the **same region or the paired region**.
- **Private endpoint**: a **NIC and a private IP in your subnet**. Public access can be turned off. Private DNS zone so the blob name resolves to that private IP.
- Firewall **default Deny**, then allow selected subnets and public IPs. Default Allow is the open internet.
- **Secure transfer required** means HTTPS only.

## Blob (module 2)

- Account → **container** → blob. Container name 3–63, lowercase, unique in the account.
- Tiers for **block** blobs: **Hot** (frequent), **Cool** (30-day minimum), **Cold** (90), **Archive** (180, offline, hours to rehydrate). Account default is Hot, Cool, or Cold. Not Archive.
- Hot ↔ Cool ↔ Cold is immediate. Archive → online is a **rehydrate** (standard up to 15 hours).
- Lifecycle moves **cooler** or deletes. Prefix filter. Early delete before the minimum stay costs extra. Cool → Hot **on access** is the exception.
- **Versioning** = overwrite history. **Soft delete** = deleted blob or container for N days. **Snapshot** is not copied by object replication.
- Object replication: versioning on **source and destination**, Hot/Cool/Cold only, containers you name. Not account GRS, and not a failover.

## Storage security (module 3)

- **key1 / key2** authorize the caller and sign account SAS and service SAS. **CMK** encrypts bytes at rest. Rotating one does not rotate the other.
- **User delegation SAS:** Entra, Blob and Data Lake, no stored access policy, survives a key regenerate. Delegation key max **7 days**.
- **Service SAS:** one resource, account key, **can** name a stored access policy with `si`. Delete the policy to revoke it. Max **5** policies on a container, share, queue, or table.
- **Account SAS:** `ss` services (`bf` = blob and files). No stored access policy.
- `sp` permissions, `st` start, `se` expiry, `spr=https` is HTTPS only, `sig` is the HMAC not the key. Clock skew **15 minutes**.
- Regenerating key1 kills only SAS tokens signed with key1. `--allow-shared-key-access false` kills Shared Key and key-signed SAS. Entra and user delegation SAS remain.
- CMK: Key Vault or Managed HSM, **same region**, subscription may differ. `Microsoft.Keyvault` vs `Microsoft.Storage`. SSE cannot be turned off.
- Production data access the module wants: **Entra ID or a SAS**. Not Shared Key in the app. Contributor on the account does not read blob bytes.
