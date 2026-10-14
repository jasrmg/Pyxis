# Module 3 — Host your domain on Azure DNS

Learn module: [Host your domain on Azure DNS](https://learn.microsoft.com/en-us/training/modules/host-domain-azure-dns/) (7 units)

**Aim:** host a domain in Azure DNS, create records (especially A), alias records that track an Azure resource.

This is **name resolution**. It is not a registrar, not Traffic Manager itself, not App Gateway.

---

## What Azure DNS is

Azure DNS **hosts** DNS zones on Azure’s name servers. You manage records with the same ARM credentials, RBAC, locks, and activity logs as other resources.

**Azure DNS does not register a domain.** Buy `contoso.com` at a registrar (GoDaddy, Namecheap, App Service domains, …). Then **delegate**: paste the Azure zone’s **NS** records at the registrar.

Creating a zone auto-creates:

- **SOA** — start of authority (this zone)
- **NS** — Azure name servers for the zone

You cannot use Azure DNS as the place you “purchase” the name. Exam loves that trap.

Learn still treats **DNSSEC** as not a reason to pick Azure DNS as the only host. Do not invent DNSSEC as the Azure DNS killer feature.

---

## Record types (this module)

Zone in these examples: `contoso.com`. Portal **Name** is only the left label. Azure appends the zone.

**FQDN** = full name a client looks up (`www.contoso.com`).  
**Apex** = the zone itself (`contoso.com`). Portal name `@`. You cannot put a **CNAME** here.

| Portal name | Type | Example value | FQDN the world queries |
| --- | --- | --- | --- |
| `@` | A (or alias A) | Standard public IP / `20.1.2.3` | `contoso.com` |
| `www` | A | `20.1.2.3` | `www.contoso.com` |
| `shop` | CNAME | `www.contoso.com` | `shop.contoso.com` → same as www |
| `@` | MX | `10 mail.contoso.com` | mail for `contoso.com` |
| `@` | TXT | `MS=ms123456` | domain verify |
| `@` | NS / SOA | Azure name servers | created with the zone |

**Record set** = one **name + type** that can hold **several values**. Example: name `www`, type **A**, two IPs:

```
www.contoso.com.  3600  IN  A  20.1.2.3
www.contoso.com.  3600  IN  A  20.1.2.4
```

That is **one** record set, two records. Same TTL. **SOA and CNAME cannot** be multi-value record sets.

TTL = how long resolvers cache. Lower TTL = faster change, more queries.

Portal: **DNS zone → Record sets → + Add**. Type A, Alias = No, IP = your **public** IP in real life (Learn uses `10.10.10.10` only as a lab dummy).

Official click-through with Microsoft’s portal pictures: [Create a public DNS zone and record (portal)](https://learn.microsoft.com/en-us/azure/dns/dns-getstarted-portal). Learn exercise (same clicks): [Create a DNS zone and an A record](https://learn.microsoft.com/en-us/training/modules/host-domain-azure-dns/4-exercise-create-dns-zone-a-record).

---

## Delegation (the actual “host my domain” steps)

1. Register the name at a **registrar**.
2. Create a **DNS zone** `contoso.com` in Azure.
3. Copy the zone **NS** records to the registrar (replace the registrar’s NS).
4. Create **A / AAAA / CNAME / alias** records in Azure.
5. Test with `nslookup` / `dig` against Azure name servers, then against the internet after TTL.

Until NS at the registrar point at Azure, the world still uses the old DNS host.

### Walkthrough — you want `https://jasrmg-dev.com`

**Apex is not a second secret name.** It is the URL you asked for: `jasrmg-dev.com`. Nothing in front. `www.jasrmg-dev.com` is a different name in the same zone.

**Portal name** is only the box Azure shows, because the zone is already `jasrmg-dev.com`:

| You want people to type | Portal Name | Azure builds this FQDN |
| --- | --- | --- |
| `jasrmg-dev.com` | `@` | `jasrmg-dev.com` (**apex**) |
| `www.jasrmg-dev.com` | `www` | `www.jasrmg-dev.com` |

1. Buy `jasrmg-dev.com` at a registrar (Namecheap, GoDaddy, …). That is **register**. Azure does not sell it.
2. Portal: Create a resource → **DNS zone**. Name = `jasrmg-dev.com`. Azure creates **SOA** and **NS** (`ns1-xx.azure-dns.com`, …).
3. At the registrar, replace nameservers with those Azure **NS** values. That is **delegate**. Not the same step as buying.
4. Put the site on something with a **Standard public IP** (VM) or an Azure web product.
5. Zone → Record sets → **+ Add**:
   - Name `@`, Type **A**, Alias **Yes**, target = that public IP (or App Service / Front Door / Static Web Apps per product docs). This makes **`jasrmg-dev.com`** open the portfolio. **Not** a CNAME on `@`.
   - Optional: Name `www`, Type **CNAME**, value `jasrmg-dev.com` so `www.jasrmg-dev.com` works too.
6. `nslookup jasrmg-dev.com ns1-xx.azure-dns.com` should return the public IP.

**Buy ≠ paste NS.** Buy = you own the string. Paste NS = the internet asks Azure for that string.

---

## Alias records

An **alias** is a record set (types **A**, **AAAA**, or **CNAME**) that **points at an Azure resource** (or another record set in the **same** zone) instead of a static IP/name.

Typical targets: **Standard** public IP, Traffic Manager profile, Azure CDN / Front Door endpoint.

Why the exam cares:

- Public IP **changes or is deleted** → alias **updates** (or becomes an empty set). No dangling A record pointing at someone else’s new IP.
- **CNAME is illegal at the zone apex.** Alias **A/AAAA** at `@` can point at Traffic Manager or CDN. That is how `contoso.com` (not only `www.contoso.com`) sits on a load-balanced Azure endpoint.

A plain A record with a typed-in IP does **not** follow the public IP resource.

---

## Private DNS (same Learn unit’s “why Azure DNS”)

A **private DNS zone** is **not** on the public internet. VMs resolve it only if their VNet has a **virtual network link**.

| Link | Auto-registration | Meaning |
| --- | --- | --- |
| Registration | **On** | VNet is the zone’s registration network. Azure creates **A** records for VM **primary** NICs; removes them on delete/stop. |
| Resolution | **Off** | VMs can **query** the zone. No auto A records. |

Rules:

- One VNet ↔ **one** private zone **with auto-registration**.
- One zone can have **many** registration VNets and **many** resolution VNets.
- One VNet can have **many** resolution zones.
- Auto-reg is **VMs / primary NIC only**. No PTR. ILB and extra NICs = **manual** records.
- **Split-horizon:** same name as a public zone; inside the VNet you get the private answer.

Azure-provided names (`*.internal.cloudapp.net`) still exist. Private DNS is how you use `vm1.corp.contoso.com` inside the VNet.

---

## Create (exam stack)

```bash
# Public zone + A
az network dns zone create -g rg-dns -n contoso.com
az network dns record-set a add-record -g rg-dns -z contoso.com -n www --ipv4-address 20.1.2.3

# Alias A at apex → Standard public IP
az network dns record-set a create -g rg-dns -z contoso.com -n "@" \
  --target-resource "/subscriptions/<sub>/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-web"

# Private zone + registration link
az network private-dns zone create -g rg-dns -n private.contoso.com
az network private-dns link vnet create -g rg-dns -n link-app \
  -z private.contoso.com -v vnet-app -e true
```

```powershell
New-AzDnsZone -Name contoso.com -ResourceGroupName rg-dns
New-AzDnsRecordSet -Name www -RecordType A -ZoneName contoso.com -ResourceGroupName rg-dns -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -IPv4Address 20.1.2.3)
New-AzPrivateDnsZone -Name private.contoso.com -ResourceGroupName rg-dns
```

| Flag | Meaning |
| --- | --- |
| `az network dns` | **Public** zone (`private-dns` = private) |
| `-g` / `--resource-group` | Resource group |
| `-n` / `--name` | Zone name, record-set name, or link name (depends on the command) |
| `-z` / `--zone-name` | Which zone the record belongs to |
| `--ipv4-address` | The A record’s IP |
| `-n "@"` | Apex (`contoso.com`) |
| `--target-resource` | Alias: ARM ID of a Standard PIP (or TM/CDN/AFD) |
| `-v` | VNet name for a private-zone link |
| `-e true` | Enable auto-registration |

Bicep: `Microsoft.Network/dnsZones` (public), `Microsoft.Network/privateDnsZones` plus `virtualNetworkLinks` (private). Do not mix the two types.

---

## Enterprise scenarios

### 1. “Just create www in Azure DNS, the domain already works at GoDaddy”

Without **NS delegation** at GoDaddy, Azure records are invisible on the internet.

### 2. “CNAME the apex to myapp.trafficmanager.net”

Illegal. Use an **alias** A/AAAA at `@` targeting the Traffic Manager profile (or Front Door / CDN).

### 3. “VM public IP is static so a handwritten A record is fine”

Static today, deleted tomorrow → dangling record. Alias to the **public IP resource** if the name must follow that PIP.

### 4. “Private zone `contoso.com` so on-prem laptops resolve it”

Laptops on the internet hit **public** DNS. Private zone answers only from **linked VNets** (and DNS forwarding you set up later). Split-horizon is VNet vs internet, not “everyone who works here.”

---

## Exam traps from this module

1. Azure DNS **hosts**. It does **not register**.
2. Delegate with **NS** at the registrar. SOA/NS appear when the zone is created.
3. **CNAME** ≠ apex. **Alias** A/AAAA **can** be apex.
4. Alias types: **A, AAAA, CNAME**. Target is an Azure resource (Standard PIP, TM, CDN, Front Door) or a same-zone record set.
5. Private zone: **VNet link**. Auto-reg = A on **primary NIC**, one registration zone per VNet.
6. `az network dns` is public. `az network private-dns` is private. Wrong noun = wrong resource.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/03-host-domain-azure-dns/poc
./dns.sh            # prints the plan (no deploy)
APPLY=1 ./dns.sh    # public zone + www A, then deletes
```
