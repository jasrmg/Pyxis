# Module 5 — Manage and control traffic flow with routes

Learn module: [Manage and control traffic flow in your Azure deployment with routes](https://learn.microsoft.com/en-us/training/modules/control-network-traffic-flow-with-routes/) (7 units)

**Aim:** system routes vs user-defined routes (UDRs), associate a route table to a **subnet**, send traffic through an NVA.

This is **where packets go next**. It is not an NSG (filter), not peering (connectivity), not a load balancer. Skills measured **4.1**.

---

## What Azure already does

Every subnet gets **system routes**. You cannot create or delete them. You **override** some with custom routes.

Default system routes (every subnet):

| Prefix | Next hop | Meaning |
| --- | --- | --- |
| This VNet’s address space | **Virtual network** | Subnets talk with no table and no gateway |
| `0.0.0.0/0` | **Internet** | Anything else goes out (Azure service public IPs still stay on the backbone) |
| RFC1918 / other reserved not in *this* VNet | **None** | Drop |

Optional system routes (only if you turn the feature on):

| When | Next hop |
| --- | --- |
| VNet peering **Connected** | **VNet peering** (remote prefixes) |
| VPN/ER gateway + BGP | **Virtual network gateway** (on-prem prefixes) |
| Service endpoint on **that** subnet | **VirtualNetworkServiceEndpoint** |

You **cannot** write a UDR whose next hop is VNet peering or service endpoint. Azure owns those.

---

## Route table and UDRs

A **route table** holds **user-defined routes**. You **associate** it to a **subnet**.

| Rule | Exam wording |
| --- | --- |
| Association | **Subnet** only — not NIC, not VM, not the VNet object |
| How many tables per subnet | **Zero or one** |
| Same table | May attach to **many** subnets |

Each UDR: **address prefix** + **next hop type** (+ next hop **IP** when the type is Virtual appliance).

UDR next hop types you can set:

| Type (portal) | CLI / ARM | Extra |
| --- | --- | --- |
| Virtual appliance | `VirtualAppliance` | **Next hop IP** = NVA private IP (or ILB in front of NVAs) |
| Virtual network gateway | `VirtualNetworkGateway` | VPN gateway in **this** VNet (not ExpressRoute as the UDR next hop) |
| None | `None` | **Drop** the packet |
| Virtual network | `VNetLocal` | Stay in the VNet |
| Internet | `Internet` | Out to internet |

---

## How Azure picks a route (effective routes)

Outbound from a subnet, Azure looks at **destination IP**.

1. **Longest prefix match** wins first (`10.0.1.0/24` beats `10.0.0.0/16` for `10.0.1.5`).
2. If the prefix is **the same**, source order: **UDR > BGP > system**.

Exceptions you will see on the exam:

- Routes for **VNet / peering / service endpoint** stay preferred even if BGP is more specific. Service-endpoint routes **cannot** be overridden by a table.
- View the result on the **NIC**: **effective routes**.

---

## NVA (network virtual appliance)

An NVA is a VM (firewall/router) that **forwards** other people’s packets.

To send subnet traffic through it:

1. Put the NVA in **its own subnet**. Same subnet as the clients + a UDR pointing at the NVA = **routing loop**.
2. Enable **IP forwarding** on the NVA **NIC** (Azure setting) **and** in the guest OS.
3. Route table on the **workload** subnet: prefix (often `0.0.0.0/0` or the other subnet) → next hop **Virtual appliance** → NVA private IP.
4. If that traffic crossed a **peering**, **Allow forwarded traffic** must be on (module 4). The checkbox is not the UDR.

`0.0.0.0/0` → Virtual appliance = “everything not more-specific goes to the NVA” (forced inspect / forced tunnel). Side effects: no direct internet inbound to that subnet; Azure public PaaS without a service endpoint also goes to the NVA.

Do **not** associate a `0.0.0.0/0` table to **`GatewaySubnet`**. Do **not** disable BGP propagation on `GatewaySubnet`.

---

## BGP route propagation

On a route table: **Virtual network gateway route propagation** (on by default). Turn it **off** on a subnet that must **ignore** on-prem BGP prefixes (and use your UDRs instead). That is a property of the **table**, then associate the table.

---

## Create (exam stack)

```bash
az network route-table create -g rg-net -n rt-app
az network route-table route create -g rg-net --route-table-name rt-app \
  -n to-nva --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.100.4

az network vnet subnet update -g rg-net --vnet-name vnet-app -n snet-web \
  --route-table rt-app

az network nic update -g rg-net -n nic-nva --ip-forwarding true
```

```powershell
New-AzRouteTable -Name rt-app -ResourceGroupName rg-net -Location eastus
Add-AzRouteConfig -Name to-nva -AddressPrefix 0.0.0.0/0 `
  -NextHopType VirtualAppliance -NextHopIpAddress 10.0.100.4
Set-AzVirtualNetworkSubnetConfig ... -RouteTable $rt
```

Bicep: `Microsoft.Network/routeTables` plus `routes[]`; associate with the subnet’s `routeTable.id`. NIC: `enableIPForwarding: true`.

| Flag | Meaning |
| --- | --- |
| `--route-table-name` / `-n` on `route-table create` | The table |
| `--address-prefix` | Destination match (CIDR or a **service tag**) |
| `--next-hop-type` | `VirtualAppliance`, `VirtualNetworkGateway`, `None`, `VnetLocal`, `Internet` |
| `--next-hop-ip-address` | Required for Virtual appliance |
| `--route-table` on `subnet update` | Associate (subnet only) |
| `--disable-bgp-route-propagation` | Table ignores gateway BGP |
| `--ip-forwarding true` | Azure NIC of the NVA |

---

## Enterprise scenarios

### 1. “Peering is Connected, spoke still cannot reach spoke”

Not a route-table bug until you check **effective routes**. Either add spoke-spoke peering or UDR → hub NVA **and** forwarded traffic.

### 2. “UDR 0.0.0.0/0 to the NVA, NVA is in snet-web with the app VMs”

Loop. NVA in `snet-nva`; table on `snet-web` only.

### 3. “I associated the route table to the VM”

Illegal. Subnet. Effective routes are **read** on the NIC.

### 4. “Disable BGP propagation on GatewaySubnet so on-prem routes disappear”

Gateway breaks. Disable it on **workload** subnets if they must not learn BGP.

---

## Exam traps from this module

1. Table → **subnet**. One table per subnet; one table, many subnets.
2. Longest prefix **first**. Same prefix: **UDR > BGP > system**.
3. Virtual appliance needs a **next hop IP**. IP forwarding on **NIC + OS**. NVA **other** subnet.
4. Next hop **None** = drop. You cannot UDR to “peering.”
5. `0.0.0.0/0` to NVA overrides default Internet. Not on `GatewaySubnet`.
6. Peering **Allow forwarded traffic** ≠ creating the UDR.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/05-control-network-traffic-flow-with-routes/poc
./routes.sh            # prints the plan (no deploy)
APPLY=1 ./routes.sh    # table + 0.0.0.0/0 to dummy NVA IP + subnet associate, then deletes
```
