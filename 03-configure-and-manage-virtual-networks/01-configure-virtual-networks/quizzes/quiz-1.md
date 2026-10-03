# Module 1 (Configure virtual networks) — Quiz 1

Date issued: 2026-10-03
Scope: this module only — VNets, subnets, reserved IPs, public vs private IP, Standard vs Basic public IP. Not NSG, peering, DNS zones, or load balancers.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. An Azure virtual network can span two regions if you pick a paired region.
B. A NIC is attached to exactly one subnet.
C. Azure reserves five IPv4 addresses in every subnet.
D. A `/29` subnet has 8 usable host addresses after Azure reservations.
E. Two VNets that will be peered should use the same `10.0.0.0/16` space so routing is simple.

---

**2.** For each statement, answer **Yes** or **No**.

1. A Standard public IP can be created with allocation method Dynamic.
2. A private IP is a property of the NIC (or IP configuration), taken from the subnet range.
3. `AzureBastionSubnet` is a valid name for a subnet that will hold application VMs.
4. Subnets in one VNet may not overlap each other.

---

**3.** Exhibit:

```bash
az network vnet create \
  --resource-group rg-net --name vnet-app --location eastus \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name snet-web --subnet-prefixes 10.1.0.0/24
```

What happens?

A. Succeeds; the subnet can sit in any RFC1918 range.
B. Fails; `10.1.0.0/24` is not inside `10.0.0.0/16`.
C. Succeeds and silently expands the VNet to `10.0.0.0/8`.
D. Fails because a VNet must have two subnets at create time.

---

**4.** Complete each blank.

1. Azure reserves ________ IPv4 addresses per subnet.
2. New public IP SKU should be ________ with allocation ________.
3. “The VM’s private IP must not change after deallocate” → set the NIC IP to ________.
4. A VNet lives in one ________ and one ________.

---

**5.** Put these objects in the order you attach them so a VM has a **static** private IP `10.0.1.10` and a **Standard** public IP.

- Create the virtual network and `snet-web` (`10.0.1.0/24`).
- Create the VM (or NIC) in `snet-web` and set private IP static `10.0.1.10`.
- Create a public IP resource, SKU Standard, allocation Static.
- Associate the public IP with the NIC’s IP configuration.

---

**6.** Case study — Contoso. Lowest-complexity design that meets **all**:

- Web VMs in one subnet, data VMs in another; they must talk on the private network.
- Later, a second region will be added; the two VNets must be peerable.
- A jump host needs a public IP that does not change.
- Do not place VMs in a gateway or Bastion subnet.

A. One VNet `10.0.0.0/16` in East US with `snet-web` and `snet-data`; second region will reuse `10.0.0.0/16`; Basic dynamic public IP on the jump host.
B. VNet `10.10.0.0/16` East US with two `/24` subnets; plan West Europe as `10.20.0.0/16`; Standard static public IP on the jump NIC; no VMs in `GatewaySubnet`.
C. Two subscriptions in one VNet so the regions can share the address space.
D. One subnet `/29` for all VMs and a Standard public IP on the VNet resource.

---

**7.** Exhibit — subnet `10.0.1.0/24`. Which static private IP is **invalid**?

A. `10.0.1.10`
B. `10.0.1.4`
C. `10.0.1.1`
D. `10.0.1.200`

---

**8.** Exhibit — PowerShell:

```powershell
New-AzPublicIpAddress -Name 'pip-web' -ResourceGroupName 'rg-net' `
  -Location 'eastus' -Sku 'Basic' -AllocationMethod 'Dynamic'
```

A NIC in `snet-web` must keep the same **public** IP after a deallocate. What do you change?

A. Nothing; Basic dynamic public IPs never change.
B. `-Sku Standard` and `-AllocationMethod Static`, then associate that public IP to the NIC.
C. Set the VNet address prefix to Static.
D. Change only `-AllocationMethod Static` and keep Basic if you also need zone redundancy.

---

**9.** Select the **two** resources a **public IP** can be associated with in this module’s model.

A. The virtual network object itself
B. A NIC IP configuration
C. A load balancer frontend (same association idea)
D. The subscription
E. An Entra administrative unit

---

**10.** Exhibit — Bicep fragment:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-app'
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.0.0/16' ] }
    subnets: [
      { name: 'snet-web', properties: { addressPrefix: '10.0.1.0/24' } }
      { name: 'snet-web-2', properties: { addressPrefix: '10.0.1.128/25' } }
    ]
  }
}
```

What happens on deploy?

A. Succeeds; two subnets in the same /24 are legal if names differ.
B. Fails; `10.0.1.128/25` overlaps `10.0.1.0/24`.
C. Succeeds; Azure shrinks `snet-web` automatically.
D. Fails because Bicep cannot create more than one subnet.

---

## Submission — 2026-10-03

1. B, C
2. Yes, No, No, Yes
3. A (asked what RFC1918 is)
4. 5; idk; public; rg + region
5. 2 → 1 → 3 → 4
6. B
7. C
8. B
9. C, B
10. B

## Score: 6/10 (60%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — one NIC / one subnet; five reserved IPs. A VNet is one region; `/29` has 3 usable, not 8; peered VNets must **not** share space |
| 2 | **Wrong** | **No / Yes / No / Yes** — first two inverted. Standard public IP is **Static only**. Private IP is a **NIC** property from the subnet |
| 3 | **Wrong** | **B** — `10.1.0.0/24` is RFC1918 but **not inside** `10.0.0.0/16` (`10.0.0.0`–`10.0.255.255`). RFC1918 ≠ “fits this VNet” |
| 4 | **Wrong** | five; **Standard** + **Static**; NIC private IP **static**; one **region** + one **subscription**. You had 5 and region; “public” and “rg” are the wrong objects |
| 5 | **Wrong** | **1 → 3 → 2 → 4** — VNet/subnet first (the NIC has nowhere to sit). Public IP is its own resource. Then NIC with static `10.0.1.10`. Then associate. `2134` creates the NIC before the subnet exists |
| 6 | Correct | B — two non-overlapping VNet spaces for later peering; Standard static on the jump NIC; no VMs in `GatewaySubnet` |
| 7 | Correct | C — `.1` is the reserved default gateway |
| 8 | Correct | B — keep the public IP → Standard + Static, then associate |
| 9 | Correct | B, C — public IP associates to a NIC IP config or an LB frontend, not to the VNet or the subscription |
| 10 | Correct | B — `10.0.1.128/25` sits inside `10.0.1.0/24`; names do not make overlap legal |

Closed: reserved `.1`, Standard+Static for a sticky public IP, NIC/LB as the associate targets, subnet overlap on deploy.

Open: **RFC1918 vs VNet prefix**, **Standard cannot be Dynamic**, **private IP lives on the NIC**, **VNet = region + subscription**, **create subnet before the NIC**.
