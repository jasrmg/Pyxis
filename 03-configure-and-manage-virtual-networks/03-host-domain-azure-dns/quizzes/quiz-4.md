# Module 3 (Host your domain on Azure DNS) — Quiz 4

Date issued: 2026-10-14
Scope: this module — public zones, apex / portal name, NS delegation, alias vs CNAME, record sets (name + type), private DNS VNet links / auto-registration. Not Traffic Manager internals, App Gateway, or custom on-prem DNS.
Pass: **9/10**. Closed notes. Last paper tonight.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A record set is uniquely identified by **name + type**.
B. A CNAME record set can hold two target names at the same time.
C. Auto-registration is a **VNet link** with registration enabled — not associating a zone to a public IP.
D. `-EnableRegistration $false` publishes the private zone to the internet.
E. Portal name `@` is a subdomain Azure inserts in front of the zone.

---

**2.** For each statement, answer **Yes** or **No**.

1. `www` A plus `www` TXT is a single record set.
2. `www` A with two IPv4 addresses is a single record set.
3. A VNet link with registration disabled is resolution-only (query, no auto A).
4. One VNet can enable auto-registration to two private DNS zones at the same time.

---

**3.** Exhibit. `vnet-app` already has a registration link to `corp.contoso.com`.

```bash
az network private-dns link vnet create -g rg-dns -n link-other \
  -z other.contoso.com -v vnet-app -e true
```

What is the expected result?

A. Succeeds; a VNet may auto-register to as many private zones as you want.
B. Not allowed / fails the intent: one VNet auto-registers to **one** private zone.
C. Succeeds and publishes both zones on the public internet.
D. Succeeds and registers `other.contoso.com` at the registrar.

---

**4.** Complete each blank.

1. A record set is keyed by ________ plus ________.
2. CNAME and SOA cannot be ________-value record sets.
3. Auto-registration is turned on with a ________ ________, not by attaching a public IP.
4. `-e false` / `-EnableRegistration $false` means the link is ________-only.

---

**5.** Goal: split-horizon `contoso.com` — internet uses **public** Azure DNS; VMs in `vnet-app` use a **private** zone of the same name. Put these in textbook order (internet first, then the VNet).

- Create the public DNS zone `contoso.com` and paste its NS at the registrar.
- Confirm a home laptop gets the public answer and a VM gets the private answer.
- Link `vnet-app` to the private zone with auto-registration enabled.
- Create the private DNS zone `contoso.com`.

---

**6.** Case study — lowest complexity that meets **all**:

- `www.contoso.com` must return two IPv4 addresses.
- `contoso.com` (apex) must follow an Azure Traffic Manager profile. CNAME at apex is illegal.
- VMs in `vnet-app` must resolve `vm1.corp.contoso.com` without internet DNS.
- Home laptops must **not** see that private zone.
- If the Standard public IP behind TM is deleted, public apex DNS must not keep a stale IP.

A. Two `www` A record sets; CNAME `@` to TM; associate the private zone to the PIP.
B. One `www` A set (two IPs); alias A at `@` to TM; NS at registrar; private zone + registration VNet link on `vnet-app` only.
C. Private zone only, auto-reg on `vnet-app`; skip the registrar; PTR for the apex.
D. Two `-e true` links from `vnet-app` to two private zones; handwritten A at `@`.

---

**7.** Auto-registration is on. The VM has a primary NIC plus a second NIC, and the subnet also has an internal load balancer. Which records appear automatically?

A. A records for the primary NIC, the extra NIC, and the ILB.
B. PTR records for every NIC.
C. An A record for the **primary** NIC only; extra NIC and ILB are manual.
D. A CNAME at `@` pointing at the ILB.

---

**8.** Exhibit:

```powershell
$r1 = New-AzDnsRecordConfig -IPv4Address 20.1.2.3
$r2 = New-AzDnsRecordConfig -IPv4Address 20.1.2.4
New-AzDnsRecordSet -Name www -RecordType A -ZoneName jasrmg-dev.com `
  -ResourceGroupName rg-dns -Ttl 3600 -DnsRecords $r1,$r2
```

How many record sets were created?

A. Two — one per IP.
B. One — name `www`, type A, two values.
C. Zero — A records cannot hold two IPs.
D. One CNAME record set; PowerShell converted the type.

---

**9.** Select the **two** true statements.

A. `-e false` still lets VMs in that VNet **query** the private zone.
B. A second `-e true` link from the same VNet to another private zone is not supported.
C. `-e false` copies NS records to GoDaddy.
D. Auto-registration writes PTR records for extra NICs.
E. You enable auto-registration by associating the private zone to a Standard public IP.

---

**10.** Exhibit:

```bicep
resource wwwA 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: zone
  name: 'www'
  properties: {
    TTL: 3600
    ARecords: [
      { ipv4Address: '20.1.2.3' }
      { ipv4Address: '20.1.2.4' }
    ]
  }
}

resource wwwTxt 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: zone
  name: 'www'
  properties: {
    TTL: 3600
    TXTRecords: [ { value: ['MS=ms123'] } ]
  }
}
```

After a successful deploy, how many record sets is that?

A. One — both resources share the name `www`.
B. Two — `www` A and `www` TXT.
C. Three — two A records plus one TXT.
D. Zero — duplicate `www` names make the deploy fail.

---

## Submission — 2026-10-14

1. A, C
2. No, Yes, Yes, No
3. B
4. name, type; multi; VNet link; resolution
5. 1432
6. B
7. C
8. B
9. A, E
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — record set = name + type; auto-reg is a VNet link |
| 2 | Correct | No / Yes / Yes / No |
| 3 | Correct | B — one auto-reg zone per VNet |
| 4 | Correct | name + type; multi; VNet link; resolution-only |
| 5 | Correct | 1 → 4 → 3 → 2 (public+NS, private zone, registration link, test) |
| 6 | Correct | B |
| 7 | Correct | C — auto A on **primary** NIC only |
| 8 | Correct | B — one `www` A set, two values |
| 9 | **Wrong** | **A, B** — `-e false` still queries; second `-e true` on the same VNet is not supported. E is alias (public PIP), not auto-reg |
| 10 | Correct | B — `www` A and `www` TXT are two record sets |

Closed: name+type, resolution-only, primary NIC A, alias apex, NS at registrar, split-horizon order.

Open for verbal: auto-reg = **VNet link**, not associating a private zone to a public IP. Q3 and Q9 asked the same limit (one `-e true` per VNet); Q3 was right, Q9 picked the PIP trap.

