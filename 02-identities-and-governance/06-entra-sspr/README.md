# Module 6 — Allow users to reset their password with Entra SSPR

Learn module: [Allow users to reset their password with Microsoft Entra self-service password reset](https://learn.microsoft.com/en-us/training/modules/allow-users-reset-their-password/)

**Aim:** what SSPR is, who it is enabled for, which authentication methods count, how registration works, and when **password writeback** is required.

This is the last module in Path 02. It sits on module 1 licensing and module 2 identity sources (cloud-only vs synced).

---

## Change vs reset vs unlock

| User action | They know the current password? | Typical feature |
| --- | --- | --- |
| **Change** | Yes | Signed-in password change |
| **Reset** | No (forgot it) | **SSPR** at `https://aka.ms/sspr` |
| **Unlock** | Account locked in AD DS | SSPR unlock, often with writeback |

The exam word is almost always **reset** (forgot password, no helpdesk).

---

## The three configuration pages

In Entra ID → **Password reset**:

| Page | What you set |
| --- | --- |
| **Properties** | SSPR **None** / **Selected** (a group — use this to pilot) / **All** |
| **Authentication methods** | How many methods to **reset** (1 or 2), and which methods are allowed |
| **Registration** | Require users to register when they sign in; days before they must **reconfirm** (often 90–180) |
| **Notifications** | Notify users on their own reset; notify admins when **another admin** resets |
| **On-premises integration** | **Write back passwords** to AD DS; optional unlock without a reset |

A definition on a shelf does nothing until you **enable SSPR for a scope of users** (Selected or All). Same shape as Policy: the assignment (who is in scope) is what makes it real.

---

## Authentication methods

Common exam list: **mobile app notification**, **mobile app code**, **email**, **mobile phone**, **office phone**, **security questions**.

- Number required to reset is **1 or 2**. Two is more secure; one is less friction.
- Register **at least one more method than required to reset**, so a user is not stuck if they lose a phone.
- Users who have not registered the minimum see an error and need an **admin reset**.

### Administrator accounts are stricter

Accounts with Azure **administrator** roles (the Entra admin roles):

- Must use **two** methods to reset (even if the tenant policy is 1).
- **Cannot use security questions.**
- Test SSPR with a **non-admin** account.

---

## Licensing — writeback is the exam hook

Current Microsoft table (do not mix change and reset):

| Scenario | Minimum license (typical exam answer) |
| --- | --- |
| Cloud-only user **changes** a password they still know | **Free** |
| Cloud-only user **resets** a forgotten password | Entra ID **P1** (or M365 Business Standard+). Older Learn text still says “SSPR for cloud-only is Free” — if the question says **forgot password + writeback**, that is **P1** either way |
| **Synced / hybrid** user reset or change, password must land in **on-prem AD DS** | **P1** + **password writeback** |

**Password writeback** is the one they will test:

- Requires **Microsoft Entra Connect** (or Cloud Sync) with **Password writeback** enabled.
- SSPR **On-premises integration**: write back passwords = Yes.
- The Connect **AD DS account** needs permission to reset passwords (and related lockout attributes) in AD.
- Without writeback, a **synced** user’s cloud reset does **not** update on-prem — they still cannot sign in to AD-joined resources with the new password.

P2 is not required for SSPR or writeback. P2 includes P1, so it works, but it **overshoots**.

---

## Combined registration

SSPR methods and MFA methods are moving to the **Authentication methods** policy (combined registration). Users register once at `https://aka.ms/setupsecurityinfo`.

Exam still talks about the Password reset blade for **who is enabled** and **on-prem writeback**. Do not confuse SSPR with Conditional Access or with Entra ID Protection (those are P1 / P2).

---

## Enterprise scenarios

### 1. Pilot, then all staff

Enable SSPR for a **Selected** security group first. Require register-on-sign-in. After the helpdesk ticket volume drops, set Properties to **All**.

### 2. Hybrid shop, users reset in the cloud and still cannot open the file share

Writeback is off, or Connect’s AD account lacks reset permission, or the user is federated without the writeback path. Fix writeback — do not create a second cloud-only account.

### 3. “Just use security questions for Global Admins”

No. Admin SSPR cannot use security questions and needs two methods. Use Authenticator + phone, or have another admin reset.

### 4. License the writeback rollout as Free because “we already have Azure”

Wrong. Hybrid writeback is **P1** (per user who uses it). Group-based licensing (also P1) is how you attach that SKU to the SSPR group.

---

## Exam traps from this module

1. **Reset** (forgot) ≠ **change** (still knows the password).
2. Enable for **Selected** or **All** — None means nobody (except the default admin path).
3. Methods to reset: **1 or 2**. Register more than you require.
4. **Admins: two methods, no security questions.** Test with a normal user.
5. Synced users need **writeback** + **P1**. Free / no writeback = on-prem password unchanged.
6. Writeback is configured in **Entra Connect** and on the SSPR **On-premises integration** page.
7. SSPR is not Azure RBAC and not Policy. It is an **Entra** user feature.
8. P2 / PIM is the overshoot answer for “users reset their own password.”

## Lab in this folder

```bash
cd 02-identities-and-governance/06-entra-sspr/poc
./sspr-inspect.sh    # read-only: tenant + reminder of SSPR blades (no tenant writes)
```

SSPR is configured in the **Entra admin center** (Password reset). There is no `az ad sspr enable` in the exam stack. Know the **portal blades** and the **writeback** checkbox on Connect.
