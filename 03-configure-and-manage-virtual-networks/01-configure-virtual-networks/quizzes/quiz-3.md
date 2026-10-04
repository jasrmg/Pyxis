# Module 1 (Configure virtual networks) — Quiz 3

Date issued: 2026-10-04
Scope: this module only — VNets, subnets, CIDR containment, reserved IPs (per subnet), public vs private IP objects. Not NSG, peering how-to, DNS zones, or load-balancer SKUs.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Azure reserves five IPv4 addresses per virtual network, shared by all subnets.
B. Azure reserves five IPv4 addresses in every subnet.
C. `Microsoft.Network/publicIPAddresses` is the public IP resource type.
D. `Microsoft.Network/publicIPAddresses` is where the VM’s private IP is stored.
E. A VNet spans two regions when you pick a regional pair.

---

**2.** For each statement, answer **Yes** or **No**.

1. Subnet `10.8.4.0/24` fits inside VNet `10.8.0.0/22`.
2. Two `/24` subnets in one VNet share a single pool of five reserved IPs.
3. A private IP that must survive deallocate is set **static** on the NIC IP configuration.
4. You associate a public IP to the virtual network object.

---

**3.** Exhibit:

```bash
az network vnet create \
  --resource-group rg-net --name vnet-app --location eastus \
  --address-prefixes 10.4.64.0/18 \
  --subnet-name snet-web --subnet-prefixes 10.4.128.0/24
```

What happens?

A. Succeeds; `10.4.128.0/24` is RFC1918.
B. Fails; `10.4.128.0/24` is not inside `10.4.64.0/18`.
C. Succeeds and expands the VNet to `10.4.0.0/16`.
D. Fails because `/18` is not a valid VNet prefix.

---

**4.** Complete each blank.

1. Azure reserves five IPv4 addresses per ________.
2. Public IP resource type: `Microsoft.Network/________`.
3. Private IP lives on the ________.
4. `/22` paints the ________ octet; `10.8.0.0/22` last address is ________.

---

**5.** Put these in an order that never creates a NIC before its subnet.

- Create a public IP, SKU Standard, allocation Static.
- Associate that public IP to the NIC IP configuration.
- Create the VNet and `snet-web` (`10.20.1.0/24`).
- Create the NIC in `snet-web` with private IP static `10.20.1.10`.

---

**6.** Case study — lowest complexity that meets **all**:

- Two subnets, private talk between them.
- Second region later; VNets must be peerable.
- Jump host public IP must not change.
- No app VMs in `GatewaySubnet`.

A. One VNet `10.0.0.0/16`; second region reuses `10.0.0.0/16`; Basic dynamic public IP on the jump host.
B. `10.10.0.0/16` East US with two `/24`s; West Europe planned as `10.20.0.0/16`; Standard static public IP on the jump NIC; VMs only in the `/24`s.
C. One VNet in two regions so both share one address space.
D. One `/29` for all VMs and a Standard public IP attached to the VNet.

---

**7.** Exhibit — subnet `10.20.1.0/24`. Which static private IP is **invalid**?

A. `10.20.1.4`
B. `10.20.1.20`
C. `10.20.1.0`
D. `10.20.1.200`

---

**8.** Exhibit:

```powershell
New-AzPublicIpAddress -Name 'pip-web' -ResourceGroupName 'rg-net' `
  -Location 'eastus' -Sku 'Standard' -AllocationMethod 'Dynamic'
```

What happens?

A. Succeeds; Standard Dynamic is the default sticky public IP.
B. Fails or is rejected; Standard requires Static.
C. Succeeds; the VNet prefix becomes Static.
D. Succeeds only if you also set the NIC private IP to Dynamic.

---

**9.** Select the **two** true statements.

A. A public IP associates to a NIC IP configuration or an LB frontend.
B. A private IP is created with `New-AzPublicIpAddress`.
C. A NIC attaches to exactly one subnet.
D. Associating a public IP places the NIC in a second subnet.
E. Five reserved IPs are taken from the VNet prefix once, not from each subnet.

---

**10.** Exhibit — Bicep:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-app'
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.8.0.0/22' ] }
    subnets: [
      { name: 'snet-a', properties: { addressPrefix: '10.8.0.0/24' } }
      { name: 'snet-b', properties: { addressPrefix: '10.8.2.0/24' } }
    ]
  }
}
```

What happens on deploy?

A. Fails; two `/24`s cannot live in a `/22`.
B. Succeeds; both subnets sit inside `10.8.0.0`–`10.8.3.255` and do not overlap.
C. Succeeds; Azure shrinks `snet-a` so `snet-b` can start at `.2`.
D. Fails because Bicep cannot declare two subnets.

---

## Submission — 2026-10-04

1. B, C
2. Yes (`10.8.0.0`–`10.8.3.255`); No; Yes; No
3. B
4. subnet; publicIpAddresses; nic; 3rd, `10.8.3.255`
5. 3 → 4 → 1 → 2
6. B
7. C
8. B
9. C, A
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — five reserved **per subnet**; `publicIPAddresses` is the public IP type |
| 2 | **Wrong** | **No / No / Yes / No**. You wrote `10.8.0.0`–`10.8.3.255` (right) then said `10.8.4.0/24` fits (it does not). `.4` is the next `/22` |
| 3 | Correct | B — `10.4.64.0/18` is `10.4.64.0`–`10.4.127.255` |
| 4 | Correct | per **subnet**; `publicIPAddresses`; **NIC**; **3rd** octet; last `10.8.3.255` |
| 5 | Correct | `3412` = VNet → NIC → public IP → associate |
| 6 | Correct | B — non-overlapping spaces; Standard static on the jump NIC |
| 7 | Correct | C — `.0` is the network address |
| 8 | Correct | B — Standard requires Static |
| 9 | Correct | A, C — associate to NIC/LB; one NIC / one subnet |
| 10 | Correct | B — `10.8.0.0/24` and `10.8.2.0/24` both inside the `/22`, no overlap |

Closed: public vs private object, five-per-subnet, `/18`/`/22` paint, Standard+Static, create order.
Remaining nit: **write the range, then compare**. `10.8.4.0` is not ≤ `10.8.3.255`.
