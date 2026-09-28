# Module 4 (Azure Policy initiatives) — Quiz 2

Date issued: 2026-09-28
Prerequisite: Quiz 1 scored 8/10 FAIL (`notScopes` vs exemption, `mode` vs `enforcementMode`, effect order).
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** correct statements.

A. `notScopes` on an assignment removes those children from evaluation and from the compliance count.
B. A Waiver exemption and a `notScopes` entry produce the same compliance report for the skipped resource.
C. Mitigated means the policy intent is met by another control; Waiver means the risk is accepted for now.
D. An exemption is stored as a property array on the policy definition.
E. Child Audit assignments cancel a parent Deny assignment at the same resource.

---

**2.** For each statement, answer **Yes** or **No**.

1. `DoNotEnforce` is a valid value for a policy definition's `mode` property.
2. `Indexed` mode is the setting that stops deny/modify from blocking a create request.
3. A tag policy that must also evaluate resource groups should use mode `All` and target the resource group type.
4. Flipping an assignment from `DoNotEnforce` to `Default` is how you start blocking after an audit period.

---

**3.** Exhibit:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "field": "tags['costCenter']",
      "exists": "false"
    },
    "then": { "effect": "deny" }
  }
}
```

The definition is assigned at a subscription with `enforcementMode` `Default`. Which object is **not** denied by this assignment when `costCenter` is missing?

A. A storage account created without the tag.
B. A virtual machine created without the tag.
C. A resource group created without the tag.
D. A public IP created without the tag.

---

**4.** Complete each blank.

1. Only a policy ________ evaluates resources; a definition and an initiative do not until they are applied to a scope.
2. Effects that need a managed identity on the assignment: ________ and ________.
3. After the identity exists, it still needs a ________ at the assignment scope or remediation fails with authorization errors.
4. To overwrite a wrong tag value, use effect ________, not ________.

---

**5.** Put these effects in evaluation order, **first to last**. Then, in one sentence, say why append/modify sit where they do.

- auditIfNotExists and deployIfNotExists
- deny
- append and modify
- disabled
- audit

---

**6.** Case study — Fabrikam.

Requirements, all of which must be met:

- Production subscriptions sit under `mg-prod`. A sandbox subscription under `mg-prod` must **not** be evaluated and must **not** appear in the compliance numbers.
- A single legacy VM in production cannot comply for 90 days. Security wants that skip **visible** on the compliance report, with an end date.
- Existing VMs missing a diagnostic setting must get one without a person clicking through each VM.

Which combination meets all three?

A. `notScopes` for the sandbox; a Waiver exemption with `expiresOn` on the VM; `deployIfNotExists` plus a remediation task.
B. An exemption on the sandbox; `notScopes` on the VM; `auditIfNotExists` with no remediation.
C. `notScopes` for both the sandbox and the VM; `append` to create diagnostic settings.
D. A Mitigated exemption on `mg-prod`; `deny` to deploy diagnostic settings.

---

**7.** Exhibit — assigned at `mg-corp` (parent of the subscription):

```json
{ "effect": "deny", "field": "location", "notIn": ["southeastasia"] }
```

Assigned at resource group `rg-app` in that subscription:

```json
{ "effect": "audit", "field": "location", "notIn": ["southeastasia"] }
```

A contributor creates a NIC in `rg-app` in `eastus`. Result?

A. The NIC is created and marked non-compliant because the resource group assignment is closer.
B. The request is denied because the management group Deny still applies.
C. The NIC is created in `southeastasia` because modify wins.
D. The two assignments cancel and the NIC is created with no compliance state.

---

**8.** Exhibit:

```bash
az policy assignment create \
  --name inherit-env \
  --scope "/subscriptions/.../resourceGroups/rg-web" \
  --policy "inherit-tag-from-rg" \
  --mi-system-assigned \
  --location westeurope \
  --enforcement-mode Default
```

The built-in definition uses effect `modify` to copy `env` from the resource group. A new VM is created in `rg-web` with no tags. The assignment identity has **no** role assignments. What happens to the VM create?

A. The VM is created with `env` copied from the resource group.
B. The create fails because modify cannot run, or the tag is not applied and the assignment is non-compliant — the identity lacks permission such as Tag Contributor.
C. The VM is denied because modify without a role becomes deny.
D. `--enforcement-mode Default` is invalid together with `--mi-system-assigned`.

---

**9.** A definition has `"mode": "All"` and default effect `Deny`. Someone wants tag-only evaluation and no blocking this week, without editing the definition JSON.

Select the **two** changes that belong on the **assignment** (not a new definition).

A. Set `enforcementMode` to `DoNotEnforce`.
B. Change `mode` to `Indexed` on the assignment object.
C. Set the assignment parameter `effect` to `Audit` if the definition parameterizes effect.
D. Add `notScopes` pointing at every resource group.
E. Set definition `mode` to `Indexed` on the assignment — that property copies down.

---

**10.** Exhibit — Bicep:

```bicep
resource init 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: 'tag-guardrails'
}

resource asg 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'tag-guardrails-mg'
  properties: {
    policyDefinitionId: init.id
    enforcementMode: 'DoNotEnforce'
  }
}
```

Finance asks: "Are we blocking non-compliant deploys yet, and will we see a compliance percentage?"

A. Blocking yes; no compliance data until `Default`.
B. Blocking no; compliance is still evaluated and reported.
C. Neither — `policySetDefinitions` cannot be referenced by `policyDefinitionId`.
D. Blocking yes, because `DoNotEnforce` applies only to `audit` effects.

---

## Submission — 2026-09-28

1. A, C
2. No, No, Yes, Yes
3. A
4. assignment; modify, deployIfNotExists; contributor role; modify, not append
5. disabled → append and modify → deny → audit → AINE/DINE. Reason: append/modify may cause the request to hit deny.
6. A
7. B
8. B
9. A, C
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — `notScopes` drops evaluation and the count; Waiver vs Mitigated. Exemption ≠ `notScopes` on the report |
| 2 | Correct | No / No / Yes / Yes — `DoNotEnforce` is assignment enforcement, not definition `mode`; `Indexed` does not mean "don't block" |
| 3 | **Wrong** | **C** — `Indexed` does not evaluate resource groups. Storage, VMs, and public IPs support tags, so they **are** denied. The question asked which object is **not** denied |
| 4 | Correct | Assignment evaluates; modify + DINE need an identity; that identity needs a **role** (exam least-privilege: Tag Contributor, not generic Contributor); modify overwrites, append does not |
| 5 | Correct (order) | disabled → append/modify → deny → audit → AINE/DINE. **Reason is inverted:** they sit before deny so they can **change the request** and a later deny may **miss**, not so they "hit deny" |
| 6 | Correct | A — exclusion for sandbox, dated Waiver for the one VM, DINE + remediation for diagnostics |
| 7 | Correct | B — parent Deny is not canceled by child Audit |
| 8 | Correct | B — identity without a role cannot modify |
| 9 | Correct | A, C — both are assignment-level. `mode` is not an assignment property |
| 10 | Correct | B — `DoNotEnforce` still evaluates and reports; it does not block |

Quiz 1 vocabulary misses (`notScopes` vs exemption, `mode` vs `enforcementMode`, effect order) are closed on this paper. Remaining nit: **Indexed skips resource groups**, and append/modify run early to **mutate**, not to feed deny.
