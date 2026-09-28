# Module 4 (Azure Policy initiatives) — Quiz 1

Date issued: 2026-09-28
Scope: this module only — policy definitions, initiatives (policy sets), assignments, effects, modes, exclusions, exemptions, enforcement, managed identity, remediation.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** effects that require a managed identity on the policy assignment.

A. deny
B. modify
C. audit
D. deployIfNotExists
E. append

---

**2.** For each statement, answer **Yes** or **No**.

1. A Deny assignment on a management group is canceled when the same rule is assigned as Audit on a child resource group.
2. Enforcement mode `DoNotEnforce` still evaluates compliance and does not block the request.
3. A policy exemption is the same mechanism as `notScopes` on the assignment.
4. Resources that already exist when a `deployIfNotExists` policy is assigned are corrected only when a remediation task runs.

---

**3.** Exhibit — policy rule:

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Storage/storageAccounts"
      },
      {
        "field": "Microsoft.Storage/storageAccounts/sku.name",
        "notIn": ["Standard_LRS", "Standard_ZRS"]
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

A deployment creates a storage account with SKU `Standard_GRS` in a scope where this definition is assigned. What is the result?

A. The account is created and the compliance state becomes Non-compliant.
B. The request is rejected and the storage account is not created.
C. The account is created as `Standard_LRS` because the policy rewrites the SKU.
D. The account is created, and a remediation task must delete it afterward.

---

**4.** Complete each blank. No options.

1. A collection of policy definitions that you assign as one object is called an ________ (also a policy set).
2. The assignment property that removes a child scope from evaluation is ________.
3. The two policy exemption categories are ________ and ________.
4. A policy that evaluates tags or locations should use mode ________, so resource groups are not in scope.

---

**5.** Put these effects in the order Azure Policy evaluates them, **first to last**.

- deny
- disabled
- audit
- append and modify
- auditIfNotExists and deployIfNotExists

---

**6.** Case study — Contoso, 40 subscriptions under one management group.

All of the following must be met, with the least ongoing assignment work:

- Every subscription must use the same allowed-locations rule and the same required `costCenter` tag rule.
- This week, deployments must not be blocked. You still need a compliance count.
- Next week, non-compliant creates must be blocked.
- Existing resources that lack `costCenter` must be updated without editing each resource by hand.

A. Assign each policy on all 40 subscriptions in Default mode, then run remediation in each subscription.
B. Assign one initiative at the management group with enforcement `DoNotEnforce`. Next week set that assignment to Default and remediate the tag policy.
C. Assign a deny policy at the tenant root and add all 40 subscriptions to `notScopes` until next week.
D. Put `CanNotDelete` locks on each resource group and set `costCenter` on the management group.

---

**7.** Exhibit:

```bash
az policy assignment create \
  --name require-tags \
  --scope "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app" \
  --policy-set-definition "required-tags-initiative" \
  --mi-system-assigned \
  --location eastus
```

The initiative contains a `modify` policy that adds `costCenter`. The assignment succeeds. A remediation task then fails with authorization errors. What was missed?

A. `--policy-set-definition` cannot be used together with `--mi-system-assigned`.
B. The new identity was not granted a role such as Tag Contributor on that scope.
C. `--location` is not a valid argument for `az policy assignment create`.
D. Remediation tasks are not supported for an assignment at resource group scope.

---

**8.** Exhibit — custom definition, assigned at a subscription. The `effect` parameter is left at its default.

```json
{
  "mode": "All",
  "parameters": {
    "effect": {
      "type": "String",
      "allowedValues": ["Audit", "Deny", "Disabled"],
      "defaultValue": "Audit"
    }
  },
  "policyRule": {
    "if": {
      "field": "location",
      "notIn": ["southeastasia"]
    },
    "then": {
      "effect": "[parameters('effect')]"
    }
  }
}
```

Someone creates a resource group in `eastus`. What happens?

A. Creation is blocked because the location is not southeastasia.
B. The resource group is created and shows as non-compliant.
C. The resource group is ignored because mode `All` does not evaluate resource groups.
D. The resource group is created in southeastasia because the policy rewrites location.

---

**9.** Exhibit:

```bicep
resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'allowed-skus'
  properties: {
    policyType: 'Custom'
  }
}

resource setDef 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: 'storage-guardrails'
  properties: {
    policyType: 'Custom'
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'storage-guardrails-sub'
  properties: {
    policyDefinitionId: setDef.id
    enforcementMode: 'DoNotEnforce'
  }
}
```

Which resource makes the subscription evaluate `storage-guardrails` without blocking requests?

A. `definition`
B. `setDef`
C. `assignment`
D. None of them. `DoNotEnforce` is not a valid `enforcementMode`.

---

**10.** A tag rule must add `owner` when the tag is missing, and must replace `owner` when it is already set to the wrong value. Which effect does that?

A. append
B. deny
C. modify
D. auditIfNotExists

---

## Submission — 2026-09-28

1. B, D
2. No, Yes, No, Yes
3. B
4. (1) policy initiatives (2) idk (3) idk (4) DoNotEnforce
5. deny → append and modify → audit → auditIfNotExists and deployIfNotExists (disabled omitted)
6. B
7. B
8. B
9. C
10. C

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 4 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — `modify` and `deployIfNotExists` need a managed identity on the assignment. `append` does not |
| 2 | Correct | No / Yes / No / Yes — child Audit cannot cancel parent Deny; `DoNotEnforce` still evaluates; exemption ≠ `notScopes`; existing DINE resources need a remediation task |
| 3 | Correct | B — `deny` rejects the request. `Standard_GRS` is not in the allowed SKU list |
| 4 | **Wrong** | initiative; **`notScopes`**; **Waiver** and **Mitigated**; mode **`Indexed`**. You mixed assignment `enforcementMode` with definition `mode` |
| 5 | **Wrong** | **disabled → append and modify → deny → audit → auditIfNotExists and deployIfNotExists**. Append/modify run *before* deny so they can change the request; disabled is checked first |
| 6 | Correct | B — one initiative at the MG, `DoNotEnforce` this week, Default next week, then remediate |
| 7 | Correct | B — system-assigned identity exists; it still needs a role such as Tag Contributor at that scope |
| 8 | Correct | B — default effect is Audit, mode `All` evaluates resource groups, so the RG is created and non-compliant |
| 9 | Correct | C — only the **assignment** evaluates a scope. `DoNotEnforce` is valid and does not block |
| 10 | Correct | C — `modify` can add or replace. `append` only adds when the property is missing |

### Q4 — four different objects, you named the wrong layer on three of them

| Blank | Your answer | Key | Why |
| --- | --- | --- | --- |
| Collection you assign as one object | initiative | **initiative** (policy set) | Counted. "Policy initiatives" is the same idea |
| Assignment property that removes a child scope | (blank) | **`notScopes`** | The child disappears from evaluation *and* from the compliance count |
| Exemption categories | (blank) | **Waiver** and **Mitigated** | Waiver = accept the risk for now. Mitigated = intent met another way. Exemptions show as Exempt and can expire |
| Mode so tag/location policies skip RGs | `DoNotEnforce` | **`Indexed`** | `DoNotEnforce` is **enforcementMode on the assignment**. `mode` is on the **definition**: `Indexed` = types that support tags and location (RGs/subscriptions are the exception — use `All` and target those types if you need them) |

`notScopes` vs exemption is the pair the exam loves. Exclusion (`notScopes`) = not evaluated, not in the count. Exemption = documented skip, still visible as Exempt.

### Q5 — effect order is a sequence, not a severity list

You started at `deny` and skipped `disabled`. Official Resource Manager order:

1. **disabled** — should this rule run at all?
2. **append / modify** — may change the request (a modify can make a later deny miss)
3. **deny** — block before the resource provider
4. **audit** — log, do not block
5. **auditIfNotExists / deployIfNotExists** — after the provider succeeds, related resource missing?

That is why a `modify` that stamps `costCenter` can stop a "deny if tag missing" from firing on the same request.

### What you already have

Q1, Q6, Q7, Q9, Q10 are the operational core: which effects need an identity, initiative at MG + DoNotEnforce then Default, identity still needs a role, assignment is what evaluates, modify vs append. The fail is vocabulary for **scope carve-outs** and **evaluation order**.

Re-read those two lists, then take a retake. Do not move to module 5 until this one is 9/10.
