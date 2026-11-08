# Path 04 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–2** (storage accounts + Blob). Grows with storage security and Azure Files.

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
