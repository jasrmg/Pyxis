# Module 2 (Configure network security groups) — Quiz 2

Date issued: 2026-10-06
Scope: this module only — NSG association, defaults, first-match, effective subnet+NIC, ASGs on NICs. Not Azure Firewall, WAF, or UDRs.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. An ASG is associated to the public IP resource.
B. An ASG is a label on NICs; an NSG rule can name it as source or destination.
C. After a rule matches, Azure still evaluates every remaining rule in that NSG.
D. When a rule matches, evaluation stops.
E. You associate an NSG to the VNet object so every subnet inherits it.

---

**2.** For each statement, answer **Yes** or **No**.

1. Default `AllowVNetInBound` allows inbound RDP from the internet.
2. After an NSG rule matches, later rules for that packet are not used.
3. You attach an ASG to a `publicIPAddresses` resource.
4. Default outbound to the internet is Allow.

---

**3.** Exhibit — inbound HTTPS from the internet. Subnet NSG and NIC NSG:

```bash
az network nsg rule create -g rg --nsg-name nsg-subnet -n deny-443 \
  --priority 100 --direction Inbound --access Deny --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443

az network nsg rule create -g rg --nsg-name nsg-nic -n allow-443 \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443
```

`nsg-subnet` is on the subnet. `nsg-nic` is on the NIC. What happens?

A. Allowed; the NIC Allow is closer to the VM so it wins.
B. Denied; inbound evaluates the subnet NSG first, Deny matches, evaluation stops.
C. Allowed; `AllowInternetOutBound` covers inbound 443.
D. Denied; two NSGs cannot exist in the same VNet.

---

**4.** Complete each blank.

1. When a rule matches, evaluation ________.
2. `AllowVNetInBound` allows traffic from ________, not from the internet.
3. You put an ASG on the ________, not on the public IP.
4. Default outbound to the internet is ________.

---

**5.** Outbound packet from a VM to the internet. NIC has `nsg-nic`, subnet has `nsg-subnet`. Put the steps in order.

- If the NIC NSG allows, evaluate `nsg-subnet`. If the NIC NSG denies, stop.
- Packet leaves the VM through the NIC.
- Evaluate `nsg-nic`.
- If the subnet NSG allows, the packet leaves the subnet.

---

**6.** Case study — lowest complexity that meets **all**:

- Windows jump VM in `snet-mgmt` must accept RDP from `203.0.113.10/32` only.
- App VMs in `snet-app` must **not** accept RDP from the internet.
- Do not deploy Azure Firewall or Bastion if an NSG meets the requirement.

A. Rely on default `AllowVNetInBound` for the jump VM; no custom rules.
B. NSG on `snet-mgmt`: inbound TCP 3389 from `203.0.113.10/32` Allow (100). NSG on `snet-app`: no inbound 3389 from Internet (default DenyAllInbound is enough).
C. Open TCP 3389 from `Internet` on both subnets so RDP always works.
D. Attach an ASG to each jump-host public IP and skip the NSG.

---

**7.** A VM has a Standard public IP and only default NSG rules on its subnet. An internet client tries TCP 443. What happens?

A. Allowed by `AllowVNetInBound`.
B. Allowed by `AllowInternetOutBound`.
C. Denied by `DenyAllInbound` until you add a custom inbound Allow.
D. Allowed because Standard public IPs are open inbound.

---

**8.** Exhibit:

```powershell
Add-AzNetworkSecurityRuleConfig -Name 'allow-https' -NetworkSecurityGroup $nsg `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 443

Add-AzNetworkSecurityRuleConfig -Name 'deny-https' -NetworkSecurityGroup $nsg `
  -Access Deny -Protocol Tcp -Direction Inbound -Priority 200 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 443
```

Inbound TCP 443 from the internet?

A. Denied; Deny always beats Allow for the same port.
B. Allowed; 110 is processed before 200, the Allow matches, evaluation stops.
C. Denied; default 65500 is processed before any custom rule.
D. Allowed only if the NIC also has a second NSG.

---

**9.** Select the **two** true statements.

A. All NICs in one ASG must be in the same VNet.
B. An ASG replaces the NSG on the subnet.
C. Default NSG rules cannot be deleted.
D. You associate an ASG to the VM’s public IP so inbound HTTPS flows.
E. Evaluation continues after a match so every Deny can still apply.

---

**10.** Exhibit — two ASGs. `asg-web` NICs are in `vnet-east`. `asg-db` NICs are in `vnet-west` (different VNet). Bicep NSG rule:

```bicep
resource rule 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  parent: nsg
  name: 'allow-sql'
  properties: {
    priority: 110
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourceApplicationSecurityGroups: [ { id: asgWeb.id } ]
    destinationApplicationSecurityGroups: [ { id: asgDb.id } ]
    destinationPortRange: '1433'
    sourcePortRange: '*'
  }
}
```

What happens?

A. Succeeds; ASGs work across any two VNets in the subscription.
B. Fails; source and destination ASG NICs must be in the same VNet.
C. Succeeds; peering is created automatically so the ASGs can talk.
D. Fails because Bicep cannot reference `applicationSecurityGroups`.

---

## Submission — 2026-10-06

1. B, D
2. No, Yes, No, Yes
3. B
4. stops; vnet; nic; allow
5. 2 → 3 → 1 → 4
6. B
7. C
8. B
9. C, A
10. B

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — ASG is a NIC label; first match **stops** |
| 2 | Correct | No / Yes / No / Yes — VNet ≠ internet; stop on match; ASG not on public IP; outbound internet Allow |
| 3 | Correct | B — inbound subnet NSG first; Deny stops; NIC Allow never runs |
| 4 | Correct | **stops**; **VNet**; **NIC**; **Allow** |
| 5 | Correct | 2314 — outbound NIC then subnet |
| 6 | Correct | B — custom Allow from that CIDR on mgmt; app subnet keeps DenyAllInbound |
| 7 | Correct | C — Standard public IP + default NSG = DenyAllInbound |
| 8 | Correct | B — 110 Allow before 200 Deny; stop |
| 9 | Correct | A, C — one VNet per ASG; defaults cannot be deleted |
| 10 | Correct | B — source and dest ASG NICs must share a VNet |

Quiz 1 misses (stops, internet vs VNet, ASG on NIC) are closed.
