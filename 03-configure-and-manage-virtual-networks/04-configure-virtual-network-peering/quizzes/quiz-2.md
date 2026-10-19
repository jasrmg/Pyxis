# Module 4 (Configure Azure Virtual Network peering) — Quiz 2

Date issued: 2026-10-19
Scope: this module — both-sides Connected, non-overlapping CIDR, non-transitive, **which peering object** gets Allow gateway transit vs Use remote gateways, forwarded traffic, global/Basic LB. Not full UDR labs or Virtual WAN.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. `--allow-gateway-transit` is set on the **spoke** peering so the spoke can share a gateway it does not have.
B. `--allow-gateway-transit` is set on the **hub** peering (the VNet that **has** the VPN/ER gateway).
C. `--use-remote-gateways` is set on the **spoke** peering; that spoke must **not** have its own gateway.
D. You enable **both** `allowGatewayTransit` and `useRemoteGateways` on the spoke peering.
E. Peering A–B and B–C is enough for A to reach C.

---

**2.** For each statement, answer **Yes** or **No**.

1. A VM in East US can reach a **Basic** load-balancer frontend in West US over **global** peering.
2. After you add a prefix to a peered VNet, you should **sync** the peer.
3. A spoke may **Use remote gateways** on two hub peerings at the same time.
4. **Allow forwarded traffic** by itself creates the UDR and the NVA.

---

**3.** Exhibit. `vnet-hub` **has** the VPN gateway. This command is meant to be the **hub → spoke** peering. The spoke peering already exists with `--use-remote-gateways`.

```bash
az network vnet peering create -g rg-net -n hub-to-spoke \
  --vnet-name vnet-hub --remote-vnet vnet-spoke \
  --allow-vnet-access --use-remote-gateways
```

What is true?

A. Correct; the hub uses remote gateways so spokes can reach on-prem.
B. Wrong flag on this object: hub needs `--allow-gateway-transit`, not `--use-remote-gateways`.
C. Fails because `--allow-vnet-access` is illegal on a hub.
D. Succeeds and automatically deletes the spoke’s `--use-remote-gateways`.

---

**4.** Complete each blank.

1. Peered VNets must have ________ address spaces.
2. Both peering resources must show status ________.
3. Hub peering (VNet **with** the gateway): ________ ________ ________.
4. Spoke peering (no local gateway): ________ ________ ________.

---

**5.** Hub already exists with a VPN gateway. Spoke VNet exists, **no** gateway, non-overlapping CIDR. Textbook remaining order so spokes use the hub gateway:

- On the spoke → hub peering, enable **Use remote gateways**.
- Create both peerings (**Connected**).
- Confirm a spoke VM’s effective routes include on-prem prefixes via the hub.
- On the hub → spoke peering, enable **Allow gateway transit**.

---

**6.** Case study — lowest complexity that meets **all**:

- Spoke `vnet-app` already has its **own** VPN gateway.
- You now want `vnet-app` to use the **hub** gateway for on-prem (one shared gateway).
- Hub and spoke CIDRs do not overlap.
- Keep private VM-to-VM over peering.

A. On the spoke peering set `allowGatewayTransit` and `useRemoteGateways` both `true`; leave the spoke gateway.
B. Remove the gateway from `vnet-app`, then hub **Allow gateway transit** and spoke **Use remote gateways**.
C. Overlap both VNets on `10.0.0.0/16` so transit is implied.
D. Delete peering; build a site-to-site VPN from spoke to hub instead of using the hub gateway.

---

**7.** Peering is **Connected**. A subnet NSG on the hub **Denies** inbound from the spoke prefix. What happens to spoke → hub VM traffic?

A. Peering bypasses NSGs; the packet is allowed.
B. The NSG still filters; inbound is denied before the hub VM.
C. Only the spoke NSG is evaluated for inbound to the hub.
D. Azure converts the flow to a public IP so DenyVNet does not apply.

---

**8.** Exhibit. Hub has the gateway. Goal: spoke uses that gateway.

```powershell
Add-AzVirtualNetworkPeering -Name hub-to-spoke -VirtualNetwork $vnetHub `
  -RemoteVirtualNetworkId $vnetSpoke.Id -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name spoke-to-hub -VirtualNetwork $vnetSpoke `
  -RemoteVirtualNetworkId $vnetHub.Id
```

Hot area: which **one** parameter is missing, and on **which** command?

Fill in: add `________` to the ________-to-________ peering.

---

**9.** Select the **two** true statements.

A. `--vnet-name` is the VNet where **this** peering resource is created (this side).
B. `--remote-vnet` can be a name in the same subscription or a remote VNet **resource ID**.
C. `--vnet-name` is always the hub, even when you create the spoke peering.
D. Global peering uses the public internet; regional peering uses the backbone.
E. You can **Use remote gateways** while the spoke still has a Basic VPN gateway.

---

**10.** Exhibit — Bicep. This resource’s `parent` is **`vnetHub`**. Hub has the VPN gateway. Which pair belongs **here**?

```bicep
resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: vnetHub
  name: 'hub-to-spoke'
  properties: {
    remoteVirtualNetwork: { id: vnetSpoke.id }
    allowVirtualNetworkAccess: true
    allowGatewayTransit: ???
    useRemoteGateways: ???
  }
}
```

A. `allowGatewayTransit: false`, `useRemoteGateways: true`
B. `allowGatewayTransit: true`, `useRemoteGateways: true`
C. `allowGatewayTransit: true`, `useRemoteGateways: false`
D. `allowGatewayTransit: false`, `useRemoteGateways: false`

---

## Submission — 2026-10-19

1. B, C
2. No, Yes, No, No
3. B
4. non-overlapping; Connected; Allow gateway transit; Use remote gateway
5. 2143 or 2413
6. B
7. B
8. -UseRemoteGateways on spoke-to-hub
9. A, B
10. C

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, C — transit on **hub** object; remote on **spoke**; spoke has no local GW |
| 2 | Correct | No / Yes / No / No — Basic LB ≠ global peering; sync after CIDR change; one remote hub; forwarded ≠ create UDR |
| 3 | Correct | B — hub command must be `--allow-gateway-transit` |
| 4 | Correct | non-overlapping; Connected; Allow gateway transit; **Use remote gateways** (plural nit) |
| 5 | Correct | 2143 and 2413 both legal |
| 6 | Correct | B — remove spoke gateway first |
| 7 | Correct | B — NSG still filters |
| 8 | Correct | `-UseRemoteGateways` on **spoke-to-hub** |
| 9 | Correct | A, B — `--vnet-name` is this side; remote can be a resource ID |
| 10 | Correct | C — `parent: vnetHub` → transit **true**, remote **false** |

Closed: which object gets which gateway flag; both-true illegal; Basic+global; sync; NSG still applies.

