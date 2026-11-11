# Path 04 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–4** (storage accounts, Blob, storage security, Azure Files).

## Module 1 — Storage accounts

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| General-purpose v2 | `az storage account create -g rg -n stapp001 -l eastus --kind StorageV2 --sku Standard_GZRS --https-only true --min-tls-version TLS1_2` | `New-AzStorageAccount -SkuName Standard_GZRS -Kind StorageV2` |
| Premium file share | `az storage account create ... --kind FileStorage --sku Premium_LRS` | kind `FileStorage`, SKU `Premium_LRS` or `Premium_ZRS` |
| Premium block blobs | `az storage account create ... --kind BlockBlobStorage --sku Premium_LRS` | kind `BlockBlobStorage` |
| Firewall deny by default | `az storage account update -g rg -n stapp001 --default-action Deny` | `Update-AzStorageAccountNetworkRuleSet -DefaultAction Deny` |
| Allow a subnet | `az storage account network-rule add -g rg -n stapp001 --vnet-name vnet-app --subnet snet-app` | `Add-AzStorageAccountNetworkRule -VirtualNetworkResourceId` |

**Trap:** SKU is `Standard_GRS`, `Standard_RAGRS`, `Standard_GZRS`, `Standard_RAGZRS`, `Premium_LRS`, `Premium_ZRS`. Premium file and premium block blob kinds do not take a GRS SKU. Standard and Premium are not an in-place conversion.

## Module 2 — Blob Storage

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Private container | `az storage container create --account-name stapp001 -n images --auth-mode login --public-access off` | `New-AzStorageContainer -Permission Off` |
| Versioning and 14-day soft delete | `az storage account blob-service-properties update -g rg --account-name stapp001 --enable-versioning true --enable-delete-retention true --delete-retention-days 14` | `Set-AzStorageBlobServiceProperty -IsVersioningEnabled $true` |
| Lifecycle policy | `az storage account management-policy create -g rg --account-name stapp001 --policy @policy.json` | `Set-AzStorageAccountManagementPolicy` |

**Trap:** Object replication needs versioning on **both** accounts. It does not copy snapshots. Archive is not an online tier and is not an account default. Container `publicAccess: Blob` does nothing when the account disallows anonymous access.

## Module 3 — Storage security

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Stored access policy on a container | `az storage container policy create --account-name stapp001 -c images -n read-2h --permissions r --expiry <utc> --auth-mode login` | `New-AzStorageContainerStoredAccessPolicy -Policy read-2h -Permission r` |
| Service SAS that names the policy | `az storage blob generate-sas --account-name stapp001 -c images -n logo.png --policy-name read-2h --https-only --auth-mode key` | `New-AzStorageBlobSASToken -Policy read-2h -Protocol HttpsOnly` |
| Regenerate key1 | `az storage account keys renew -g rg -n stapp001 --key key1` | `New-AzStorageAccountKey -KeyName key1` |
| Turn off Shared Key | `az storage account update -g rg -n stapp001 --allow-shared-key-access false` | `Set-AzStorageAccount -AllowSharedKeyAccess $false` |

**Trap:** `si` is the stored access policy, and only a **service** SAS can use it. Regenerating key1 kills SAS tokens signed with key1, not a user delegation SAS and not a SAS signed with key2. CMK is `keySource: Microsoft.Keyvault` in the **same region**. That key is not key1.

## Module 4 — Azure Files

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Hot SMB share | `az storage share-rm create -g rg --storage-account stapp001 -n dept --quota 100 --access-tier Hot` | `New-AzRmStorageShare -Name dept -QuotaGiB 100 -AccessTier Hot` |
| Share soft delete, 14 days | `az storage account file-service-properties update -g rg --account-name stapp001 --enable-delete-retention true --delete-retention-days 14` | `Update-AzStorageFileServiceProperty -EnableShareDeleteRetentionPolicy $true -ShareRetentionDays 14` |
| Share snapshot | `az storage share snapshot --account-name stapp001 -n dept --auth-mode login` | `New-AzStorageShare -Name dept -Snapshot` |

**Trap:** SMB mount port is **445**. A SAS does not mount the share. `FileStorage` is `Premium_LRS` or `Premium_ZRS` only. Soft delete is **1–365** days on the account file service. Cloud tiering is on the **server endpoint**, after the Storage Sync Service, the registered server, and the sync group.
