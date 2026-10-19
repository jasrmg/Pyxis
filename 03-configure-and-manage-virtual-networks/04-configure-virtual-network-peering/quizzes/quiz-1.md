# Module 4 (Configure Azure Virtual Network peering) — Quiz 1

Date issued: 2026-10-19
Scope: this module — peering both directions, non-overlapping CIDR, non-transitive hub-and-spoke, gateway transit, forwarded traffic / service chaining, backbone vs VPN. Not full UDR syntax, Azure Firewall SKUs, or Virtual WAN.
Pass: **9/10**. Closed notes. Skim `../README.md` first.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. VNet peering sends VNet-to-VNet packets over the public internet.
B. Traffic between peered VNets stays on the Microsoft backbone.
C. Creating a peering on `vnet-app` only is enough for VMs in both VNets to talk.
D. Both VNets must have a peering resource; status **Connected** on both sides.
E. Peering is transitive: A–B and B–C implies A can reach C.

---

**2.** For each statement, answer **Yes** or **No**.

1. Two VNets both using `10.0.0.0/16` can be peered if they are in different regions.
2. Same-region peering and global peering both use the Microsoft backbone.
3. A spoke VNet that **Use remote gateways** may also have its own VPN gateway.
4. Default AllowVNetInBound can allow traffic from a peered VNet when VNet access is enabled.

---

**3.** Exhibit. `vnet-app` is `10.1.0.0/16`. `vnet-hub` is `10.0.0.0/16`. An admin runs **only**:

```bash
az network vnet peering create -g rg-net -n app-to-hub \
  --vnet-name vnet-app --remote-vnet vnet-hub --allow-vnet-access
```

What is true?

A. Both VNets show peering status **Connected**; VMs can ping.
B. The `vnet-app` side is **Initiated** (or not fully up). The hub still needs its own peering.
C. The command fails because `--allow-gateway-transit` is required on every peering.
D. Azure automatically creates the reverse peering on `vnet-hub`.

---

**4.** Complete each blank.

1. Peered VNets must have ________ address spaces.
2. Until both peerings are ________, the link is not usable.
3. On the **hub** (the VNet that **has** the VPN/ER gateway), enable ________ ________ ________.
4. On the **spoke**, enable ________ ________ ________, and do **not** deploy a local gateway.

---

**5.** You need `vnet-app` (`10.1.0.0/16`) to talk to `vnet-hub` (`10.0.0.0/16`). Nothing exists yet. Textbook order:

- Create the peering on `vnet-hub` toward `vnet-app`.
- Confirm both peerings show **Connected**.
- Create `vnet-hub` and `vnet-app` with non-overlapping prefixes.
- Create the peering on `vnet-app` toward `vnet-hub`.

---

**6.** Case study — lowest cost that meets **all**:

- Three spoke VNets must reach **on-premises** through Azure.
- Spokes must reach VMs in the hub VNet on private IPs.
- Do not deploy a VPN gateway in every spoke.
- VNet-to-VNet traffic must not go via the internet.

A. Peer each spoke to the hub; hub peering **Allow gateway transit**; each spoke **Use remote gateways**; one VPN gateway in the hub.
B. Deploy a VPN gateway in the hub and in every spoke; skip peering.
C. Peer spoke-A to spoke-B only; expect spoke-C to reach on-prem through transitivity.
D. Global-peer every spoke to a Basic internal load balancer in another region instead of a gateway.

---

**7.** `vnet-a` is peered (**Connected**) to `vnet-hub`. `vnet-b` is peered (**Connected**) to `vnet-hub`. No UDRs, no extra peerings. A VM in `vnet-a` sends packets to a VM in `vnet-b`. What happens?

A. It works; hub peering is transitive.
B. It fails; peering is **not** transitive. Need spoke-to-spoke peering or UDR + NVA (and forwarded traffic).
C. Azure converts it to a VPN gateway hop automatically.
D. It works only if both spokes are in the same resource group.

---

**8.** Exhibit. Goal: both VNets **Connected**.

```powershell
$vnetApp = Get-AzVirtualNetwork -Name vnet-app -ResourceGroupName rg-net
$vnetHub = Get-AzVirtualNetwork -Name vnet-hub -ResourceGroupName rg-net
Add-AzVirtualNetworkPeering -Name app-to-hub -VirtualNetwork $vnetApp `
  -RemoteVirtualNetworkId $vnetHub.Id
```

What is still missing?

A. `New-AzVpnGateway` on `vnet-app` (required for any peering).
B. The reciprocal `Add-AzVirtualNetworkPeering` on `$vnetHub` toward `$vnetApp.Id`.
C. `--use-remote-gateways` on both sides.
D. Overlapping the two address spaces so they share `10.0.0.0/16`.

---

**9.** Select the **two** true statements about forwarded traffic and service chaining.

A. **Allow forwarded traffic** by itself creates the UDR and the NVA.
B. An NVA in the hub plus UDRs on spokes can send spoke-to-spoke (or outbound) traffic through that NVA.
C. The peering checkbox **Allow forwarded traffic** must be on for those forwarded packets to be accepted.
D. Next hop type ExpressRoute gateway is how you UDR between two peered VNets.
E. Service chaining requires the two VNets to overlap on `10.0.0.0/8`.

---

**10.** Exhibit — Bicep. Hub already has a VPN gateway. Which property pair is the **spoke** side?

```bicep
resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: vnetSpoke
  name: 'spoke-to-hub'
  properties: {
    remoteVirtualNetwork: { id: vnetHub.id }
    allowVirtualNetworkAccess: true
    allowGatewayTransit: ???
    useRemoteGateways: ???
  }
}
```

A. `allowGatewayTransit: true`, `useRemoteGateways: false`
B. `allowGatewayTransit: false`, `useRemoteGateways: true`
C. `allowGatewayTransit: true`, `useRemoteGateways: true`
D. `allowGatewayTransit: false`, `useRemoteGateways: false`

---

## Submission — 2026-10-19

1. B, D
2. No, Yes, No, Yes
3. B
4. non conflicting; Connected; allow vnet access + forwarded + gateway transit; Use remote gateways (other two unknown)
5. 3142 or 3412
6. A
7. B
8. B
9. B, C
10. C

## Score: 8/10 (80%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — backbone; both sides **Connected** |
| 2 | Correct | No / Yes / No / Yes — overlap still fails across regions; spoke cannot have a local gateway if it uses remote |
| 3 | Correct | B — one `peering create` = not fully up |
| 4 | **Wrong** | **non-overlapping**; **Connected**; hub = **Allow gateway transit**; spoke = **Use remote gateways**. Access/forwarded are other checkboxes, not this blank |
| 5 | Correct | 3142 and 3412 both legal (VNets first; either peering order; then Connected) |
| 6 | Correct | A — one hub gateway + transit / remote |
| 7 | Correct | B — not transitive |
| 8 | Correct | B — reciprocal peering |
| 9 | Correct | B, C — UDR+NVA plus **Allow forwarded traffic**. The checkbox does not create the route |
| 10 | **Wrong** | **B** — spoke is `allowGatewayTransit: false`, `useRemoteGateways: true`. Both true (C) is illegal (one gateway per VNet) |

Closed: backbone, both sides, overlap-across-regions, non-transitive, forwarded traffic + NVA, case study hub gateway.

Open: hub vs spoke **gateway** flags (transit vs remote). Do not stack both `true` on the spoke. Exam word is **non-overlapping**, not “non-conflicting.”

