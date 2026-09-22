# Module 2 — Create, configure, and manage identities

Learn module: [Create, configure, and manage identities](https://learn.microsoft.com/en-us/training/modules/create-configure-manage-identities/) (14 units)

**Aim:** create/configure/manage **users**, create/configure/manage **groups**, manage **licenses**, and explain **custom security attributes** and **automatic user provisioning**.

This is the heaviest module in the path for exam points. "Manage Microsoft Entra users and groups" is a named skill.

---

## Users

### Identity sources

| Source | What it is |
| --- | --- |
| **Cloud identity** | Created directly in this tenant (or another Entra tenant) |
| **Directory-synchronized** | Exists in on-prem AD DS, synced up by **Entra Connect Sync** / Cloud Sync |
| **Guest / external** | Invited **B2B** user; the credential lives in their home tenant or as a Microsoft/social account |

### Member vs Guest

`userType` is **Member** or **Guest**. Guest is the default for invited external users and is more restricted in what it can read in the directory. You can convert a guest to a member (and back) — a real exam nuance, because "make the vendor a full employee identity" is a property change, not a delete-and-recreate.

### Rules that get tested

- **UPN must use a verified domain** in the tenant. `user@contoso.onmicrosoft.com` always works; `user@contoso.com` only after you verify `contoso.com`.
- A **deleted user is soft-deleted for 30 days** and can be restored. After 30 days it is permanent. Same for Microsoft 365 groups; **security groups are not recoverable** that way.
- **Synced users must be edited on-premises.** Most attributes of a directory-synced user are read-only in the cloud — fix AD DS, let sync carry it. If a question shows an admin unable to change a user's name in the portal, suspect sync.
- **Bulk operations** are done with a **CSV** (bulk create, bulk invite, bulk delete, bulk password reset) in the portal, or via CLI/PowerShell/Graph for scripted work.
- `usageLocation` (a two-letter country code) is required before some licenses can be assigned — service availability is country-specific.

## Groups

Two independent axes. Exam questions almost always hinge on one of them.

### Axis 1 — group type

| Type | Use |
| --- | --- |
| **Security** | Grant access: Azure RBAC, app access, license assignment |
| **Microsoft 365** | Collaboration: shared mailbox, SharePoint site, Teams; can have external members |

### Axis 2 — membership type

| Membership | Behavior | License |
| --- | --- | --- |
| **Assigned** | You add/remove members by hand | Free |
| **Dynamic User** | Rule over user attributes, e.g. `user.department -eq "Finance"` | **P1** |
| **Dynamic Device** | Rule over device attributes | **P1** (security groups only) |

Constraints to memorize:

- Dynamic rules evaluate **attributes of users or devices** — you cannot build a dynamic rule whose members are **groups**.
- A single dynamic group is **either** user-based **or** device-based, never both.
- **Microsoft 365 groups support Dynamic User, not Dynamic Device.**
- Converting a group from Assigned to Dynamic **discards existing manual members** — the rule becomes the source of truth.
- Nesting: a group can contain a group. Azure **RBAC honors nesting**, and so does group-based licensing. Dynamic membership does not produce nested groups.
- `isAssignableToRole` (role-assignable groups) must be set **at creation** and cannot be changed later; those groups also cannot be dynamic.

## Administrative units

An **AU** scopes an admin role to a **subset** of the directory — the closest thing Entra ID has to an OU, but for **delegation only**, not policy.

- Example: make someone **User Administrator** over just the "Manila Branch" AU, so they can reset passwords for that branch and nowhere else.
- AU members can be **users, groups, or devices**.
- **Licensing:** the scoped **administrator** needs **P1**; the AU **members** only need Free.
- **Dynamic AUs** support **users or devices, not both, and not groups**.
- **Adding a group to an AU scopes the group object, not the group's members.** A scoped admin can rename the group or change its membership, but cannot manage those users' own properties unless the users are also AU members. This distinction is a favorite exam question.

## Device registration

| State | Who owns it | Sign-in |
| --- | --- | --- |
| **Entra registered** | Personal / BYOD | Personal account, work access added |
| **Entra joined** | Organization, cloud-only | Work account signs in to the device |
| **Hybrid Entra joined** | Organization, also joined to on-prem AD DS | Work account, needs on-prem AD |

Tenant device settings you can control: who may join devices, **maximum devices per user**, and whether **MFA is required to join**. Hybrid join is the answer when the device must keep using on-prem AD (GPO, Kerberos to file servers) *and* be visible to Entra ID.

## Licenses

Two assignment models:

| Model | How | Notes |
| --- | --- | --- |
| **Direct** | Assign to the user | Fine at small scale |
| **Group-based** | Assign the license to a **group**; members inherit | **P1** feature; the standard approach at scale |

Watch for:

- **Conflicting service plans** — two products that both include the same plan cause an assignment error; disable the duplicate plan.
- **`usageLocation` missing** → assignment fails for location-restricted services.
- **Removing a user from a licensed group removes the license**, and the associated data enters its retention/deletion path.
- Not enough available seats → the assignment errors; check consumed vs available.

## Custom security attributes

Tenant-defined **key/value attributes** on directory objects (attribute sets like `Engineering` with attributes like `Project`). Used for **attribute-based access control (ABAC)** and for filtering.

- Not readable or writable by regular admins; needs dedicated roles such as **Attribute Definition Administrator** and **Attribute Assignment Administrator**.
- Global Administrator does **not** get these permissions by default — a real trap.

## Automatic user provisioning

Create, update, and deprovision accounts in apps automatically, driven by **SCIM**:

- **Outbound/app provisioning** — Entra ID pushes accounts into SaaS apps (ServiceNow, Salesforce).
- **HR-driven inbound provisioning** — Workday / SuccessFactors is the source of truth, and accounts flow into Entra ID (or AD DS).

The point: **joiner-mover-leaver handled by the platform**, so a terminated employee loses access without a ticket.

---

## Enterprise scenarios

### 1. Branch helpdesk that must not touch HQ

Manila needs local password resets. Wrong answer: give them User Administrator on the tenant. Right answer: create an **administrative unit** for the branch, add those users, and assign **User Administrator scoped to the AU**. Budget for **P1 for the helpdesk admins**; the branch users stay Free.

### 2. Vendor access that must expire cleanly

A contractor needs access for a 3-month project. Invite as a **B2B guest** (credential stays in their tenant, so their employer's offboarding kills it too), put them in an **assigned** security group used for RBAC, and review it. Do not create a cloud-only account with a shared password.

### 3. HR wants "new Finance hires get access automatically"

**Dynamic User** group with `user.department -eq "Finance"`, used for both RBAC and **group-based licensing**. Two costs land on the invoice: **P1** for dynamic membership and P1 for group-based licensing (same license). Also verify HR actually populates `department`, or the rule matches nobody.

### 4. The group that was converted

An admin flips a 400-member assigned group to a dynamic rule to "clean it up." Conversion **drops the manual members**; access disappears for anyone the rule does not match. Recovery is re-adding by hand or fixing the rule — there is no undo. Do this in a test group first.

### 5. Deleted the wrong user

A user is deleted on Friday. On Monday you can **restore** them from deleted users (30-day window) with group memberships and licenses intact. If the same happened to a **security group**, there is no restore — recreate it and rebuild the role assignments.

---

## Exam traps from this module

1. UPN must use a **verified domain**.
2. Users and Microsoft 365 groups: **30-day soft delete**. Security groups: no restore.
3. **Synced** users are edited on-premises, not in the cloud.
4. Dynamic membership = **P1**. Group-based licensing = **P1**. Administrative-unit admins = **P1**.
5. Dynamic groups cannot target **groups**, and cannot mix **users and devices**.
6. Converting Assigned → Dynamic **wipes manual members**.
7. `isAssignableToRole` is set **at creation only** and excludes dynamic membership.
8. Adding a **group** to an AU scopes the **group object**, not its members.
9. Custom security attributes need their own roles; **Global Admin is not automatically included**.
10. Licensing failures usually mean **missing `usageLocation`**, **conflicting service plans**, or **no seats left**.

## Lab in this folder

`poc/users-groups.sh` (Azure CLI) and `poc/users-groups.ps1` (Azure PowerShell). Both **default to read-only listing**. Creating users and groups writes to your real tenant — there is no "sandbox tenant" for Entra objects — so writes are gated behind `APPLY=1` / `-Apply` and use an obvious `az104-` prefix plus a cleanup step.

```bash
cd 02-identities-and-governance/02-create-configure-manage-identities/poc
./users-groups.sh            # read-only inventory
APPLY=1 ./users-groups.sh    # create demo user + group, then clean up
```
