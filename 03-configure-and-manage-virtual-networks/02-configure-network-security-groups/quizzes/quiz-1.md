# Module 2 (Configure network security groups) — Quiz 1

Date issued: 2026-10-06
Scope: this module only — NSG association, default rules, priority, effective subnet+NIC evaluation, ASGs. Not Azure Firewall, WAF, UDRs, or Network Watcher labs.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. You associate an NSG to the virtual machine resource.
B. Each subnet can have at most one NSG.
C. Default NSG rules can be deleted in the portal so inbound internet is open.
D. A lower priority number is processed before a higher number.
E. One NSG can be associated to only a single subnet in its lifetime.

---

**2.** For each statement, answer **Yes** or **No**.

1. For inbound traffic, Azure evaluates a subnet NSG before a NIC NSG.
2. `DenyAllInbound` (65500) can be deleted and replaced with a custom deny.
3. NICs in two different VNets can be members of the same ASG.
4. The same NSG can be associated to two subnets.

---

**3.** Exhibit:

```bash
az network nsg rule create -g rg --nsg-name nsg-web -n allow-ssh \
  --priority 200 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 22

az network nsg rule create -g rg --nsg-name nsg-web -n deny-ssh \
  --priority 100 --direction Inbound --access Deny --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 22
```

An internet client tries TCP 22. What happens?

A. Allowed; Allow is the action that matches port 22.
B. Denied; priority 100 is evaluated first and processing stops.
C. Allowed; default `AllowInternetOutBound` covers inbound SSH.
D. Denied; you cannot have two rules for the same port.

---

**4.** Complete each blank.

1. Custom NSG priority values are ________ through ________.
2. Inbound with both a subnet NSG and a NIC NSG: evaluate ________ first, then ________.
3. When a rule matches, evaluation ________.
4. Default inbound from the internet is ________ until you add a custom Allow.

---

**5.** An inbound packet from the internet to a VM. The subnet has `nsg-subnet`, the NIC has `nsg-nic`. Put the steps in order.

- Deliver to the VM if the NIC NSG allows.
- Evaluate `nsg-subnet`.
- Packet arrives at the subnet.
- If the subnet NSG allows, evaluate `nsg-nic`. If the subnet NSG denies, stop.

---

**6.** Case study — Fabrikam. Lowest-complexity design that meets **all**:

- Three web NICs and two data NICs in one VNet, two subnets.
- HTTPS from the internet to web only.
- TCP 1433 from web to data only; no other 1433.
- Do not hang an NSG on every NIC if one subnet NSG plus labels will do.

A. NSG on each of the five NICs with the five private IPs typed into every rule; no ASGs.
B. One NSG on each subnet. ASGs `asg-web` and `asg-data`. Rules: Internet→asg-web:443 Allow (100); asg-web→asg-data:1433 Allow (110); *→asg-data:1433 Deny (120).
C. Azure Firewall Premium plus Application Gateway WAF, no NSG.
D. One NSG allowing `*` inbound to both subnets so the VMs can boot.

---

**7.** Which default rule allows inbound RDP from the internet?

A. AllowVNetInBound (65000)
B. AllowAzureLoadBalancerInBound (65001)
C. None. DenyAllInbound (65500) blocks it until you add a custom Allow.
D. AllowInternetOutBound (65001)

---

**8.** Exhibit:

```powershell
New-AzNetworkSecurityRuleConfig -Name 'allow-443' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 4096 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 443
```

The NSG still has default `DenyAllInbound` at 65500. What happens to inbound TCP 443 from the internet?

A. Denied; 4096 is processed after 65500 so Deny wins.
B. Allowed; 4096 is a custom priority, so it is processed before 65500.
C. Denied; Standard public IPs ignore NSG Allows.
D. Allowed only if you also set the VNet address prefix to Allow.

---

**9.** Select the **two** true statements about ASGs.

A. All NICs in one ASG must be in the same virtual network.
B. An ASG is a firewall you associate instead of an NSG.
C. An NSG rule can use an ASG as source or destination instead of IP addresses.
D. An ASG is attached to the public IP resource.
E. Peered VNets may share one ASG membership list.

---

**10.** Exhibit — Bicep fragment:

```bicep
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-web'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-https'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'deny-https'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}
```

What happens on deploy?

A. Succeeds; Deny always wins when both rules name port 443.
B. Fails; two inbound rules cannot share priority 200.
C. Succeeds; Azure keeps Allow and drops Deny.
D. Fails because Bicep cannot set `sourceAddressPrefix` to a service tag.

---

## Submission — 2026-10-06

1. B, D
2. Yes; No (override with higher-priority custom rule); No; Yes
3. B (asked for CLI syntax)
4. 100, 4096; subnet, nic; starts(?); deny (+ inbound default names)
5. 3 → 2 → 4 → 1
6. B
7. A
8. B
9. C, D
10. B

## Score: 7/10 (70%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — one NSG per subnet; lower number first. Not the VM; defaults cannot be deleted; one NSG can attach many times |
| 2 | Correct | Yes / No / No / Yes |
| 3 | Correct | B — 100 Deny is processed before 200 Allow; first match stops |
| 4 | **Wrong** | 100–4096; subnet then NIC; evaluation **stops**; inbound from internet is **denied**. You had “starts” |
| 5 | Correct | 3241 = arrive → subnet NSG → then NIC NSG if allowed → deliver |
| 6 | Correct | B — subnet NSGs + ASGs. Do not pick by option length next time |
| 7 | **Wrong** | **C** — none of the defaults allow internet RDP. `AllowVNetInBound` is **VNet**, not Internet. `DenyAllInbound` 65500 |
| 8 | Correct | B — 4096 is still before 65500 |
| 9 | **Wrong** | **A, C** — ASG NICs in one VNet; NSG rule names the ASG. D is false: ASG is on the **NIC**, not the public IP |
| 10 | Correct | B — inbound priorities must be unique |

Closed: associate target, first-match with lower number, inbound order, duplicate priority, 4096 vs 65500.

Open: evaluation **stops** (not starts); internet inbound ≠ AllowVNet; ASG lives on the **NIC**.
