# Path 04 — Cumulative exam (modules 1–4)

Date issued: 2026-11-11
Scope: storage only. Firewalls and virtual networks, SAS, stored access policies, access keys, identity-based Azure Files, storage accounts, redundancy, object replication, encryption, file shares, blob containers, tiers, Files snapshots and soft delete, blob lifecycle, blob versioning, blob soft delete.
Pass: **9/10**. Closed notes, including `exam/remember.md`.

Format: balanced option lengths, mixed types, at least three exhibits. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every blank.

---

**1.** Select the **two** true statements.

A. RA-GZRS serves `-secondary` reads with no failover, and the primary is ZRS.
B. After failover the account is LRS until geo-redundancy is enabled again.
C. A read of the `-secondary` host fails the account over.
D. FileStorage accepts Standard_RAGZRS.
E. Archive can be the default tier of a new general-purpose v2 account.

---

**2.** For each statement, answer **Yes** or **No**.

1. A service SAS can be revoked by deleting its stored access policy, without regenerating key1.
2. Regenerating key1 revokes a user delegation SAS.
3. Object replication copies blob snapshots.
4. Object replication requires blob versioning on the source account and the destination account.

---

**3.** Exhibit. The blob endpoint is still `stapp001.blob.core.windows.net`. Office users come from the public internet. The app subnet is already allowed.

```json
"networkAcls": {
  "defaultAction": "Deny",
  "virtualNetworkRules": [{ "id": "/subscriptions/.../subnets/snet-app" }],
  "ipRules": []
}
```

What meets the office requirement?

A. Add the office public IP. The blob hostname is already the public endpoint.
B. Add the blob hostname to ipRules so the office can resolve it.
C. Set defaultAction to Allow. An empty ipRules list then means the office only.
D. The service endpoint replaces the public address with a private IP, so no office rule is needed.

---

**4.** Fill in the blanks. No options.

A private endpoint puts a ________ IP on a NIC in your subnet. A service endpoint leaves the storage account on its ________ IP.

---

**5.** Put these in the order that replicates new block blobs. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Enable blob versioning on both accounts.
2. Create both storage accounts and the two containers.
3. Upload the blob to the source container.
4. Create the object-replication policy from the source container to the destination container.

---

**6.** Case study. A user deletes one file inside the share `dept`. The share still exists. Share soft delete is enabled for 14 days. What brings that file back?

A. Share soft delete. A deleted file is kept for the retention period.
B. Blob versioning. A file share keeps previous bytes the same way a blob does.
C. A share snapshot taken before the delete.
D. A failover. The secondary still has the file and the primary does not.

---

**7.** Exhibit.

```text
sp=r&se=2026-11-12T00:00:00Z&spr=https&si=read-2h&sig=abc
```

What is true of this token?

A. Read and write over HTTP. si is key1.
B. An account SAS for blob and files. si implies ss=bf.
C. Read, HTTPS only, revoked by deleting the stored access policy read-2h.
D. A user delegation SAS. sig is the Entra token.

---

**8.** Exhibit. The storage account is in East US. The key vault in this snippet is in West Europe. Both are in the same subscription.

```bicep
encryption: {
  keySource: 'Microsoft.Keyvault'
  keyvaultproperties: {
    keyvaulturi: 'https://kvapp001.vault.azure.net/'
    keyname: 'cmk'
  }
}
```

What is true?

A. Accepted. Any region works when the subscription is the same.
B. Rejected. Customer-managed keys require keySource Microsoft.Storage.
C. Rejected. The vault must be in East US. A different subscription would still be allowed.
D. Accepted. West Europe is the paired region, which is where the vault must sit.

---

**9.** Select the **two** true statements.

A. One lifecycle rule can move a blob from Hot to Archive at 90 days and delete it at 365.
B. Lifecycle can move an Archive blob back to Hot after 10 days.
C. Versioning keeps the previous bytes on overwrite. Soft delete keeps a deleted blob for the retention window.
D. With versioning off, an overwrite is kept as a soft-deleted blob.
E. Object replication includes the blob’s snapshots.

---

**10.** Case study. Domain users must mount `\\stapp001.file.core.windows.net\dept`. They must not receive the account key. Which configuration meets that?

A. A SAS used as the SMB password, over TCP 443.
B. key1. An SMB mount cannot use identity.
C. A user delegation SAS, mounted the same way a blob is.
D. A directory source, a share data role, NTFS, and TCP 445.

---

## Submission — 2026-11-11

1. A, B
2. Y N N Y
3. A
4. private, public
5. 2143
6. C
7. C
8. C
9. C, A
10. D

## Score: 10/10 (100%) — PASS

| Q | Result | Skill | Key |
| --- | --- | --- | --- |
| 1 | Correct | **2.2** redundancy | A, B — RA-GZRS reads `-secondary` with no failover and the primary is ZRS. After failover the account is LRS until geo is turned back on. A read does not fail over. FileStorage is not RA-GZRS. Archive is not an account default |
| 2 | Correct | **2.1** SAS and keys; **2.2** object replication | Y N N Y — delete the stored access policy to revoke that service SAS. key1 renew does not kill a user delegation SAS. Replication does not copy snapshots. Versioning is required on both accounts |
| 3 | Correct | **2.1** firewalls and VNets | A — add the office public IP. The blob hostname stays up. Default Allow opens the internet. A service endpoint does not give the account a private IP |
| 4 | Correct | **2.1** private endpoint vs service endpoint | **private**, **public** |
| 5 | Correct | **2.2** object replication | **2 → 1 → 4 → 3** — accounts and containers, versioning on both, then the policy, then the upload |
| 6 | Correct | **2.3** Files snapshots and soft delete | C — the share still exists, so the file comes from a snapshot. Soft delete retains a deleted share |
| 7 | Correct | **2.1** SAS and stored access policies | C — `sp=r`, `spr=https`, `si` names the policy. Delete that policy to revoke it |
| 8 | Correct | **2.2** encryption | C — the vault must be in East US with the account. A different subscription is allowed. `Microsoft.Keyvault` is the customer-managed key |
| 9 | Correct | **2.3** lifecycle, versioning, blob soft delete | A, C — one rule can archive and later delete. Versioning keeps an overwrite. Soft delete keeps a delete. Lifecycle does not rehydrate Archive. Replication does not copy snapshots |
| 10 | Correct | **2.1** identity-based access for Azure Files | D — directory source, share data role, NTFS, TCP 445. A SAS does not mount SMB |

Path 04 cumulative passed. Domain 2 only. Study guide re-checked 2026-11-11; the page chrome still showed 26 Oct 2023 and the snapshot was not replaced.
