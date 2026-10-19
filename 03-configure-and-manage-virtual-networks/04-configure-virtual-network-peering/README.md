# Module 4 — Configure Azure Virtual Network peering

Learn module: [Configure Azure Virtual Network peering](https://learn.microsoft.com/en-us/training/modules/configure-vnet-peering/) (8 units)

**Aim:** peer two VNets, both directions **Connected**, gateway transit, hub-and-spoke with forwarded traffic / service chaining.

This is **VNet-to-VNet over the Microsoft backbone**. It is not a VPN gateway, not the internet, not Azure Virtual WAN as a product, not UDRs as the whole routing story (next module). Skills measured **4.1**.

---

## What peering is

A **peering** links two VNets so they look like one for **private IP** connectivity. Traffic stays on Microsoft’s backbone. No public internet. No hop through a VPN gateway for that VNet-to-VNet path.

| Kind | Where the two VNets live |
| --- | --- |
| Virtual network peering | Same Azure region |
| Global virtual network peering | Different regions |

Same knobs. Global has extra traps (Basic load-balancer frontends are not reachable across global peering).

You can peer across **subscriptions** and **Entra tenants** if you have rights (or you paste the remote VNet **resource ID**).

**Address spaces must not overlap.** Module 1 containment: if any address is in both prefixes, peering fails. Plan CIDR before you peer.

---

## Both sides, or it is not up

Peering is **two resources**, one on each VNet.

| Status you see | Meaning |
| --- | --- |
| Initiated | You created only one side |
| Connected | Both sides exist and agree |

Until **both** show **Connected**, VMs do not talk. Creating the link on `vnet-app` only is not “half working.” Exam loves a single `az network vnet peering create`.

Default **Allow virtual network access** = on. That is the checkbox that actually lets VMs use the peering. The `VirtualNetwork` NSG service tag then includes the **peered** VNet too.

---

## Non-transitive (hub-and-spoke)

`A` peered to `B`, `B` peered to `C` does **not** make `A` talk to `C`.

Spokes peer to the **hub**. Spoke-to-spoke needs **another** peering, or **UDRs** that send traffic to an NVA/firewall in the hub (**service chaining**). Peering alone is not a router.

---

## The four checkboxes (learn these names)

Portal creates **two** peerings in one wizard (local + remote). CLI/PowerShell: you still emit **two** peering objects.

| Setting | CLI flag | Typical hub | Typical spoke |
| --- | --- | --- | --- |
| Allow virtual network access | `--allow-vnet-access` | On | On |
| Allow forwarded traffic | `--allow-forwarded-traffic` | On if NVA/UDR | On if NVA/UDR |
| Allow gateway transit | `--allow-gateway-transit` | **On** (this VNet **has** the VPN/ER gateway) | Off |
| Use remote gateways | `--use-remote-gateways` | Off | **On** (use the hub’s gateway) |

**Forwarded traffic** does **not** create UDRs or an NVA. It only **permits** packets that an NVA already forwarded. You still write the UDR (next module’s verb, this module’s exam pairing).

**Gateway transit** (spokes reach on-prem through **one** hub gateway):

1. Hub has a VPN or ExpressRoute gateway in `GatewaySubnet` (not **Basic** VPN SKU).
2. Hub → spoke peering: **Allow gateway transit**.
3. Spoke → hub peering: **Use remote gateways**.
4. The spoke **must not** have its own gateway. One gateway per VNet: local **or** remote, not both.
5. A spoke can **Use remote gateways** on **only one** peering.

---

## NSG, DNS, routes still exist

Peering is **connectivity**. It does not punch holes.

- **NSG:** still evaluated (subnet then NIC inbound). Default **AllowVNetInBound** includes peered VNets when VNet access is allowed. A custom Deny still blocks.
- **DNS:** names do not magically resolve across VNets. Private DNS **VNet links** (module 3) or your own DNS.
- **Effective routes** on a NIC: next hop type **VNet peering** for the remote address space. If that route is missing, peering is not **Connected**.

---

## Resize after peering

You can add/change a peered VNet’s address space without tearing the peering down. Then **sync** the peer (portal or PowerShell). Do not leave peers stale after a CIDR change.

---

## Create (exam stack)

```bash
# Two VNets, non-overlapping, then BOTH peerings
az network vnet peering create -g rg-net -n app-to-hub \
  --vnet-name vnet-app --remote-vnet vnet-hub --allow-vnet-access

az network vnet peering create -g rg-net -n hub-to-app \
  --vnet-name vnet-hub --remote-vnet vnet-app --allow-vnet-access

# Hub-and-spoke + on-prem through hub gateway
az network vnet peering create -g rg-net -n hub-to-spoke \
  --vnet-name vnet-hub --remote-vnet vnet-spoke \
  --allow-vnet-access --allow-gateway-transit --allow-forwarded-traffic

az network vnet peering create -g rg-net -n spoke-to-hub \
  --vnet-name vnet-spoke --remote-vnet vnet-hub \
  --allow-vnet-access --use-remote-gateways --allow-forwarded-traffic
```

```powershell
Add-AzVirtualNetworkPeering -Name app-to-hub -VirtualNetwork $vnetApp `
  -RemoteVirtualNetworkId $vnetHub.Id
Add-AzVirtualNetworkPeering -Name hub-to-app -VirtualNetwork $vnetHub `
  -RemoteVirtualNetworkId $vnetApp.Id
```

Bicep child: `Microsoft.Network/virtualNetworks/virtualNetworkPeerings`. Properties: `allowVirtualNetworkAccess`, `allowForwardedTraffic`, `allowGatewayTransit`, `useRemoteGateways`, `remoteVirtualNetwork.id`. You still need the **reciprocal** peering on the other VNet.

| Flag | Meaning |
| --- | --- |
| `--vnet-name` | Local VNet (this side’s peering resource lives here) |
| `--remote-vnet` | Other VNet name or resource ID |
| `--allow-vnet-access` | VMs may use the peering |
| `--allow-forwarded-traffic` | Accept NVA/UDR-forwarded packets |
| `--allow-gateway-transit` | **This** VNet’s gateway may be used by the peer |
| `--use-remote-gateways` | **This** VNet uses the **peer’s** gateway |

---

## Enterprise scenarios

### 1. “I peered vnet-app to vnet-hub, VMs still cannot ping”

Second peering missing (status **Initiated**). Or overlapping CIDR (create failed). Or NSG deny. Or you expected spoke-to-spoke through the hub with no UDR.

### 2. “Put a VPN gateway in every spoke so they reach on-prem”

Works, burns money. Lowest cost: **one** hub gateway + **Allow gateway transit** / **Use remote gateways**.

### 3. “Peering is a VPN, so it is slower than in-VNet”

Same-region VM-to-VM latency is in-VNet class. Bandwidth is the **VM size**, not a gateway SKU.

### 4. “Global peer so spoke VMs hit a Basic internal load balancer in the other region”

Illegal for **Basic** LB frontends over **global** peering. Standard SKU, or keep them in one region.

---

## Exam traps from this module

1. **Non-overlapping** CIDR or peering will not create.
2. **Two** peerings. One side = **Initiated**, not done.
3. **Not transitive.** Spoke-to-spoke is not free.
4. Backbone, not internet. Not a VPN hop for VNet-to-VNet.
5. Hub: **Allow gateway transit**. Spoke: **Use remote gateways**. Spoke has **no** local gateway.
6. **Allow forwarded traffic** + UDR next hop = NVA. The checkbox is not the route.
7. NSG still applies. `VirtualNetwork` includes the peer when access is allowed.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/04-configure-virtual-network-peering/poc
./peering.sh            # prints the plan (no deploy)
APPLY=1 ./peering.sh    # two VNets + both peerings, then deletes
```
