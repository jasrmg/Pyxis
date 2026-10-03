# Module 1 — Configure virtual networks

Learn module: [Configure virtual networks](https://learn.microsoft.com/en-us/training/modules/configure-virtual-networks/) (11 units)

**Aim:** VNet features, subnets, public vs private IP, create a VNet and assign addresses.

NSGs, peering, DNS zones, UDRs, and load balancers are **later modules**. This one is address space and IP association.

---

## What a VNet is

An Azure **virtual network** is a private RFC1918 (or your custom) address space in **one region**, in **one subscription**. VMs, NICs, private endpoints, and several PaaS NICs live **inside a subnet of that VNet**.

- A VNet does **not** span regions. Need two regions → two VNets (peering or a gateway is a later module).
- Address space is CIDR, e.g. `10.0.0.0/16`. You can add more prefixes later if they do not overlap existing subnets.
- If you will **peer** later, the two VNets' address spaces **must not overlap**. Plan that now.

---

## Subnets

Carve the VNet into subnets. A NIC sits in **exactly one** subnet.

| Rule | Exam wording |
| --- | --- |
| Subnets **cannot overlap** | `10.0.1.0/24` and `10.0.1.128/25` overlap — create fails |
| Subnet must fit **inside** the VNet space | `10.1.0.0/24` is illegal in a `10.0.0.0/16` VNet |
| Azure **reserves 5 IPs** in every IPv4 subnet | You cannot use them |

Reserved in each subnet (example `10.0.1.0/24`):

| Address | Why |
| --- | --- |
| `.0` | Network address |
| `.1` | Default gateway |
| `.2` and `.3` | Azure DNS mapping |
| `.255` | Broadcast (for this size) |

Usable hosts in a `/24` = **251**, not 254. A `/29` (8 addresses) has only **3** usable — too small for most workloads.

**Named system subnets** (create them empty, exact name):

- `GatewaySubnet` — VPN / ExpressRoute gateway (size at least `/27` in real designs)
- `AzureBastionSubnet` — Bastion (`/26` minimum)
- `AzureFirewallSubnet` — Azure Firewall (`/26` minimum)

You do not put VMs in those.

---

## Private IP vs public IP

| | **Private IP** | **Public IP** |
| --- | --- | --- |
| Where it lives | On the **NIC** (or ILB frontend), from the **subnet** range | Separate **resource**, then **associated** (NIC, LB, VPN gateway, NAT gateway, App Gateway) |
| Default | Every NIC gets one | Optional |
| Allocation | **Dynamic** (Azure picks from the subnet) or **Static** (you pick a free usable address in that subnet) | **Standard SKU: Static only**. Basic SKU (retiring): dynamic or static |
| Internet inbound | No (unless you also have a public IP / NAT / LB) | Yes, if NSG/firewall allow (Standard public IP is closed until you allow) |

**Static private IP** is how a VM keeps `10.0.1.10` across stop/start. Dynamic private IPs can change if the VM is stopped (deallocated) long enough — exam still treats “must not change” as **static**.

You **cannot** pick a reserved address (`.0`–`.3`, broadcast) as a static private IP.

A VM can have multiple NICs; each NIC one primary private IP (plus secondary IPs). Public IP associates to a **specific IP config** on the NIC, not to the VM object itself.

---

## Public IP SKU (this module’s trap)

| | **Basic** (legacy) | **Standard** |
| --- | --- | --- |
| Allocation | Dynamic or static | **Static only** |
| Default security | Open | **Closed** — need NSG (or similar) for inbound |
| Zone | No zone-redundancy | Zone-redundant / zonal |

New work: **Standard + Static**. If an exhibit shows `--sku Basic --allocation-method Dynamic`, that is the old pattern.

---

## Create (exam stack)

```bash
az network vnet create \
  --resource-group rg-net --name vnet-app --location eastus \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name snet-web --subnet-prefixes 10.0.1.0/24

az network vnet subnet create \
  --resource-group rg-net --vnet-name vnet-app \
  --name snet-data --address-prefixes 10.0.2.0/24

az network public-ip create \
  --resource-group rg-net --name pip-web \
  --sku Standard --allocation-method Static --location eastus
```

```powershell
New-AzVirtualNetwork -Name vnet-app -ResourceGroupName rg-net -Location eastus -AddressPrefix '10.0.0.0/16'
# then Add-AzVirtualNetworkSubnetConfig + Set-AzVirtualNetwork
New-AzPublicIpAddress -Name pip-web -ResourceGroupName rg-net -Location eastus -Sku Standard -AllocationMethod Static
```

Bicep (`Microsoft.Network/virtualNetworks`) — address space on the VNet, subnets as a property array. Public IP is `Microsoft.Network/publicIPAddresses`.

---

## Enterprise scenarios

### 1. “Give me a /29 for the web subnet”

Too small after Azure’s five reserved addresses. Use `/24` or at least `/27` unless you have a documented tiny appliance subnet.

### 2. Two VNets both `10.0.0.0/16` because “it is private”

Peering will fail. Change one space **before** you fill it with subnets and VMs.

### 3. App needs a fixed private IP for a firewall allow-list

Set the NIC’s private IP to **Static** and pick a usable address in the subnet. Do not rely on Dynamic. A public IP is a different requirement (internet).

### 4. “The VM has no public IP but I can RDP from home”

Then something else is publishing it (bastion, DNAT, Jump box). A NIC’s **private** IP is not reachable from the internet.

---

## Exam traps from this module

1. VNet = **one region**. Address spaces that will peer **must not overlap**.
2. Azure reserves **5 IPs per subnet**.
3. Subnets cannot overlap and must sit inside the VNet CIDR.
4. Private IP is on the **NIC**; public IP is a **resource you associate**.
5. “Must not change on stop/start” → **static** private (or Standard static public).
6. New public IPs: **Standard + Static**.
7. `GatewaySubnet` / `AzureBastionSubnet` / `AzureFirewallSubnet` are reserved names and sizes — no app VMs there.
8. NSG/peering/DNS zones are **not** this module’s verbs.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/01-configure-virtual-networks/poc
./vnet.sh            # prints the plan (no deploy)
APPLY=1 ./vnet.sh    # creates VNet + subnet + Standard public IP, then deletes
```
