# Module 5 — Secure your Azure resources with Azure RBAC

Learn module: [Secure your Azure resources with Azure role-based access control (Azure RBAC)](https://learn.microsoft.com/en-us/training/modules/secure-azure-resources-with-rbac/)

**Aim:** what Azure RBAC is, how a role assignment is built, built-in vs custom roles, scope, inheritance, and how that differs from Entra ID roles and from Azure Policy.

Same backbone as modules 3 and 4: **scope, inherit down, smallest assignment that does the job.** Policy says what a resource is allowed to *be*. RBAC says who is allowed to *do*.

---

## Three pieces of a role assignment

An assignment is **not** “give Ben Contributor.” It is a triple:

| Piece | What it is |
| --- | --- |
| **Security principal** | Who: user, group, service principal, **managed identity** |
| **Role definition** | What they may do: a list of `Actions` / `NotActions` / `DataActions` |
| **Scope** | Where: management group, subscription, resource group, or **one resource** |

Miss any piece and you do not have an assignment. The exam loves “assign Reader to the group at the resource group,” not to the user at the subscription.

Best practice: assign to a **group**, not to a user. Azure RBAC **honours nested groups** (module 2). Group-based licensing does not. Do not mix those two trees.

---

## Azure RBAC vs Entra ID roles vs Policy vs locks

| | Controls | Scope |
| --- | --- | --- |
| **Azure RBAC** | Azure **resources** (VMs, storage, RGs, subscriptions) | MG / sub / RG / resource |
| **Entra ID roles** | The **directory** (users, groups, licenses, apps) | Tenant (or administrative unit) |
| **Azure Policy** | Resource **properties** (SKU, location, tags) | Same ARM hierarchy; inherit down |
| **Resource locks** | Delete / change of a resource (`CanNotDelete`, `ReadOnly`) | RG or resource (also subscription) |

**Global Administrator is not Owner.** A Global Admin has no Azure subscription rights until someone assigns an Azure role, or they **elevate access** (“Access management for Azure resources”), which grants **User Access Administrator** at the **root** management group — still not Owner, and it is an audit event. Turn it off when the job is done.

Contributor **cannot** assign roles. Owner **can**. User Access Administrator **can assign roles** but cannot create VMs. Need both jobs → **Owner**, or **Contributor + User Access Administrator** (two assignments; Owner is one). Exam “lowest privilege”: if they only need to grant access, UAA, not Owner.

---

## Built-in roles you must not mix up

| Role | Manage resources | Assign Azure roles |
| --- | --- | --- |
| **Owner** | Yes | Yes |
| **Contributor** | Yes | **No** |
| **Reader** | Read only | No |
| **User Access Administrator** | **No** | Yes |
| **Virtual Machine Contributor** (and other resource-specific roles) | That resource type | No |

Classic subscription admins (Account Admin, Service Administrator, Co-Administrator) are a **legacy** path at **subscription** scope only. Co-Admin ≈ Owner on the subscription. You cannot scope a co-admin to a resource group. Prefer Azure RBAC.

---

## Inheritance

Same rule as Policy: assignments inherit **downward**. An assignment at the management group shows on every subscription, RG, and resource under it.

You **cannot remove an inherited assignment at the child.** Change it where it was created, or move the child out from under that scope.

Effective rights are **additive**. There is no “deny this role at the RG” in normal RBAC. (Azure **deny assignments** are a separate object, usually created by Microsoft for managed apps, deployment stacks, and similar — you generally **do not** author them yourself. Deny beats allow.)

Least privilege: assign at the **smallest scope** that still meets the requirement. Fourteen subscriptions need Reader → one assignment at a **management group**, not fourteen subscription assignments (module 3 scenario).

---

## Custom roles

JSON (or Bicep) role definition:

- `Actions` / `NotActions` — control-plane (ARM) operations
- `DataActions` / `NotDataActions` — data plane (blobs, queue messages)
- **`AssignableScopes`** — where this role may be assigned (must include the scope you will use)

You cannot create a custom role that assigns itself everywhere unless `AssignableScopes` says so. Cloning a built-in and removing `Microsoft.Authorization/*/write` is the usual “Contributor but not IAM” pattern — but **Contributor already cannot assign roles**. Custom is for *gaps* in built-in roles (e.g. restart VMs plus read storage, nothing else).

Limits worth remembering: thousands of custom roles per tenant; you need permission to write role definitions at that scope.

---

## How you assign (exam stack)

```bash
az role assignment create \
  --assignee maria@contoso.com \
  --role "Virtual Machine Contributor" \
  --scope "/subscriptions/<subId>/resourceGroups/rg-app"
```

```powershell
New-AzRoleAssignment -SignInName maria@contoso.com `
  -RoleDefinitionName 'Virtual Machine Contributor' `
  -ResourceGroupName rg-app
```

```bash
az role assignment list --scope <scope> --include-inherited
az role assignment delete --ids <assignmentId>
```

`--include-inherited` is how you *see* a parent assignment. `delete` on that ID, with only RG rights, **fails** — the assignment lives at the parent (same shape as Policy quiz 3 Q7).

Who may assign: **Owner** or **User Access Administrator** at that scope (or a custom role with `Microsoft.Authorization/roleAssignments/write`).

---

## Enterprise scenarios

### 1. Helpdesk must restart VMs in `rg-app`, nothing else

**Virtual Machine Contributor** (or a tighter custom role) at **`rg-app`**, assigned to a **group**. Not Owner at the subscription. Not Contributor at the subscription.

### 2. Platform team must grant access but must not deploy

**User Access Administrator** at the management group or subscription. Not Owner.

### 3. App needs to read a Key Vault / storage account

Assign the role to the app’s **managed identity**, at the vault or account scope. Do not put a user password in the app.

### 4. “Make them Global Admin so they can see the subscription”

Wrong plane. Global Admin ≠ Azure Reader. Assign **Reader** (or elevate UAA at root only for a break-glass, then remove).

---

## Exam traps from this module

1. A role assignment is **principal + role + scope**. All three.
2. **Contributor cannot assign roles.** Owner can. UAA assigns roles but does not manage resources.
3. **Entra roles ≠ Azure RBAC.** Global Admin is not Owner.
4. Inherit **down**. Cannot delete an inherited assignment at the child.
5. Assign to a **group**. RBAC follows nesting; licensing does not.
6. Smallest scope that works. Management group for many subscriptions.
7. Deny assignments are not “a Deny role you create.” Policy `deny` is also a different object.
8. Locks are not RBAC.

## Lab in this folder

```bash
cd 02-identities-and-governance/05-secure-resources-rbac/poc
./rbac.sh            # read-only: what roles you hold, inherited assignments
APPLY=1 ./rbac.sh    # optional: list only (writes are tenant-wide; keep APPLY off unless you intend it)
```
