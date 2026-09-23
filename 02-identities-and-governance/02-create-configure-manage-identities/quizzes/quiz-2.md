# Module 2 (Create, configure, and manage identities) — Quiz 2

Date issued: 2026-09-23
Scope: this module only — users, groups, administrative units, device registration, licenses, custom security attributes, automatic provisioning.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** A 400-member **assigned** security group is converted to **dynamic** with the rule `(user.department -eq "Finance")`. 120 members match the rule; 4 of the remaining members were added by hand as deliberate exceptions.

Select the **two** correct statements.

A. Members matching the rule are present in the group once processing completes.
B. The conversion is blocked until the manual members are removed first.
C. The previous member list can be restored from the group's audit history.
D. The 4 exceptions are lost, and cannot be re-added by hand afterwards.
E. Manual membership continues to operate alongside the rule.

---

**2.** For each statement about administrative units, answer **Yes** or **No**.

1. An administrator holding a tenant-wide role is constrained by an AU that contains the target user.
2. An administrator must be a member of an AU in order to hold a role scoped to that AU.
3. A single user object can belong to more than one AU.
4. An AU can be granted the Reader role on an Azure subscription.

---

**3.** Exhibit — a Microsoft Graph request:

```http
PATCH https://graph.microsoft.com/v1.0/groups/4d2a-.../
```

```json
{
  "groupTypes": ["DynamicMembership"],
  "membershipRule": "(user.department -eq \"Finance\") or (device.deviceOSType -eq \"Windows\")",
  "membershipRuleProcessingState": "On"
}
```

Why does this request fail?

A. `membershipRuleProcessingState` must be `Paused` when a rule is first applied.
B. A single dynamic group cannot combine user attributes and device attributes.
C. `groupTypes` must also contain `Unified` for a rule to be evaluated.
D. Device rules require the `deviceOwnership` attribute rather than `deviceOSType`.

---

**4.** Exhibit — a user object returned from Microsoft Graph:

```json
{
  "displayName": "Ben Ramos",
  "userPrincipalName": "ben@contoso.com",
  "userType": "Member",
  "onPremisesSyncEnabled": true,
  "usageLocation": null,
  "assignedLicenses": []
}
```

An administrator must correct Ben's display name and assign him a Microsoft 365 E3 license. Which statement is correct?

A. Both changes can be made in the Entra portal; only the license needs a support request.
B. The display name must be changed on-premises; the license assignment needs `usageLocation` set.
C. The display name can be changed in the cloud; the license assignment requires `userType` to be Member.
D. Both changes fail until Ben is converted from a synchronized to a cloud-only account.

---

**5.** Complete each blank.

1. A deleted user is recoverable for ________ days. Also recoverable that way: ________ groups. Not recoverable: ________ groups.
2. `isAssignableToRole` can be set only at ________, and is incompatible with ________ membership.
3. The minimum edition for group-based licensing is ________, and for administrative-unit-scoped admins it is ________.
4. Automatic user provisioning to SaaS applications is driven by the ________ protocol.

---

**6.** The Cebu helpdesk currently holds **tenant-wide** `Helpdesk Administrator`. You must restrict them to Cebu users only, without leaving them unable to work at any point. Put these actions in order.

- Assign `Password Administrator` scoped to the administrative unit.
- Remove the tenant-wide `Helpdesk Administrator` assignment.
- Create the administrative unit.
- Confirm P1 licensing for the helpdesk staff receiving the scoped role.
- Add the Cebu user objects as members of the administrative unit.

---

**7.** Contoso has 300 laptops that must continue to receive Group Policy and authenticate to on-premises file servers with Kerberos, while also being evaluated by Conditional Access policies in Entra ID.

Which device state meets the requirement?

A. Microsoft Entra registered, with the corporate network added as a trusted location.
B. Microsoft Entra joined, with Entra Domain Services providing Kerberos tickets.
C. Hybrid Microsoft Entra joined, with the devices joined to AD DS and synchronized.
D. Microsoft Entra joined, with Entra Connect Sync writing the devices back on-premises.

---

**8.** A contractor from a partner firm needs access to one Azure resource group for three months. When the partner firm terminates her employment, her access to Contoso must end without Contoso doing anything.

Which approach meets the requirement?

A. Create a cloud-only member account in the Contoso tenant and set an expiry date on it.
B. Invite her as a B2B guest and add her to an assigned security group used for the RBAC assignment.
C. Invite her as a B2B guest, then convert her `userType` to Member so RBAC can be applied.
D. Create a cloud-only account and place it in a dynamic group keyed on her `department`.

---

**9.** Select the **two** correct statements about custom security attributes.

A. Global Administrator can read and write attribute values without further role assignment.
B. Creating an attribute set requires a role such as Attribute Definition Administrator.
C. They can be consumed by attribute-based access control for resource access.
D. They are populated from on-premises AD DS by Microsoft Entra Connect Sync.
E. They replace the 15 on-premises extension attributes in the user schema.

---

**10.** Exhibit — group structure in the Contoso tenant:

```json
{
  "displayName": "All-Engineering",
  "members": [
    { "type": "group", "displayName": "Platform-Team", "userCount": 28 },
    { "type": "group", "displayName": "QA-Team",       "userCount": 16 },
    { "type": "user",  "displayName": "Lea Cruz" }
  ]
}
```

A Microsoft 365 E3 license is assigned to `All-Engineering`, and the Contributor role on a subscription is assigned to `All-Engineering`.

How many users receive the licence, and how many receive Contributor?

A. 45 receive the licence; 45 receive Contributor.
B. 1 receives the licence; 45 receive Contributor.
C. 45 receive the licence; 1 receives Contributor.
D. 1 receives the licence; 1 receives Contributor.

---

## Submission — 2026-09-23

1. A, D
2. No, No, Yes, No
3. B
4. B
5. (1) 30, M365, security (2) at creation, dynamic (3) P1, P1 (4) SCIM
6. Create AU → add Cebu users → confirm P1 → assign scoped Password Administrator → remove tenant-wide Helpdesk Administrator
7. C
8. B
9. B, C
10. A

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, D — matching users return after discard-then-repopulate; exceptions are gone and cannot be re-added by hand |
| 2 | Correct | No / No / Yes / No — AU is not a fence; admin need not be a member; multi-AU membership is allowed; an AU is not a security principal |
| 3 | Correct | B — a dynamic group is user-based or device-based, never both |
| 4 | Correct | B — synced display name is edited on-prem; license needs `usageLocation` |
| 5 | Correct | 30-day soft delete for users and M365 groups, not security groups; `isAssignableToRole` at creation only, incompatible with dynamic; P1 / P1; SCIM |
| 6 | Correct | Create AU → add members → confirm P1 → assign scoped role → then drop the tenant-wide assignment so they are never without access |
| 7 | Correct | C — Hybrid Entra joined keeps AD DS join (GPO, Kerberos) and is visible to Conditional Access |
| 8 | Correct | B — B2B guest; credential lives in the partner tenant, so their offboarding kills Contoso access |
| 9 | Correct | B, C — Attribute Definition Administrator to create sets; consumed by ABAC. Global Admin does **not** get these permissions by default |
| 10 | **Wrong** | **B** — group-based licensing does **not** follow nested groups (only first-level **user** members: Lea Cruz). Azure RBAC **does** follow nesting (28 + 16 + 1 = 45). You treated both consumers as if they honour nesting |

Q10 is the only miss, and it is the exact distinction added to the notes today. Azure RBAC and group-based licensing both accept a group as the assigned principal, but they disagree about nesting. Memorise that split: RBAC walks the nest; licensing stops at the first-level users.

Interview gaps for this module: Assigned → Dynamic, AU group-object-vs-members, AU-not-a-fence / additive permissions, P1-for-the-scoped-admin. Those all landed on this paper. Remaining open: nested licensing vs nested RBAC.
