# Module 1 (Configure virtual networks) — Quiz 2

Date issued: 2026-10-04
Scope: this module only — VNets, subnets, CIDR containment, reserved IPs, public vs private IP, Standard vs Basic public IP. Not NSG, peering how-to, DNS zones, or load-balancer SKUs.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A NIC can be attached to two subnets in the same VNet.
B. A private IP is assigned from the subnet range onto the NIC IP configuration.
C. A Standard public IP can use allocation method Dynamic.
D. Two VNets that will be peered should use identical address space.
E. Azure reserves five IPv4 addresses in every subnet.

---

**2.** For each statement, answer **Yes** or **No**.

1. Subnet `10.8.3.0/24` fits inside VNet `10.8.0.0/22`.
2. A Standard public IP can be created with allocation method Dynamic.
3. You associate a public IP to the virtual network resource itself.
4. `AzureBastionSubnet` is a valid place for the application jump VM.

---

**3.** Exhibit:

```bash
az network vnet create \
  --resource-group rg-net --name vnet-app --location westus \
  --address-prefixes 192.168.0.0/23 \
  --subnet-name snet-web --subnet-prefixes 192.168.2.0/24
```

What happens?

A. Succeeds; both prefixes are RFC1918 so the subnet is legal.
B. Fails; `192.168.2.0/24` is not inside `192.168.0.0/23`.
C. Succeeds and silently expands the VNet to `192.168.0.0/16`.
D. Fails because a `/23` VNet is not allowed in Azure.

---

**4.** Complete each blank.

1. Azure reserves ________ IPv4 addresses per subnet.
2. New public IP SKU should be ________ with allocation ________.
3. Private IP that must survive deallocate → set the ________ to ________.
4. A VNet lives in one ________ and one ________.

---

**5.** Put these in an order that never creates a NIC before its subnet.

- Associate the public IP with the NIC’s IP configuration.
- Create the virtual network and `snet-web` (`10.4.80.0/24`).
- Create the NIC (or VM) in `snet-web` and set private IP static `10.4.80.10`.
- Create a public IP resource, SKU Standard, allocation Static.

---

**6.** Case study — Fabrikam. Lowest-complexity design that meets **all**:

- Web and data VMs in two subnets; they must talk on the private network.
- A second region will be added later; the two VNets must be peerable.
- Jump host public IP must not change after deallocate.
- Do not place VMs in `GatewaySubnet` or `AzureBastionSubnet`.

A. One VNet `10.0.0.0/16` East US; West Europe will reuse `10.0.0.0/16`; Basic dynamic public IP on the jump host.
B. VNet `10.10.0.0/16` East US with two `/24` subnets; plan West Europe as `10.20.0.0/16`; Standard static public IP on the jump NIC; app VMs only in the `/24`s.
C. One VNet spanning East US and West Europe so both regions share `10.10.0.0/16`.
D. One `/29` subnet for every VM and a Standard public IP on the VNet object.

---

**7.** Exhibit — subnet `10.20.1.0/24`. Which static private IP is **invalid**?

A. `10.20.1.10`
B. `10.20.1.4`
C. `10.20.1.3`
D. `10.20.1.50`

---

**8.** Exhibit:

```bash
az network public-ip create \
  --resource-group rg-net --name pip-web \
  --sku Standard --allocation-method Dynamic --location eastus
```

What happens, and what do you change if the NIC must keep the same public IP after deallocate?

A. Succeeds; Dynamic Standard public IPs never change, so leave it.
B. Fails (or is rejected); Standard requires Static. Create it as Standard + Static, then associate it to the NIC.
C. Succeeds; set the VNet prefix to Static instead.
D. Change only the SKU to Basic and keep Dynamic so the address can be zone-redundant.

---

**9.** Select the **two** true statements about IP association in this module.

A. A public IP associates to a NIC IP configuration (or an LB frontend), not to the VNet object.
B. A private IP is a separate `Microsoft.Network/publicIPAddresses` resource.
C. Every NIC must have a public IP before the VM can start.
D. A private IP is taken from the subnet and lives on the NIC (IP config).
E. Associating a public IP moves the NIC into a second subnet.

---

**10.** Exhibit — ARM fragment:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2023-11-01",
  "name": "vnet-app",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": { "addressPrefixes": [ "10.8.0.0/22" ] },
    "subnets": [
      { "name": "snet-a", "properties": { "addressPrefix": "10.8.3.0/24" } },
      { "name": "snet-b", "properties": { "addressPrefix": "10.8.4.0/24" } }
    ]
  }
}
```

What happens on deploy?

A. Succeeds; `10.8.4.0/24` is RFC1918 so it may sit beside the VNet.
B. Fails; `10.8.4.0/24` is not inside `10.8.0.0/22`.
C. Succeeds; Azure adds `10.8.4.0/22` to the VNet address space.
D. Fails because ARM cannot declare two subnets in one resource.

---

## Submission — 2026-10-04

1. B, A
2. Yes (range written as `10.8.0.0`–`10.11.255.255`); No; No; No
3. B (`192.168.0.0`–`192.168.1.255`)
4. 5; Basic, Dynamic; ip, dynamic; subscription, region
5. 2 → 3 → 4 → 1
6. B
7. C
8. B
9. A, B
10. B

## Score: 7/10 (70%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | **Wrong** | **B, E** — private IP is on the NIC from the subnet; five reserved. A NIC is **one** subnet. You had B and picked A instead of E |
| 2 | Correct | Yes / No / No / Yes is not the set — **Yes / No / No / No**. `10.8.3.0/24` does fit. **Range you wrote is wrong:** `/22` is 3rd octet, 6 painted 2 empty, block 4 → `10.8.0.0`–`10.8.3.255`, not `10.8.0.0`–`10.11.255.255` |
| 3 | Correct | B — `/23` is `192.168.0.0`–`192.168.1.255` |
| 4 | **Wrong** | five; **Standard + Static**; **NIC** to **static**; region + subscription. You still wrote the legacy public IP and Dynamic for the sticky private IP |
| 5 | Correct | `2341` is VNet → NIC → public IP → associate. Legal |
| 6 | Correct | B — two non-overlapping VNet spaces; Standard static on the jump NIC; no app VMs in system subnets |
| 7 | Correct | C — `.3` is reserved (Azure DNS mapping) |
| 8 | Correct | B — Standard cannot be Dynamic |
| 9 | **Wrong** | **A, D** — public IP associates to NIC/LB; private IP is on the NIC from the subnet. B names `publicIPAddresses` — that is the **public** IP resource, not the private IP |
| 10 | Correct | B — `10.8.0.0/22` ends at `10.8.3.255`; `10.8.4.0/24` is the next block |

Closed: `/23` containment, create order, reserved `.3`, Standard rejects Dynamic, case-study address spaces.

Open: **public vs private object** (Q4, Q9), **five reserved** as a fact (Q1), **`/22` block sits in octet 3** (Q2 range).
