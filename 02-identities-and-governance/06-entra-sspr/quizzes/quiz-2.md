# Module 6 (Entra SSPR) — Quiz 2

Date issued: 2026-10-02
Prerequisite: Quiz 1 scored 8/10 FAIL (Properties None; methods to reset are 1 or 2; test with a non-admin).
Pass: **9/10**. Closed notes.

Answer **every** numbered blank on Q4 before you open Q5.

---

**1.** Select the **two** true statements.

A. SSPR Properties **None** turns self-service reset **off** for regular users.
B. SSPR Properties **None** means no extra MFA is required during reset.
C. The number of methods **required to reset** is 1 or 2.
D. The number of methods required to reset is “2, or more if the user registered extra.”
E. Password writeback requires Entra ID P2.

---

**2.** For each statement, answer **Yes** or **No**.

1. You should test SSPR while signed in as Global Administrator.
2. Administrator SSPR cannot use security questions.
3. A user who registered fewer methods than required to reset can still complete SSPR with helpdesk-free email only.
4. Synced users need password writeback (and typically P1) if the new password must work on-premises.

---

**3.** Exhibit:

```text
Properties: All
Methods required to reset: 1
Methods enabled: Email, Mobile phone
Write back passwords: Yes
```

Ben is **synced**, licensed P1, and registered **email only**. He forgot his password and must open an on-premises file share afterward. Result?

A. SSPR succeeds (one method meets the policy) and writeback updates AD DS.
B. SSPR fails because admins require two methods and Ben is synced.
C. SSPR succeeds in the cloud only; writeback never applies to “All.”
D. SSPR fails until he registers security questions.

---

**4.** Complete **all four**.

1. Properties values: ________, ________, ________.
2. Methods required to reset: ________ or ________.
3. Users should **register** ________ methods than the reset requirement.
4. Test SSPR with a ________ account.

---

**5.** A tenant is on **None**. You must pilot 40 hybrid users, then go tenant-wide after tickets drop. Put the enablement steps in order (writeback is already on in Connect).

- Set Properties to All.
- Set Properties to Selected and pick the pilot group.
- Confirm those 40 users can reset and sign in on-prem.
- Set On-premises integration writeback to Yes if it is not already.

---

**6.** Case study — Fabrikam. Lowest cost that meets all:

- Cloud-only staff forgot passwords; no on-prem AD.
- Helpdesk must not handle those resets.
- Global Admins must not be the test accounts.
- Do not buy P2.

A. SSPR Selected = staff group; methods 1 or 2; test with a staff user; P2 for writeback.
B. SSPR Selected = staff group; methods 1 or 2; test with a non-admin staff user; writeback off (not needed).
C. SSPR None; Password Administrator on each subscription.
D. SSPR All; security questions only; test as Global Administrator.

---

**7.** Exhibit — two users:

```text
Maria: Global Administrator, registered email + security questions
Lea: Member, no admin role, in Pilot-SSPR, registered email + mobile
Properties: Selected = Pilot-SSPR
Methods required to reset: 1
Methods: Email, Mobile phone, Security questions
```

Who can complete SSPR as configured, and why?

A. Both. The tenant requires only one method.
B. Lea only. Maria is not in Pilot-SSPR, and admin reset cannot use security questions / follows the admin two-method rule.
C. Maria only. Global Administrator always bypasses Properties.
D. Neither. Writeback is not mentioned.

---

**8.** Which portal blade turns SSPR **off** for regular users without deleting the methods policy?

A. Properties → **None**
B. Authentication methods → set required methods to 0
C. Registration → reconfirm days = 0
D. Subscription IAM → remove Password Administrator

---

**9.** Select the **two** items that belong on the **On-premises integration** / Connect path, not on Properties.

A. Write back passwords to on-premises AD
B. Selected vs All vs None
C. Allow users to unlock accounts without resetting the password
D. Notify users on password resets
E. Combined registration URL

---

**10.** Complete the sentence (no options):

A synced user resets in the cloud. Writeback is **off**. They can sign in to ________ and they cannot sign in to ________ with that new password.

---

## Submission — 2026-10-02

1. A, C
2. No, Yes, No, Yes
3. A
4. None, Selected, All; 1 or 2; more; non-admin
5. 2, 4, 3, 1 (Selected → SSPR writeback Yes → confirm pilot → All)
6. B
7. B
8. A
9. A, E
10. cloud, on-prem

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — None = off for regular users; reset count is 1 or 2 |
| 2 | Correct | No / Yes / No / Yes |
| 3 | Correct | A — one registered method meets policy; writeback updates AD DS |
| 4 | Correct | None/Selected/All; 1 or 2; register **more**; **non-admin** |
| 5 | Correct | Pilot Selected, ensure writeback, prove it, then All |
| 6 | Correct | B — no writeback needed for cloud-only; no P2; don't test as GA |
| 7 | Correct | B — Lea; Maria hits the admin two-method / no-security-questions rule |
| 8 | Correct | A — Properties → None |
| 9 | **Wrong** | **A, C** — writeback and **unlock without reset** live on On-premises integration (and Connect). Combined registration is **not** that blade |
| 10 | Correct | Cloud **yes**; on-prem **no** when writeback is off |

Quiz 1 blanks are closed. One miss: **unlock without resetting** is the other On-premises integration checkbox, next to writeback. Notifications and combined registration are different pages.

Module 6 passed. Path 02 all six modules have a passing quiz.
