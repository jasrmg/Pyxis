# Module 3 (Host your domain on Azure DNS) — Quiz 2

Date issued: 2026-10-14
Scope: this module — public zones, portal name vs apex vs FQDN, registrar NS delegation, alias vs CNAME, record sets, private DNS VNet links / auto-registration. Not Traffic Manager internals, App Gateway, or custom on-prem DNS.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements. Zone name is `jasrmg-dev.com`.

A. Portal name `www` makes the FQDN `www.jasrmg-dev.com`.
B. The apex of `jasrmg-dev.com` is `www.jasrmg-dev.com`.
C. `jasrmg-dev.com/projects` is a DNS name whose portal name is `projects`.
D. Portal name `@` is the apex (`jasrmg-dev.com`).
E. You type the full FQDN, including the zone, in the Azure Name box.

---

**2.** For each statement, answer **Yes** or **No**.

1. Creating an Azure DNS zone registers the domain with the registrar for you.
2. Delegation is pasting the Azure zone’s NS records at the registrar.
3. Creating the zone auto-creates SOA plus NS records (typically four name servers).
4. A handwritten A record at `@` with last week’s IP updates itself if that Standard public IP resource is deleted.

---

**3.** Exhibit. The admin wants **internet** users to resolve `jasrmg-dev.com` from Azure DNS.

```bash
az network private-dns zone create -g rg-dns -n jasrmg-dev.com
```

What is true after a successful deploy?

A. This is the correct public zone; next paste its NS at Namecheap.
B. This creates a **private** zone. Internet resolvers do not use it as public DNS.
C. Azure registers `jasrmg-dev.com` with ICANN as part of the command.
D. The command fails; a private zone cannot be named `jasrmg-dev.com`.

---

**4.** Complete each blank.

1. In the portal Name box, the apex of `jasrmg-dev.com` is typed as ________.
2. To make the public internet use Azure DNS, put the zone ________ records at the ________.
3. Microsoft 365 domain ownership checks usually look for a ________ record.
4. Private-zone auto-registration writes ________ records for the VM ________ NIC.

---

**5.** You already own `jasrmg-dev.com` at Namecheap. Azure has **no** zone yet. Internet users still hit Namecheap’s parking page. Put these in the **textbook** order.

- Test with `nslookup` against an Azure name server.
- Copy the Azure zone NS records into Namecheap’s nameserver fields.
- Create the Azure DNS zone `jasrmg-dev.com`.
- Create an alias A record; portal name `@`; target = the Standard public IP.

---

**6.** Case study — lowest complexity that meets **all**:

- Browser URL must be exactly `jasrmg-dev.com` (apex), not only `www`.
- Site runs on a VM with a **Standard** public IP.
- If that public IP **resource** is deleted, DNS must not keep advertising the old number.
- Home laptops on the internet must resolve the name.

A. Private DNS zone `jasrmg-dev.com` with auto-registration on the VM’s VNet.
B. Public zone; alias A at `@` targeting the PIP; paste Azure NS at Namecheap.
C. Public zone; CNAME `@` to the VM’s `*.cloudapp.azure.com` name.
D. Public zone; only an A record named `www`; users bookmark `www` forever.

---

**7.** Exhibit. Zone `jasrmg-dev.com`. An admin runs:

```bash
az network dns record-set a add-record -g rg-dns -z jasrmg-dev.com \
  -n www --ipv4-address 20.1.2.3
az network dns record-set a add-record -g rg-dns -z jasrmg-dev.com \
  -n www --ipv4-address 20.1.2.4
```

What is true?

A. Azure created **two** record sets named `www`.
B. That is **one** `www` A record set with two IPv4 values.
C. The second command fails; A record sets can hold only one IP.
D. Both commands write CNAME records, not A records.

---

**8.** Exhibit. Goal: browser URL is exactly `jasrmg-dev.com` (apex).

```powershell
New-AzDnsZone -Name jasrmg-dev.com -ResourceGroupName rg-dns
New-AzDnsRecordSet -Name www -RecordType A -ZoneName jasrmg-dev.com `
  -ResourceGroupName rg-dns -Ttl 3600 `
  -DnsRecords (New-AzDnsRecordConfig -IPv4Address 20.1.2.3)
```

Hot area: which **one** parameter value do you change, and to **what**?

Do **not** pick a different record type. Fill in: change `________` to `________`.

---

**9.** Select the **two** true statements about private DNS.

A. One VNet can enable auto-registration to two private zones at the same time.
B. Auto-registration does not create records for extra NICs or an internal load balancer; those are manual.
C. A VNet link with registration disabled still lets VMs in that VNet query the zone.
D. A coffee-shop laptop on the public internet resolves names in a private zone with no VNet link and no forwarding.
E. Auto-registration writes PTR records for every NIC.

---

**10.** Exhibit. You need an **alias** A at the apex that tracks a Standard public IP. Which command is the one that does that job?

```bash
# A
az network dns record-set cname set-record -g rg-dns -z jasrmg-dev.com \
  -n "@" -c pipweb.eastus.cloudapp.azure.com

# B
az network dns record-set a create -g rg-dns -z jasrmg-dev.com -n "@" \
  --target-resource "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-web"

# C
az network private-dns record-set a add-record -g rg-dns -z jasrmg-dev.com \
  -n "@" -a 20.1.2.3

# D
az network dns record-set a add-record -g rg-dns -z jasrmg-dev.com \
  -n www --ipv4-address 20.1.2.3
```

A. Command A  
B. Command B  
C. Command C  
D. Command D  

---

## Submission — 2026-10-14

1. A, D
2. No, Yes, Yes, No
3. B
4. @; NS, registrar; TXT; A, primary
5. 3241
6. B
7. A
8. www → @
9. C, E
10. B

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, D — portal `www` → `www.jasrmg-dev.com`; `@` is apex. `/projects` is a path, not a DNS name |
| 2 | Correct | No / Yes / Yes / No |
| 3 | Correct | B — `private-dns` is not a public zone |
| 4 | Correct | `@`; **NS** at the **registrar**; **TXT**; **A** on **primary** NIC |
| 5 | Correct | 3 → 2 → 4 → 1 (zone, paste NS, alias `@`, nslookup) |
| 6 | Correct | B — public zone + alias A at apex + NS at registrar |
| 7 | **Wrong** | **B** — one `www` A **record set**, two IPv4 values. Same name + same type = one set |
| 8 | Correct | change `www` to `@` |
| 9 | **Wrong** | **B, C** — extra NIC/ILB are manual; resolution link still queries. Auto-reg writes **A** on **primary** NIC, not PTR |
| 10 | Correct | B — alias A at `@` with `--target-resource` |

Closed: apex `@`, NS at registrar, TXT, auto-reg A/primary, `dns` vs `private-dns`, alias command, textbook order.

Open: **record set** = name + type (multi-value A is still one set); auto-reg is **A not PTR**, extra NIC/ILB **manual**.

