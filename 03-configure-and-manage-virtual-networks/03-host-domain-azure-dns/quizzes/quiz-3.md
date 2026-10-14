# Module 3 (Host your domain on Azure DNS) — Quiz 3

Date issued: 2026-10-14
Scope: this module — public zones, apex vs portal name, NS delegation, alias vs CNAME, record sets, private DNS links / auto-registration. Not Traffic Manager internals, App Gateway, or custom on-prem DNS.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements. Zone is `jasrmg-dev.com`.

A. Two A records for portal name `www` (two IPs) are **one** record set.
B. A `www` A record and a `www` TXT record are **two** record sets.
C. A CNAME record set can hold two target names at once.
D. Portal name `@` is a subdomain Azure appends before the zone.
E. SOA is a record set you add yourself after you buy the domain.

---

**2.** For each statement, answer **Yes** or **No**.

1. Auto-registration writes PTR records for every NIC on the VM.
2. Auto-registration writes A records for the VM primary NIC.
3. An extra NIC and an internal load balancer get auto-created DNS records.
4. A VNet can enable auto-registration to only one private DNS zone.

---

**3.** Exhibit:

```bicep
resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'corp.contoso.com'
  location: 'global'
}

resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: zone
  name: 'link-app'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: { id: vnetApp.id }
  }
}
```

What is true after a successful deploy?

A. Internet clients resolve `corp.contoso.com` using this zone’s NS records.
B. VMs in `vnetApp` get auto-created **A** records on the **primary** NIC.
C. Azure copies NS records to the registrar because `registrationEnabled` is true.
D. The deploy fails; private zones cannot enable registration.

---

**4.** Complete each blank.

1. A record set is keyed by name plus ________.
2. To delegate a public zone, paste ________ records at the ________.
3. Microsoft 365 ownership checks usually look for a ________ record.
4. Auto-registration writes ________ records, not ________.

---

**5.** You want `vm1.corp.contoso.com` inside a VNet. Nothing exists yet. Textbook order so auto-registration can write the A **when the VM is created**:

- Create the private DNS zone `corp.contoso.com`.
- Deploy the VM in the VNet.
- Create the VNet link with auto-registration enabled.
- From another VM in that VNet, resolve `vm1.corp.contoso.com`.

---

**6.** Case study — lowest complexity that meets **all**:

- `www.contoso.com` must answer **two** public IPv4 addresses.
- `contoso.com` (apex) must sit on Azure Traffic Manager. CNAME at apex is illegal.
- Home laptops on the internet must resolve both names.
- Microsoft 365 must be able to verify the domain.

A. Two `www` A record sets; CNAME `@` to TM; SOA for M365.
B. One `www` A set with two IPs; alias A at `@` to TM; NS at registrar; TXT for M365.
C. Private zone auto-reg only; skip registrar NS; PTR for M365.
D. Hand-typed A at `@`; `www` CNAME only; skip ownership records.

---

**7.** You try to create an alias A record whose target is a **Basic** public IP. What happens?

A. Succeeds; alias supports Basic and Standard public IPs.
B. Fails or is unsupported; alias targets a **Standard** public IP (or TM / CDN / Front Door).
C. Succeeds and silently converts the alias to a CNAME at the apex.
D. Succeeds and registers `contoso.com` at the registrar.

---

**8.** Exhibit:

```powershell
New-AzPrivateDnsZone -Name corp.contoso.com -ResourceGroupName rg-dns
New-AzPrivateDnsVirtualNetworkLink -Name link-app `
  -ResourceGroupName rg-dns -ZoneName corp.contoso.com `
  -VirtualNetworkId $vnet.Id -EnableRegistration $false
```

VMs in that VNet can query the zone, but no A records appear for new VMs. Why?

A. Private zones never create A records; you must use `New-AzDnsZone`.
B. `-EnableRegistration $false` is a resolution-only link.
C. `$false` publishes the zone to the internet instead of the VNet.
D. The zone name must be `@` for auto-registration to run.

---

**9.** Select the **two** true statements.

A. Split-horizon: the same name can exist as public and private; a linked VNet gets the private answer.
B. One VNet auto-registers to at most one private DNS zone.
C. A private zone answers queries from any client on the internet.
D. Auto-registration writes PTR records for extra NICs.
E. You enable auto-registration by associating the zone to a public IP.

---

**10.** Exhibit:

```bash
az network dns record-set a add-record -g rg-dns -z jasrmg-dev.com \
  -n www --ipv4-address 20.1.2.3
az network dns record-set txt add-record -g rg-dns -z jasrmg-dev.com \
  -n www --value "MS=ms123456"
```

What is true?

A. Azure merged both into **one** record set named `www`.
B. That is **two** record sets: `www` A and `www` TXT.
C. The TXT command overwrites and deletes the A record.
D. The TXT command fails; a name may have only one record type.

---

## Submission — 2026-10-14

1. A, C
2. No, Yes, No, Yes
3. B
4. value; NS, registrar; TXT; A, PTR
5. 1324
6. B
7. B
8. C
9. A, E
10. A

## Score: 5/10 (50%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | **Wrong** | **A, B** — two A IPs = one set; `www` A + `www` TXT = two sets. CNAME cannot be multi-value |
| 2 | Correct | No / Yes / No / Yes |
| 3 | Correct | B — `registrationEnabled: true` → auto **A** on **primary** NIC |
| 4 | **Wrong** | name + **type** (not value); NS at registrar; TXT; **A** not **PTR**. Blanks 2–4 were right |
| 5 | Correct | 1 → 3 → 2 → 4 (zone, link auto-reg, VM, resolve) |
| 6 | Correct | B |
| 7 | Correct | B — alias needs **Standard** PIP (or TM/CDN/AFD), not Basic |
| 8 | **Wrong** | **B** — `-EnableRegistration $false` is resolution-only. It does **not** publish the zone to the internet |
| 9 | **Wrong** | **A, B** — split-horizon; one auto-reg zone per VNet. Auto-reg is a **VNet link**, not a public IP association |
| 10 | **Wrong** | **B** — different **types** = two record sets, even with the same name `www` |

Closed: auto-reg A/primary Y/N, NS at registrar, TXT, alias Standard, private-zone Bicep, textbook private order, case study alias apex.

Open: **record set = name + type** (Q1/Q4/Q10); CNAME not multi-value; `$false` = resolution-only; auto-reg = **VNet link**, one zone per VNet.
