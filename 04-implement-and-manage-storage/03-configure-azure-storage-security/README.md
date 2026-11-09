# Module 3 — Configure Azure Storage security

Learn module: [Configure Azure Storage security](https://learn.microsoft.com/en-us/training/modules/configure-storage-security/) (10 units)

**Aim:** Who can call the data plane, and who holds the encryption key. Skills **2.1** (SAS, stored access policies, access keys) and **2.2** (encryption). Identity-based Azure Files is skill 2.1 and is finished in the Files module. Firewalls and private endpoints were module 1.

---

## Three different secrets

| Secret | What it does | Where it lives |
| --- | --- | --- |
| **Account key** (`key1`, `key2`) | Shared Key auth. Full data-plane access. Also signs account SAS and service SAS | The storage account. Key Vault can store and rotate the keys |
| **SAS token** | Limited rights, a time window, optional IP and HTTPS. The client never receives the account key | A query string. `sig` is an HMAC, not the key |
| **Customer-managed key** | Encrypts bytes at rest. Does not authorize a caller | Your Key Vault or Managed HSM |

Rotating the encryption key does not revoke a SAS. Regenerating `key1` does not roll the customer-managed key. The Learn assessment’s “use Key Vault to rotate access keys” is the **account key**, not the CMK.

---

## SAS types

| Type | Signed with | Reaches | Stored access policy |
| --- | --- | --- | --- |
| **User delegation** | Microsoft Entra (a user delegation key) | Blob and Data Lake | No |
| **Service** | Account key | One resource in one service (a blob, container, share, queue, table) | **Yes.** This is the one the policy can revoke |
| **Account** | Account key | Service operations and more than one service (`ss`) | No |

A user delegation SAS stays valid until its delegation key expires even if you later remove the user’s role. The delegation key lifetime maxes at **7 days**, and the SAS cannot outlive that key. Regenerating `key1` or `key2` does **not** revoke it.

A service SAS or account SAS with no stored access policy is revoked only by waiting for `se`, or by regenerating the **account key that signed it**.

---

## Stored access policy

Defined on a container, file share, queue, or table. At most **5** policies on that resource. The service SAS names the policy with **`si`**.

Create the policy first, then mint the SAS. Delete or change the policy and every SAS that names it stops, without regenerating `key1` or `key2`. Other SAS tokens that use a different policy, or no policy, keep working.

---

## URI parameters (the unit table)

`https://stapp001.blob.core.windows.net/images/logo.png?sp=r&st=...&se=...&spr=https&sip=203.0.113.10&sig=...`

| Parameter | Meaning |
| --- | --- |
| `sv` | Storage service version |
| `ss` | Services. `b` blob, `f` file, `q` queue, `t` table. `bf` is blob and files. Account SAS |
| `srt` | Resource types on an account SAS: `s` service, `c` container, `o` object |
| `st` / `se` | Start and expiry, UTC. Omit `st` to be valid immediately |
| `sr` | Resource. `b` blob, `c` container |
| `sp` | Permissions. `r` read, `w` write, `d` delete, `l` list, `c` create, `a` add |
| `sip` | IP or range that may present the SAS |
| `spr` | `https` only, or `https,http` |
| `si` | Stored access policy name |
| `sig` | HMAC-SHA256 signature. Not the account key |

Clock skew is up to **15 minutes**. Set `st` at least 15 minutes in the past, or omit it. A start time of “now” fails for the first few minutes. Always distribute the URI over **HTTPS**. A token caught on HTTP can be replayed until `se`.

For a REST version older than 2012-02-12, a SAS with no stored access policy lasts at most **1 hour**.

---

## Account keys

Two keys, both full access. Rotation without downtime: switch clients to the other key, regenerate the one they left, switch back, regenerate the second. `az storage account keys renew --key key1` invalidates every account SAS and service SAS **signed with key1**. It does not touch a user delegation SAS, and it does not touch a SAS signed with key2.

`--allow-shared-key-access false` turns off Shared Key. Key1, key2, and key-signed SAS stop. Entra auth and user delegation SAS still work.

The module assessment’s recommendation for data access is **Microsoft Entra ID or a SAS**. Shared Key and a connection string are the patterns it rejects for production. A 10-year SAS checked into a repo fails the unit’s own rule: short expiry, and a policy when you must revoke early.

---

## Encryption

Storage service encryption is on for every current account and cannot be turned off. Default is a Microsoft-managed key, 256-bit AES. That protects data **at rest**. `spr=https` and secure transfer required protect data **in transit**. Neither one decides whether a caller is allowed.

Customer-managed keys live in **Azure Key Vault** or **Key Vault Managed HSM** (FIPS 140-2 Level 3). You can create, disable, audit, rotate, and authorize the key. The storage account and the vault must be in the **same region**. They may be in **different subscriptions**. The account’s managed identity needs wrap, unwrap, and get on that key. If the key is disabled or the identity loses those rights, reads and writes fail.

`keySource: Microsoft.Keyvault` means the customer holds the key. `Microsoft.Storage` means Microsoft holds it. Infrastructure encryption (a second AES layer) is chosen **at account creation** and cannot be turned off later.

---

## Azure Files identity (skill 2.1, finished next module)

SMB identity needs a directory: **AD DS**, **Microsoft Entra Domain Services**, or **Microsoft Entra Kerberos**. Access then needs both a share role (`Storage File Data SMB Share Reader`, `Contributor`, or `Elevated Contributor`) and an NTFS permission. The account key mounts the share with full control and skips that identity path.

---

## Commands

```bash
az storage container policy create --account-name stapp001 -c images -n read-2h \
  --permissions r --expiry 2026-11-10T00:00:00Z --auth-mode login

az storage blob generate-sas --account-name stapp001 -c images -n logo.png \
  --policy-name read-2h --https-only --auth-mode key

az storage account keys renew -g rg-stor -n stapp001 --key key1
az storage account update -g rg-stor -n stapp001 --allow-shared-key-access false
```

```bicep
encryption: {
  keySource: 'Microsoft.Keyvault'
  keyvaultproperties: {
    keyvaulturi: 'https://kvapp001.vault.azure.net/'
    keyname: 'cmk'
  }
}
```

The vault in that snippet has to be in the account’s region.

---

## Exam traps

- `sig` is not the account key. `se` is expiry. `st` is start. `spr=https` does not allow HTTP.
- A stored access policy revokes a **service** SAS. It does not attach to an account SAS or a user delegation SAS.
- Regenerating key1 does not revoke a user delegation SAS or a SAS signed with key2.
- CMK same region, any subscription. The CMK is not key1.
- Contributor on the storage account manages the resource. Blob bytes need a data role such as **Storage Blob Data Contributor**, or a SAS.
