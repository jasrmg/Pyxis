# Module 3 (Configure Azure Storage security) — Quiz 1

Date issued: 2026-11-09
Scope: this Learn module — SAS types and URI parameters, stored access policies, account keys, encryption and customer-managed keys. Not redundancy, not blob tiers.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A user delegation SAS uses Microsoft Entra credentials and applies to Blob and Data Lake.
B. A stored access policy can revoke a service SAS without regenerating the account keys.
C. Deleting a container stored access policy revokes an account SAS signed with key1.
D. A user delegation SAS is signed with storage account key1, the same way a service SAS is.
E. The sig parameter is the account key, so the holder can mint more SAS tokens.

---

**2.** For each statement, answer **Yes** or **No**.

1. A SAS handed out over HTTP can be intercepted and replayed until it expires.
2. A start time of “now” can fail for the first few minutes because of clock skew.
3. Regenerating key2 revokes a user delegation SAS.
4. A customer-managed key requires the storage account and the key vault to be in the same region.

---

**3.** Exhibit. A client presents this URI.

```text
https://stapp001.blob.core.windows.net/images/logo.png?sp=r&st=2026-11-09T00:00:00Z&se=2026-11-09T02:00:00Z&spr=https&sip=203.0.113.10&sig=abc
```

What does this token allow?

A. Read over HTTPS from 203.0.113.10 until the expiry.
B. Read and write from any IP over HTTP or HTTPS.
C. Read and delete over HTTPS from any IP address.
D. List the container over HTTP from 203.0.113.10 only.

---

**4.** Fill in the blanks. No options.

Customer-managed keys are stored in ________ or in ________.

---

**5.** Put these in the order that issues a service SAS you can revoke without regenerating an account key. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Send the SAS URI to the client over HTTPS.
2. Create a stored access policy on the container.
3. Delete or change that policy when this client must lose access before the expiry.
4. Generate a service SAS whose si parameter names that policy.

---

**6.** Case study. A contractor needs read access to one blob for two hours. You must be able to cut that access off tonight without regenerating key1 or key2, and the contractor must not receive an account key. Which option meets every requirement?

A. Put key1 in a connection string and delete the container tonight.
B. Set the container public access to Blob until the two hours are over.
C. Issue a read-only service SAS tied to a stored access policy, HTTPS only, short expiry.
D. Issue an account SAS with no expiry so a container policy can revoke it later.

---

**7.** Exhibit. The storage account `stapp001` is in East US, subscription A. The key vault is in East US, subscription B.

```bicep
encryption: {
  keySource: 'Microsoft.Keyvault'
  keyvaultproperties: {
    keyvaulturi: 'https://kvapp001.vault.azure.net/'
    keyname: 'cmk'
  }
}
```

What is true of this customer-managed key?

A. Rejected. The vault and the account must share a subscription.
B. Rejected. Customer-managed keys keep keySource set to Microsoft.Storage.
C. Accepted. Same region is required. Subscriptions may differ.
D. Accepted only if the vault sits in the account’s paired region.

---

**8.** Exhibit. Yesterday you issued two tokens. The service SAS was signed with key1 and names no stored access policy. The other is a user delegation SAS.

```bash
az storage account keys renew -g rg-stor -n stapp001 --key key1
```

What is true after this command?

A. The key1 service SAS stops. The user delegation SAS keeps working.
B. Both tokens stop. Renewing a key revokes every SAS on the account.
C. The user delegation SAS stops. The key1 service SAS keeps working.
D. Neither token stops. Renew only changes the portal label for key1.

---

**9.** Exhibit. Select the **two** true statements about this account SAS fragment.

```text
ss=bf&sp=rw&se=2026-11-10T00:00:00Z&spr=https&sig=abc
```

A. sp=rw grants read and write.
B. spr=https means the token also accepts HTTP.
C. ss=bf covers Blob and Azure Files.
D. se is the UTC time when the SAS becomes valid.
E. sig is key1 in plain text.

---

**10.** Case study. A production app in Azure already has a managed identity. It needs ongoing access to sensitive images. The account key must not sit in the app. Which option matches the module recommendation?

A. A connection string that contains key1, stored as an app setting.
B. Shared Key authorization written in the application source.
C. An account SAS that expires in ten years, committed in the repo.
D. Microsoft Entra ID through the app’s managed identity.

---

## Submission 2026-11-09

1. AB
2. YYNY
3. A
4. key vault, hsm container
5. 2413
6. C
7. C
8. A
9. AC
10. D

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — user delegation SAS is Entra for Blob and Data Lake; a stored access policy revokes a service SAS without a key regenerate |
| 2 | Correct | Y Y N Y — HTTP SAS can be replayed; start time of now hits clock skew; key2 renew does not kill a user delegation SAS; CMK vault is same region |
| 3 | Correct | A — `sp=r`, `spr=https`, `sip=203.0.113.10`, until `se` |
| 4 | **Wrong** | **Azure Key Vault** or **Azure Key Vault Managed HSM**. An HSM container is not the store |
| 5 | Correct | **2 → 4 → 1 → 3** — policy, then the service SAS that names it with `si`, then HTTPS to the client, then delete the policy to revoke |
| 6 | Correct | C — read-only service SAS, stored access policy, HTTPS, short expiry |
| 7 | Correct | C — same region required, subscriptions may differ, `keySource` is `Microsoft.Keyvault` |
| 8 | Correct | A — key1 SAS dies; the user delegation SAS stays |
| 9 | Correct | A, C — `sp=rw` is read and write; `ss=bf` is Blob and Azure Files |
| 10 | Correct | D — Entra through the managed identity. Not the account key, and not a ten-year SAS in the repo |

Closed: SAS types, URI limits, policy-then-revoke order, key1 renew versus user delegation, CMK region versus subscription, Entra for the app.

Open: the second CMK store is **Managed HSM**, not an HSM container.
