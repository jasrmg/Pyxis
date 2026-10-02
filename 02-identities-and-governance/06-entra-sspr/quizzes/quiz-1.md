# Module 6 (Entra SSPR) — Quiz 1

Date issued: 2026-10-02
Scope: this module only — SSPR enablement, methods, registration, admin differences, password writeback, licensing.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** requirements for a **synced** user to reset a forgotten password in the cloud and then sign in to an on-premises file share with that new password.

A. Entra ID Free and SSPR Properties set to All
B. Password writeback enabled in Microsoft Entra Connect
C. Entra ID P1 (or P2) for that user, and SSPR on-premises writeback enabled
D. Privileged Identity Management so the user can activate Password Administrator
E. An administrative unit scoped to the file share

---

**2.** For each statement, answer **Yes** or **No**.

1. A Global Administrator can use security questions as one of their SSPR methods.
2. Administrator accounts must provide two methods to reset, even if the tenant policy requires one.
3. SSPR Properties = None disables SSPR for regular users you would otherwise include.
4. Azure Reader on a subscription is required before a user can open `https://aka.ms/sspr`.

---

**3.** Exhibit — tenant settings:

```text
Password reset → Properties: Selected → group "Pilot-SSPR"
Authentication methods required to reset: 2
Methods: Email, Mobile phone, Security questions
Registration: Require users to register when signing in = Yes
On-premises integration: Write back passwords = No
```

Lea is **cloud-only**, in `Pilot-SSPR`, and has registered email only. She forgot her password. What happens?

A. She resets with email; writeback is irrelevant for cloud-only users.
B. She cannot complete SSPR because the tenant requires two methods and she registered one.
C. She resets, but the password also writes to AD DS automatically.
D. She cannot reset because writeback is Off.

---

**4.** Complete each blank.

1. SSPR Properties can be ________, ________, or ________.
2. Number of methods required to reset is ________ or ________.
3. Hybrid password writeback minimum edition is ________.
4. Test SSPR with a ________ account, not a Global Administrator.

---

**5.** Put these in a sensible **pilot-then-production** order.

- Set Properties to All (or the production group).
- Enable writeback in Entra Connect and on the SSPR On-premises integration page (if users are synced).
- Enable SSPR for a Selected pilot group.
- Require registration on sign-in and confirm the helpdesk ticket volume dropped.

---

**6.** Case study — Contoso. Lowest cost that meets **all**:

- 800 users are **synced** from AD DS and must reset forgotten passwords without the helpdesk.
- After reset they must sign in to on-premises PCs the same day.
- 20 cloud-only guests are out of scope for this project.
- The company already has Entra ID Free.

A. Free SSPR for All; skip writeback.
B. P1 for the 800 synced users, SSPR Selected = those users, writeback on.
C. P2 for all 820 identities so PIM can reset passwords.
D. P1 for the 20 guests only; writeback off; synced users change passwords in AD DS.

---

**7.** Exhibit — Entra Connect “View current configuration” shows the AD DS connector account. Password writeback is checked in Connect. SSPR On-premises integration writeback is Yes. Synced users still fail to sign in on-prem after a cloud reset.

Which permission gap is the most likely?

A. The users need the Azure Contributor role on the AD DS virtual network.
B. The Connect AD DS account lacks **Reset password** (and related) rights in Active Directory.
C. Global Administrator must be a member of Domain Admins.
D. SSPR Properties must be set to None during writeback.

---

**8.** A Password Administrator resets another administrator’s password. Which SSPR notification setting tells **other admins** that happened?

A. Notify users on password resets
B. Notify all admins when other admins reset their password
C. Require users to register when signing in
D. Number of days before reconfirm

---

**9.** Select the **two** correct statements.

A. Combined registration lets a user enroll MFA and SSPR methods in one security-info experience.
B. Password writeback requires Entra ID P2.
C. Users should register more methods than the number required to reset.
D. Enabling SSPR for All also grants those users Owner on every subscription.
E. Security questions are the preferred SSPR method for Global Administrator.

---

**10.** Exhibit — Bicep will not configure SSPR (it is not an ARM resource). Which portal path is the one that turns SSPR on for a pilot group?

A. Azure Policy → Assignments → auditIfNotExists password reset
B. Subscription IAM → Role assignments → Password Administrator
C. Microsoft Entra ID → Password reset → Properties → Selected
D. Microsoft Entra ID → Groups → New dynamic group → `user.sspr -eq true`

---

## Submission — 2026-10-02

1. B, C
2. No, Yes, No, No
3. B
4. (1) All, Selected, None (2) 2, more (3) P1 (4) test
5. 3, 2, 4, 1 (Selected → writeback → registration/tickets → All)
6. B
7. B
8. B
9. A, C
10. C

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

Pass line is 9/10. Module 6 is **not** checked off.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — Connect writeback **and** P1 + SSPR on-prem writeback. Free / PIM / AU do not write to AD DS |
| 2 | **Wrong** | No / Yes / **Yes** / No — Properties **None** turns SSPR **off** for ordinary users. You marked statement 3 No |
| 3 | Correct | B — policy requires **two** methods; she registered one |
| 4 | **Wrong** | None / Selected / All (you had this). Reset count is **1 or 2**, not “2, more”. Writeback **P1**. Test with a **non-admin** account. “Register more than required” is Q9, not the reset-count blank |
| 5 | Correct | Pilot group → writeback if hybrid → prove registration/tickets → then All |
| 6 | Correct | B — P1 on the 800 synced users + writeback; guests out of scope |
| 7 | Correct | B — Connect’s AD DS account needs Reset password rights |
| 8 | Correct | B — notify admins when **another admin** is reset |
| 9 | Correct | A, C — combined registration; register more methods than required to reset |
| 10 | Correct | C — Password reset → Properties → Selected |

### Q2 statement 3 — what “None” means

Properties is a three-way switch for **who may use SSPR**:

| Value | Regular users |
| --- | --- |
| **None** | SSPR is **off** for them |
| **Selected** | Only members of the group you pick (pilot) |
| **All** | Everyone in the tenant (who is licensed / in policy) |

Admins still have a separate, stricter admin-reset path. Statement 3 is only about **regular** users: None = they are not included. That is a **Yes**.

### Q4 blank 2 — two different numbers

- **Methods required to reset:** **1 or 2** (the policy knob).
- **Methods a user should register:** **more than** that number (so they are not stuck).

You put the second fact in the first blank. Q9 already tests “register more.”
