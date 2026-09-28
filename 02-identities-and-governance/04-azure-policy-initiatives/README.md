# Module 4 — Azure Policy initiatives

Learn module: [Azure Policy initiatives](https://learn.microsoft.com/en-us/training/modules/intro-to-governance/) (or the current AZ-104 Policy module on the identities-and-governance path).

**Aim:** definitions, initiatives (policy sets), assignments, effects, modes, exclusions, exemptions, enforcement, managed identity, remediation.

This module is the **verbs** on the hierarchy from module 3. A policy assignment at a management group inherits downward the same way RBAC does. A child **cannot** cancel a parent Deny by assigning Audit.

If you catch yourself guessing, stop and name **which object** the question is about: definition, initiative, assignment, or exemption. Most wrong answers mix those four.

---

## The four objects — do not merge them

| Object | What it is | Evaluates resources? |
| --- | --- | --- |
| **Policy definition** | The rule: `if` this, `then` this **effect** | No. It is a template |
| **Initiative** (policy set) | A **collection of definitions** you assign as **one** object | No. Still a template |
| **Assignment** | A definition *or* initiative **applied to a scope** | **Yes. This is what evaluates** |
| **Exemption** | A documented skip for one assignment at a child scope | Changes the result to **Exempt** |

Exam consequence: a Bicep file can contain a definition, a set, and an assignment. Only the **assignment** makes the subscription start evaluating. `DoNotEnforce` on that assignment is valid — evaluate, do not block.

Assign **one initiative at the management group**, not forty copies of the same two policies on forty subscriptions.

---

## Two different "modes" — this is Q4 from quiz 1

| Property | Lives on | Values | Job |
| --- | --- | --- | --- |
| **`mode`** | the **definition** | `All` or `Indexed` | **Which resource types** are evaluated |
| **`enforcementMode`** | the **assignment** | `Default` or `DoNotEnforce` | **Whether a matching deny/modify blocks** the request |

### Definition `mode`

- **`All`** — resource groups, subscriptions, and all resource types.
- **`Indexed`** — only types that support **tags and location**. Use this for tag/location policies so types that cannot be tagged do not show as non-compliant.

Exception: if the policy must apply to **resource groups or subscriptions themselves**, set `mode` to **`All`** and target `Microsoft.Resources/subscriptions/resourceGroups` or `Microsoft.Resources/subscriptions`. Indexed tag policies are commonly described as **not applying to resource groups**.

### Assignment `enforcementMode`

- **`Default`** — effects run for real. Deny blocks. Modify changes the request.
- **`DoNotEnforce`** — still **evaluates** and reports compliance. Does **not** block and does not modify on create. The exam phrase: "deployments must not be blocked this week, but we still need a compliance count."

That is the Contoso pattern: assign the initiative at the MG with `DoNotEnforce`, next week flip the **same assignment** to `Default`, then remediate existing resources.

---

## Effects

| Effect | What it does | Blocks create? | Needs managed identity? |
| --- | --- | --- | --- |
| **disabled** | Rule is skipped | No | No |
| **append** | Adds a property **only if it is missing** | No | No |
| **modify** | Adds **or replaces** (tags are the usual example). Can remediate existing resources | No (changes the request) | **Yes** |
| **deny** | Rejects the request. Resource is **not** created | **Yes** | No |
| **audit** | Created, marked **non-compliant** | No | No |
| **auditIfNotExists** | Related resource missing → non-compliant (e.g. no diagnostic setting) | No | No |
| **deployIfNotExists** | Related resource missing → **deploy it** (or mark non-compliant until remediated) | No | **Yes** |

`append` versus `modify`: need to **replace** a wrong tag value → **modify**. Append will not overwrite.

`modify` and `deployIfNotExists` need a **system-assigned managed identity on the assignment**, and that identity must be **granted a role** at the assignment scope (Tag Contributor for tags, a deploy role for DINE). Creating the identity (`--mi-system-assigned`) is not enough — that was quiz 1 Q7.

Existing resources are **not** auto-fixed by assigning a DINE or modify policy. You run a **remediation task**. New creates can be modified/denied on the request itself when enforcement is Default.

---

## Evaluation order (memorize this list)

On a create/update, Resource Manager order:

1. **disabled** — should this rule run at all?
2. **append** and **modify** — may **change the request**. A modify that stamps `costCenter` can make a later "deny if tag missing" miss.
3. **deny** — block **before** the resource provider, so a denied resource is not also audited.
4. **audit**
5. **auditIfNotExists** and **deployIfNotExists** — after the provider succeeds, is a *related* resource missing?

That is why starting the list at `deny` is wrong.

---

## Scope: inherit down, carve-outs are not the same

Assignments inherit **downward**. **Most restrictive wins.** A Deny at the management group is **not** canceled by Audit on a child resource group.

Two ways to skip a child, and they are **not** the same:

| | **`notScopes`** (exclusion) | **Exemption** |
| --- | --- | --- |
| Where it lives | Property **on the assignment** | **Separate object** on the resource/scope |
| Evaluated? | **No** | Assignment still exists; this scope is skipped **with a reason** |
| Compliance report | Resource **does not appear** in the count | Shows as **Exempt** (still visible) |
| Typical use | Permanent, broad skip (a whole test subscription) | Time-bound or specific skip you must **track** |
| Expires? | No | Optional **`expiresOn`** |

Exemption **categories** (exactly two):

- **Waiver** — we accept the risk for now.
- **Mitigated** — the policy intent is met **another way** (for example a third-party control).

---

## Locks are not Policy

`CanNotDelete` / `ReadOnly` are **resource locks**. They do not stamp tags, do not produce a compliance dashboard, and do not replace an initiative. If a question wants a compliance count or a required tag, the answer is Policy, not a lock.

---

## Enterprise scenarios

### 1. Forty subscriptions, two rules, no block this week

One **initiative** at the **management group**, `enforcementMode` **`DoNotEnforce`**. Next week set that assignment to **Default**. Run a **remediation** on the modify/tag policy for what already exists.

### 2. Inherit `env` from the resource group

Built-in **"Inherit a tag from the resource group"** — effect **`modify`**. Identity + Tag Contributor. Tags still do **not** inherit by default (module 3). This policy is how you make them.

### 3. Storage SKU not in the allow-list, effect deny

Request is **rejected**. The account is not created. Audit would create it and mark non-compliant. Modify would rewrite (if the alias supports it), not deny.

### 4. Sandbox subscription must not be in the production initiative

Add it to the assignment's **`notScopes`**. Do not use an exemption unless you need it on the report as Exempt.

---

## Exam traps from this module

1. Only an **assignment** evaluates a scope. Definitions and initiatives do nothing until assigned.
2. **`mode`** (definition) ≠ **`enforcementMode`** (assignment). Indexed ≠ DoNotEnforce.
3. **`modify`** and **`deployIfNotExists`** need a managed identity **and** a role on that identity.
4. **`append`** does not replace. **`modify`** does.
5. Child Audit **cannot** cancel parent Deny.
6. **`notScopes`** ≠ exemption. Waiver / Mitigated are exemption categories only.
7. Existing resources need a **remediation task**.
8. Effect order: **disabled → append/modify → deny → audit → AINE/DINE**.

## Lab in this folder

`poc/` is optional once the notes stick. The exam verbs are:

```bash
az policy assignment create --name require-tags \
  --scope "/providers/Microsoft.Management/managementGroups/mg-corp" \
  --policy-set-definition "required-tags-initiative" \
  --enforcement-mode DoNotEnforce

az policy assignment create --name inherit-env --scope <rg-id> \
  --policy <modify-definition-id> --mi-system-assigned --location eastus
# then grant Tag Contributor to that assignment's principalId

az policy remediation create --name fix-tags --policy-assignment inherit-env
```
