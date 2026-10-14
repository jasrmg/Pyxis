# Module 3 (Host your domain on Azure DNS) — Quiz 1

Date issued: 2026-10-14
Scope: this module — public Azure DNS zones, records, registrar NS delegation, alias records, private DNS VNet links / auto-registration. Not Traffic Manager internals, App Gateway, or custom on-prem DNS servers.
Pass: **9/10**. Closed notes. Skim `../README.md` first if the week off wiped the unit.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Azure DNS registers `contoso.com` with ICANN so you do not need a registrar.
B. Creating an Azure DNS zone creates SOA and NS records automatically.
C. A CNAME record is the supported way to map `contoso.com` (apex) to a Traffic Manager profile.
D. An alias A record can point at a Standard public IP resource.
E. Private DNS zones are published to the public internet the same way as public zones.

---

**2.** For each statement, answer **Yes** or **No**.

1. Azure DNS can purchase and register a domain name.
2. An alias record can exist at the zone apex.
3. A CNAME record can exist at the zone apex.
4. A VNet needs a virtual network link to resolve names in a private DNS zone.

---

**3.** Exhibit:

```bash
az network dns zone create -g rg-dns -n contoso.com
az network dns record-set a add-record -g rg-dns -z contoso.com \
  -n www --ipv4-address 20.45.12.8
```

What is true after a successful deploy (ignore registrar delegation)?

A. `www.contoso.com` has an A record to `20.45.12.8`.
B. `contoso.com` (apex) has an A record to `20.45.12.8`.
C. The command creates a CNAME from `www` to `20.45.12.8`.
D. It fails; Azure DNS cannot host `contoso.com` until you buy it inside the portal.

---

**4.** Complete each blank.

1. Azure DNS ________ a domain; a ________ sells the name.
2. To make the internet use Azure DNS, put the zone ________ records at the ________.
3. Alias record types: A, AAAA, and ________.
4. Auto-registration writes ________ records for the VM ________ NIC.

---

**5.** Put these in order so `www.contoso.com` resolves on the public internet to your web PIP.

- Create A or alias records in the Azure zone.
- Register `contoso.com` at a domain registrar.
- Copy the Azure zone NS records to the registrar.
- Create the Azure DNS zone `contoso.com`.

---

**6.** Case study — lowest complexity that meets **all**:

- Users must reach the site as `contoso.com` (apex), not only `www`.
- Front end is Azure Traffic Manager (CNAME to TM is the usual pattern for `www`).
- The apex cannot be a CNAME.
- If the backend public IP resource is deleted, DNS must not keep advertising a stale IP.

A. CNAME `@` to `contoso.trafficmanager.net`.
B. Alias A/AAAA at `@` targeting the Traffic Manager profile; `www` can be CNAME or alias to the same profile.
C. Hand-typed A record at `@` with last week’s PIP, TTL 86400, no alias.
D. Private DNS zone `contoso.com` with auto-registration so home PCs resolve the apex.

---

**7.** You need to prove to Microsoft 365 that you own `contoso.com`. Which record type is the usual tool?

A. SOA
B. TXT
C. PTR
D. SRV

---

**8.** Exhibit:

```bash
az network dns record-set a create -g rg-dns -z contoso.com -n www \
  --target-resource "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-web"
```

`pip-web` is Standard SKU. Someone later **deletes** `pip-web`. What happens to the DNS name?

A. `www.contoso.com` keeps resolving to the old IP forever.
B. The alias record set becomes empty (no dangling IP); it no longer points at the deleted PIP.
C. Azure recreates `pip-web` automatically so DNS never breaks.
D. The zone is deleted because alias records own the public IP.

---

**9.** Select the **two** true statements about private DNS.

A. A VNet can have auto-registration to only one private DNS zone.
B. Auto-registration creates PTR records for every NIC on the VM.
C. A resolution-only VNet link lets VMs query the zone without auto-creating A records.
D. Private zones answer queries from any client on the internet.
E. You enable auto-registration by associating the zone to a public IP.

---

**10.** Exhibit — Bicep:

```bicep
resource zone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: 'contoso.com'
  location: 'global'
}

resource apexCname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: zone
  name: '@'
  properties: {
    TTL: 3600
    CNAMERecord: { cname: 'contoso.trafficmanager.net' }
  }
}
```

What happens?

A. Succeeds; `@` is the supported apex CNAME pattern.
B. Fails or is invalid DNS; CNAME is not allowed at the zone apex. Use an alias A/AAAA instead.
C. Succeeds and silently converts the CNAME to an A record.
D. Fails because `dnsZones` cannot host `contoso.com` — you must use `privateDnsZones`.

---

## Submission — 2026-10-14

1. B, D
2. No, Yes, No, Yes
3. A
4. host, idk; idk; CNAME; idk, primary
5. 4 → 2 → 3 → 1
6. B
7. A
8. B
9. C, A
10. B

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — SOA/NS on zone create; alias A → Standard PIP. Azure DNS does not register; CNAME ≠ apex; private ≠ public internet |
| 2 | Correct | No / Yes / No / Yes |
| 3 | Correct | A — `-n www` → FQDN `www.contoso.com` |
| 4 | **Wrong** | **hosts** / **registrar**; **NS** at the **registrar**; CNAME; **A** records on the **primary** NIC. You had host + CNAME + primary |
| 5 | Correct | 4231 is legal (zone, buy, paste NS, then records). Textbook order is also 2-4-3-1 (buy first) |
| 6 | Correct | B — alias at apex; not CNAME `@` |
| 7 | **Wrong** | **B TXT** — M365 domain verify is a TXT record. SOA is auto-created with the zone; it does not prove ownership to M365 |
| 8 | Correct | B — alias becomes an empty set when the PIP is deleted |
| 9 | Correct | A, C — one registration zone per VNet; resolution link queries without auto-reg |
| 10 | Correct | B — no CNAME at `@` |

Closed: host vs register at a high level, alias vs CNAME apex, private-zone links, alias dangling PIP.

Open: **NS at the registrar** (delegation), auto-reg writes **A** records, **TXT** for domain verify.
