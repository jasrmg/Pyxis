# Module 2 (Configure Azure Blob Storage) — Quiz 1

Date issued: 2026-11-08
Scope: this Learn module — containers, tiers, lifecycle, versioning, soft delete, object replication. Not SAS.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Hot is the frequent-access tier. Its access price is the lowest of the four.
B. Cool is for data that stays at least 30 days and is still read immediately.
C. Archive returns the first byte in milliseconds.
D. Cold’s minimum stay is 30 days.
E. A blob can be stored without a container.

---

**2.** For each statement, answer **Yes** or **No**.

1. Changing a blob from Hot to Cool completes immediately.
2. Rehydrating a blob from Archive to Hot completes immediately.
3. Object replication copies blob snapshots.
4. Object replication requires blob versioning on the source account and the destination account.

---

**3.** Exhibit. A block blob at `images/logo.png` was last modified **100** days ago.

```json
"actions": {
  "baseBlob": {
    "tierToCool": { "daysAfterModificationGreaterThan": 30 },
    "tierToArchive": { "daysAfterModificationGreaterThan": 90 },
    "delete": { "daysAfterModificationGreaterThan": 365 }
  }
}
```

What is the blob’s state after this rule runs?

A. Deleted. 100 days is past the first threshold.
B. In Archive. The delete day has not been reached.
C. Still Hot. Lifecycle rules only delete.
D. In Cool. Archive is not a lifecycle action.

---

**4.** Fill in the blanks. No options.

The Archive tier’s minimum stay before an early-deletion charge is ________ days. A standard-priority rehydrate can take up to ________ hours.

---

**5.** Put these in the order that replicates **new** block blobs from East US to West Europe. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Enable blob versioning on both accounts.
2. Create both storage accounts and the two containers.
3. Create the object-replication policy from the source container to the destination container.
4. Upload the blob to the source container.

---

**6.** Case study. A video library is read thousands of times a day. Viewers must get the first byte immediately. Pick the tier that fits that pattern.

A. Archive. The storage price is the lowest.
B. Cold. Reads are immediate, and a library can sit for 90 days.
C. Hot. Reads are immediate, and this library is read all day.
D. Cool. This is the tier for data you rarely open.

---

**7.** Exhibit. Anonymous `GET` of a blob in `images`.

```json
"allowBlobPublicAccess": false
```

```json
"publicAccess": "Blob"
```

The first property is on the storage account. The second is on the container. What happens?

A. The GET succeeds. Container access Blob overrides the account.
B. The GET fails. Anonymous access is off on the account.
C. The GET succeeds, and an anonymous list of the container succeeds.
D. The GET fails because a container name cannot exceed 24 characters.

---

**8.** Exhibit. You then create an object-replication policy from `stsrc` to `stdst`.

```bash
az storage account blob-service-properties update -g rg-stor --account-name stsrc \
  --enable-versioning true
```

`stdst` still has versioning off. What is true?

A. Replication runs. Only the source account needs versioning.
B. Turn versioning on for `stdst` as well. Both accounts need it.
C. Replication runs, and snapshots on `stsrc` are copied.
D. Turn versioning off on `stsrc`. Object replication forbids versioning.

---

**9.** Select the **two** true statements about lifecycle management.

A. One rule can move a blob from Hot to Archive and delete it on a later day.
B. One rule can move a blob from Archive to Hot after it is 10 days older.
C. A prefix filter such as `images/` limits which blobs the rule sees.
D. Lifecycle archive actions target page blobs.
E. Deleting a Cool blob on day 1 never adds an early-deletion charge.

---

**10.** A deleted blob must be recoverable for **14 days**. An overwrite must keep the previous bytes. What meets both?

A. Soft delete for 14 days. An overwrite is kept as a deleted blob.
B. Versioning only. A delete is kept for 14 days with no other setting.
C. Soft delete for 14 days, and versioning.
D. Object replication to a second account. That sets the 14-day window.

---

## Submission 2026-11-08

1. AB
2. YNNY
3. B
4. 180, 15
5. 2314
6. C
7. B
8. B
9. AC
10. C

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — Hot is frequent access and the cheapest to read; Cool stays at least 30 days and is still online |
| 2 | Correct | Y N N Y — Hot to Cool is immediate; Archive rehydrate is not; replication does not copy snapshots; versioning is required on both accounts |
| 3 | Correct | B — at 100 days Archive (90) has been reached and delete (365) has not. When two tier actions match, the cooler one is applied |
| 4 | Correct | **180** days, **15** hours |
| 5 | **Wrong** | **2 → 1 → 3 → 4** — create the accounts and containers, enable versioning on both, then create the policy, then upload. The policy cannot be created while versioning is off |
| 6 | Correct | C — Hot |
| 7 | Correct | B — `allowBlobPublicAccess: false` wins. Container `Blob` does nothing |
| 8 | Correct | B — `stdst` needs versioning too |
| 9 | Correct | A, C — one rule can archive now and delete later; a prefix filter limits the blobs. Lifecycle does not move Archive back to Hot |
| 10 | Correct | C — soft delete covers the delete window; versioning keeps the bytes an overwrite would replace |

Closed: tiers and minimum stays, lifecycle day math, anonymous access gated on the account, versioning on both sides of replication, soft delete plus versioning.

Open: the replication policy is step 3. Versioning on both accounts is step 2, before that policy.
