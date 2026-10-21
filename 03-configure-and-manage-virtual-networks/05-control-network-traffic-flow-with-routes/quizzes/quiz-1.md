# Module 5 (Manage and control traffic flow with routes) — Quiz 1

Date issued: 2026-10-21
Scope: this module — system vs user-defined routes, route table association, longest prefix, UDR vs BGP vs system, NVA + IP forwarding, next hop types, `0.0.0.0/0`. Not Azure Firewall SKUs, Virtual WAN, or full BGP design.
Pass: **9/10**. Closed notes. Skim `../README.md` first.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. You associate a route table to the virtual machine resource.
B. You associate a route table to a **subnet** (zero or one table per subnet).
C. Azure picks a matching UDR before a longer prefix if the UDR is custom.
D. Azure uses **longest prefix match** first; if prefixes are equal, UDR beats BGP beats system.
E. You can set a UDR next hop type of **VNet peering**.

---

**2.** For each statement, answer **Yes** or **No**.

1. A subnet can have two route tables associated at the same time.
2. Default Azure routing lets subnets in the same VNet talk with no UDR.
3. An NVA should sit in the **same** subnet as the VMs whose `0.0.0.0/0` points at it.
4. IP forwarding for an NVA is an Azure NIC setting **and** a guest-OS setting.

---

**3.** Exhibit:

```bash
az network route-table create -g rg-net -n rt-web
az network route-table route create -g rg-net --route-table-name rt-web \
  -n to-nva --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.100.4
az network nic update -g rg-net -n nic-web --network-security-group nsg-web
```

The admin wanted **snet-web** to send internet-bound traffic to the NVA at `10.0.100.4`. What is missing?

A. `az network vnet subnet update ... --route-table rt-web` on **snet-web**.
B. `az network nic update ... --route-table rt-web` on the VM NIC.
C. `--next-hop-type VnetPeering` instead of VirtualAppliance.
D. Nothing; creating the table auto-associates it to every subnet in the RG.

---

**4.** Complete each blank.

1. Associate a route table to a ________, not a NIC or VM.
2. For the same prefix, Azure prefers UDR, then ________, then system.
3. Next hop type ________ means drop the packet.
4. NVA next hop type is Virtual appliance plus a next hop ________.

---

**5.** NVA VM does not exist yet. Textbook order so `snet-web` sends `0.0.0.0/0` through the NVA:

- Enable IP forwarding on the NVA NIC (Azure) and in the OS.
- Associate the route table to **snet-web** only (not the NVA subnet).
- Create the NVA in **snet-nva** and note its private IP.
- Create the route table and a UDR `0.0.0.0/0` → Virtual appliance → that IP.

---

**6.** Case study — lowest complexity that meets **all**:

- VMs in `snet-web` must send **all** internet-bound traffic through firewall VM `10.0.100.4`.
- Subnets in the same VNet must still talk using default VNet routing unless overridden.
- Do not associate anything to `GatewaySubnet`.
- Do not use ExpressRoute as the UDR next hop.

A. Route table on `snet-web`: `0.0.0.0/0` next hop **Internet**.
B. Route table on `snet-web`: `0.0.0.0/0` next hop **Virtual appliance** `10.0.100.4`; NVA in another subnet; IP forwarding on.
C. Route table on `GatewaySubnet`: `0.0.0.0/0` next hop Virtual appliance.
D. UDR next hop **Virtual network gateway** of type ExpressRoute.

---

**7.** A UDR for `10.90.0.0/16` has next hop type **None**. A VM sends a packet to `10.90.1.20`. What happens?

A. Azure NATs it to a public IP.
B. The packet is **dropped**.
C. Azure sends it to the internet default route.
D. Azure sends it over VNet peering automatically.

---

**8.** Exhibit:

```powershell
New-AzRouteTable -Name rt-web -ResourceGroupName rg-net -Location eastus
Get-AzVirtualNetwork -Name vnet-app -ResourceGroupName rg-net
# ... subnet config updated with -RouteTable $rt
```

The table is associated to `snet-web` but has **no routes**. Internet-bound traffic from that subnet goes where by default?

A. Nowhere; an empty table drops all traffic.
B. **Internet** (`0.0.0.0/0` system route) unless a more specific route matches.
C. The VPN gateway, because association implies forced tunneling.
D. The NVA at `10.0.100.4` even with no UDR.

---

**9.** Select the **two** true statements.

A. Disable BGP route propagation on a **workload** subnet’s table if that subnet must ignore on-prem BGP prefixes.
B. Disable BGP route propagation on **GatewaySubnet** so the VPN gateway learns fewer routes.
C. Service-endpoint system routes cannot be overridden by a UDR.
D. Longest prefix is ignored when a UDR exists anywhere in the table.
E. You associate route tables to public IP resources.

---

**10.** Exhibit — Bicep. Goal: `snet-web` sends `10.1.0.0/16` (peered spoke) through NVA `10.0.100.4`. Which `nextHopType` belongs in the UDR?

```bicep
resource rt 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-web'
  location: 'eastus'
  properties: {
    routes: [
      {
        name: 'to-spoke-via-nva'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: ???
          nextHopIpAddress: '10.0.100.4'
        }
      }
    ]
  }
}
```

A. `VnetPeering`
B. `VirtualAppliance`
C. `Internet`
D. `VirtualNetworkGateway`

---

## Submission — 2026-10-21

1. B, D
2. No, Yes, No, Yes
3. A
4. subnet; BGP; None; private IP
5. 3412
6. B
7. B
8. B
9. A, C
10. B

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — subnet association; longest prefix then UDR > BGP > system |
| 2 | Correct | No / Yes / No / Yes — one table per subnet; NVA **other** subnet; forwarding NIC+OS |
| 3 | Correct | A — `subnet update --route-table` |
| 4 | Correct | subnet; **BGP**; **None**; next hop **IP** (NVA private IP) |
| 5 | Correct | 3412 is legal (NVA IP exists before the UDR). Textbook 3142 puts forwarding before the UDR |
| 6 | Correct | B — `0.0.0.0/0` Virtual appliance, not GatewaySubnet |
| 7 | Correct | B — None = drop |
| 8 | Correct | B — empty table still has system `0.0.0.0/0` Internet |
| 9 | Correct | A, C — disable BGP on **workload** tables; service-endpoint routes cannot be overridden |
| 10 | Correct | B — `VirtualAppliance` (you cannot UDR next hop peering) |

