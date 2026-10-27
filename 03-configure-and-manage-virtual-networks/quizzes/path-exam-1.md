# Path 03 — Cumulative exam (modules 1–8)

Date issued: 2026-10-27
Scope: virtual networking only. VNets, peering, public IPs, UDRs, NSGs and ASGs, effective security rules, Bastion, service endpoints, private endpoints, Azure DNS, internal and public load balancer, connectivity and load-balancer troubleshooting. Application Gateway is not a scored heading on this paper.
Pass: **9/10**. Closed notes, including `exam/remember.md`.

Format: balanced option lengths, mixed types, at least three exhibits. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every blank.

---

**1.** Select the **two** true statements.

A. Both peering links must show Connected before traffic flows.
B. Peering is transitive, so spokes talk through the hub with no other route.
C. Overlapping address spaces cannot be peered.
D. The spoke peering is the one set to Allow gateway transit.
E. Allow forwarded traffic creates the NVA route.

---

**2.** For each statement, answer **Yes** or **No**.

1. A new public IP should be SKU Standard and allocation Static.
2. Effective security rules return Allow or Deny for a single packet.
3. A load balancer HTTP probe treats status 404 as healthy.
4. A CNAME record can be created at the zone apex.

---

**3.** Exhibit.

```bash
az network route-table route create -g rg --route-table-name rt-app -n to-nva \
  --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.100.4
az network vnet subnet update -g rg --vnet-name vnet-app -n snet-web --route-table rt-app
```

What is true?

A. All traffic, including VNet-local, is sent to 10.0.100.4.
B. This is the catch-all. A longer prefix still wins. The table is on the subnet.
C. VirtualAppliance creates a peering to the appliance VNet.
D. The route table attaches to the NIC. The subnet has no table.

---

**4.** Fill in the blanks. No options.

Azure Bastion Basic or Standard uses a dedicated subnet named ________, no smaller than ________.

---

**5.** Put these in the order that makes `www.jasrmg-dev.com` resolve for internet users. The name is registered at a registrar. Azure does not sell the name. Reply with the numbers, like `2 → 4 → 1 → 3`.

1. At the registrar, set the domain’s name servers to the Azure NS records.
2. Create the public DNS zone `jasrmg-dev.com` in Azure.
3. Confirm a public resolver returns the address for `www.jasrmg-dev.com`.
4. Add the `www` A record in that zone.

---

**6.** Case study. Meet **all** of these:

- The storage account’s public network access is **disabled**.
- VMs in `snet-app` reach the blobs on a **private IP in that VNet**.
- From that VNet, the blob hostname resolves to that private IP.
- A service endpoint plus a public firewall rule does not meet the public-access line.

A. Service endpoint on `snet-app` and a storage firewall allow for the subnet.
B. Private endpoint in `snet-app`, public access disabled, private DNS zone linked to the VNet.
C. A public IP on each VM, allowed on the storage firewall.
D. Peer the VNet to the storage account so the public endpoint becomes private.

---

**7.** Exhibit. The load balancer must be internal. Clients on the internet must not reach it.

```bicep
frontendIPConfigurations: [
  {
    name: 'fe'
    properties: {
      publicIPAddress: {
        id: pip.id
      }
    }
  }
]
```

What do you change?

A. Keep `publicIPAddress`. Internal means a public IP with no DNS label.
B. Use the subnet id. The frontend is a private IP in that subnet.
C. Use a Basic public IP. Basic is the internal SKU.
D. Point `publicIPAddress` at the peered VNet resource id.

---

**8.** Exhibit. Inbound TCP 443 from the internet.

```powershell
Add-AzNetworkSecurityRuleConfig -Name 'allow-https' -NetworkSecurityGroup $nsg `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
  -SourceAddressPrefix Internet -DestinationPortRange 443
Add-AzNetworkSecurityRuleConfig -Name 'deny-https' -NetworkSecurityGroup $nsg `
  -Access Deny -Protocol Tcp -Direction Inbound -Priority 200 `
  -SourceAddressPrefix Internet -DestinationPortRange 443
```

What happens?

A. Denied. A Deny beats an Allow on the same port.
B. Allowed. Priority 100 matches first and evaluation stops.
C. Denied. The default deny is evaluated before custom rules.
D. Allowed only if this NSG is also attached to the NIC.

---

**9.** Select the **two** true statements.

A. A service endpoint leaves the PaaS service on its public IP.
B. A service endpoint creates a private IP for that service in the subnet.
C. An ASG replaces the NSG on the subnet.
D. ASG members are NICs in one VNet. The NSG rule names the ASG.
E. A private endpoint is a route whose next hop is Internet.

---

**10.** IP flow verify returns **Allow**. Next hop returns `VirtualAppliance` and `10.0.100.4`. The VM still cannot reach `10.0.2.4`. Where do you look next?

A. The NSG rule that denied the packet. The Allow result was a false reading.
B. The NVA at 10.0.100.4. The packet is allowed and is routed there.
C. Service health for Azure SQL. This symptom is a PaaS failure.
D. The public DNS zone. VirtualAppliance means the name did not resolve.

---

## Submission — 2026-10-27

1. A, C
2. Yes, No, No, No
3. B
4. AzureBastionSubnet, /26
5. 2 → 1 → 4 → 3
6. B
7. B
8. B
9. A, D
10. B

## Score: 10/10 (100%) — PASS

| Q | Result | Skill | Key |
| --- | --- | --- | --- |
| 1 | Correct | **4.1** peering | A, C — both links Connected; overlapping prefixes cannot peer. Not transitive. Hub gets Allow gateway transit; the spoke gets Use remote gateways. Allow forwarded traffic does not create the NVA route |
| 2 | Correct | **4.1** public IP; **4.2** effective NSG; **4.3** probe and DNS | Y N N N — Standard + Static; one-packet Allow/Deny is IP flow verify; HTTP probe needs **200**; CNAME cannot be the apex |
| 3 | Correct | **4.1** user-defined routes | B — `0.0.0.0/0` is the catch-all. A longer prefix still wins. The table is on the subnet |
| 4 | Correct | **4.2** Bastion | `AzureBastionSubnet`, **/26** |
| 5 | Correct | **4.3** Azure DNS | `2143` is legal: zone, registrar NS, `www` A, then confirm. `2413` is the other legal order. The zone has to exist before the registrar change, and both the NS delegation and the A record have to exist before the confirm |
| 6 | Correct | **4.2** private endpoints | B — private endpoint NIC, public access off, private DNS zone linked to the VNet |
| 7 | Correct | **4.3** internal load balancer | B — frontend is a subnet private IP |
| 8 | Correct | **4.2** NSGs | B — priority 100 matches first and evaluation stops |
| 9 | Correct | **4.2** service endpoints and ASGs | A, D — service endpoint leaves the public IP; ASG is a NIC label in one VNet and the NSG rule names it |
| 10 | Correct | **4.1** troubleshoot connectivity | B — Allow plus next hop VirtualAppliance means look at the NVA |

Path 03 cumulative passed. Domain 4 only. Application Gateway was not scored.
