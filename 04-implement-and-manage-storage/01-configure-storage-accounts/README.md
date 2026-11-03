# Module 1 — Configure storage accounts

Learn module: [Configure storage accounts](https://learn.microsoft.com/en-us/training/modules/configure-storage-accounts/) (9 units)

**Aim:** Pick the account kind, the redundancy, and how the endpoint is reached. Skills **2.2** (create, redundancy, encryption) and **2.1** (firewalls and VNets). SAS, stored access policies, and access keys are the security module. Object replication, tiers, and lifecycle are the Blob module.

---

## What sits in the account

A storage account is one set of settings for **blobs, files, queues, and tables**. Azure SQL and Cosmos DB are their own resources. They are not inside the account.

| Service | What it stores | Endpoint shape |
| --- | --- | --- |
| **Blob** | Unstructured objects. HTTP. Images, video, backup | `https://stapp001.blob.core.windows.net/images/logo.png` |
| **Files** | SMB or NFS share mounted by many VMs | `https://stapp001.file.core.windows.net/<share>` |
| **Queue** | Messages for async work. One message up to **64 KB** | `https://stapp001.queue.core.windows.net/<queue>` |
| **Table** | Schemaless NoSQL rows. Not Azure SQL | `https://stapp001.table.core.windows.net/<table>` |

Data Lake is blob storage with a hierarchical namespace. The blob host is still the object endpoint.

A custom blob name such as `blobs.jasrmg-dev.com` is a **CNAME** to `stapp001.blob.core.windows.net`. That is a subdomain. The zone apex cannot be a CNAME.

---

## Kinds

| Kind | Services | Redundancy you can pick | Use |
| --- | --- | --- | --- |
| **Standard general-purpose v2** | Blobs, files, queues, tables | LRS, ZRS, GRS, RA-GRS, GZRS, RA-GZRS | Almost everything |
| **Premium block blobs** | Block and append blobs only | LRS, ZRS | High transaction rate, low latency |
| **Premium file shares** | Files only (SMB and NFS) | LRS, ZRS | High-performance shares |
| **Premium page blobs** | Page blobs only | LRS (ZRS in some regions) | Old unmanaged VM disks |

You do **not** convert Standard to Premium, or Premium to Standard, on the same account. Create the other account and copy. A **general-purpose v1** account **does** upgrade in place to v2. Do that. v1 is missing current features.

New VM OS and data disks are **managed disks**. Do not plan a new VM disk as a page blob in a storage account.

Every current kind encrypts data at rest with storage service encryption. Secure transfer required forces **HTTPS**.

---

## Redundancy

The account has one redundancy setting. It applies to the services in that account.

| Setting | Copies | Zone failure | Other region | Read the other region with no failover |
| --- | --- | --- | --- | --- |
| **LRS** | 3 in one datacenter | Primary down | No | No |
| **ZRS** | 3 zones, sync, one region | Still read/write | No | No |
| **GRS** | LRS primary, async to the pair | Primary down until failover | Data is there | No |
| **RA-GRS** | Same as GRS | Same | Data is there | **Yes**, `<account>-secondary.blob.core.windows.net` |
| **GZRS** | ZRS primary, async to the pair | Still read/write | Data is there | No |
| **RA-GZRS** | Same as GZRS | Still read/write | Data is there | **Yes**, the `-secondary` host |

Geo copy is asynchronous. The secondary can lag. ZRS and GZRS are not offered in every region.

The Learn unit says the secondary is used only if Microsoft fails the account over. Customers can start that failover too. Two facts the items use:

- **RA-GRS and RA-GZRS** read the secondary **before** any failover. A read does not fail the account over.
- **GRS and GZRS** do not serve that secondary host until failover. After failover the account is **LRS** until you turn geo-redundancy back on.

Lowest setting that is still read/write after a zone loss, still has the data after a region loss, and can be read in the other region without a failover: **RA-GZRS**.

---

## Who can open the endpoint

| Control | Public endpoint | What you add |
| --- | --- | --- |
| Firewall default **Allow** | Open | Nothing. This is the insecure default once you intended to lock it |
| Firewall default **Deny**, selected networks | Still the public IP | Subnets (service endpoint) and public IPs. Subnet must be in the **same region or the paired region** |
| **Private endpoint** | Can be disabled | A NIC with a private IP in your subnet, plus a private DNS zone so the blob name resolves to that IP |

A service endpoint does not give the account a private IP. A private endpoint does.

---

## Create (exam stack)

```bash
az storage account create -g rg-stor -n stapp001 -l eastus \
  --kind StorageV2 --sku Standard_GZRS \
  --https-only true --min-tls-version TLS1_2

az storage account update -g rg-stor -n stapp001 --default-action Deny
az storage account network-rule add -g rg-stor -n stapp001 \
  --vnet-name vnet-app --subnet snet-app
```

Premium files: `--kind FileStorage --sku Premium_LRS` (or `Premium_ZRS`). Premium block blobs: `--kind BlockBlobStorage --sku Premium_LRS`.

```powershell
New-AzStorageAccount -ResourceGroupName rg-stor -Name stapp001 -Location eastus `
  -SkuName Standard_GZRS -Kind StorageV2 -EnableHttpsTrafficOnly
```

Bicep: `Microsoft.Storage/storageAccounts`, `kind: 'StorageV2'`, `sku.name: 'Standard_GZRS'`. `properties.supportsHttpsTrafficOnly: true`. `networkAcls.defaultAction: 'Deny'` plus a virtual network rule. `defaultAction: 'Allow'` leaves the public endpoint open.

| Flag | Meaning |
| --- | --- |
| `--kind StorageV2` | General-purpose v2 |
| `--sku Standard_RAGZRS` | RA-GZRS. The CLI token has no hyphen |
| `--sku Premium_LRS` with `--kind FileStorage` | Premium file share. Not `Standard_GRS` |
| `--https-only true` | Secure transfer required |
| `--default-action Deny` | Firewall closed until a rule allows a subnet or IP |

---

## Enterprise scenarios

### 1. “One account for the web tier: blobs, a file share, and a queue, and a zone plus a region must not wipe us out”

Standard general-purpose v2, **GZRS** or **RA-GZRS**. Premium file and premium block blob accounts cannot hold all three services and cannot be GRS.

### 2. “We must read last night’s blobs from the paired region while the primary is down, and we must not click Failover”

**RA-GRS** or **RA-GZRS**, URL host `<account>-secondary.blob.core.windows.net`. GRS has the bytes in the pair and still will not serve that host.

### 3. “App subnet in East US, plus this one office IP. Nobody else”

Firewall default **Deny**. Service endpoint on the subnet, allow that subnet and the office IP. The subnet has to be in the same region or the paired region. A private endpoint is the tighter option when the public endpoint should go away.

### 4. “Turn this Premium file account into Standard GRS”

Not on this account. New general-purpose v2 account, copy the share.

---

## Exam traps from this module

1. **StorageV2** is the general-purpose account. Premium kinds are **blobs only** or **files only**, and their SKU is **Premium_LRS** or **Premium_ZRS**.
2. **LRS** dies with the datacenter. **ZRS** survives a zone, not a region. **GRS** is not readable on `-secondary` until failover. **RA-** is.
3. Failover is not a read. After failover the account is **LRS** until geo is enabled again.
4. Standard ↔ Premium is a **new account**. GPv1 → v2 is in place.
5. Private endpoint = private IP. Service endpoint = public IP plus a firewall rule.
6. Blob URL is `https://<account>.blob.core.windows.net/<container>/<blob>`. Custom name is a CNAME on a **subdomain**.
7. Azure SQL is not a storage-account service. New VM disks are managed disks.

## Lab in this folder

```bash
cd 04-implement-and-manage-storage/01-configure-storage-accounts/poc
./storage-account.sh            # prints the plan (no deploy)
APPLY=1 ./storage-account.sh    # Standard_GZRS general-purpose v2, then deletes the lab group
```
