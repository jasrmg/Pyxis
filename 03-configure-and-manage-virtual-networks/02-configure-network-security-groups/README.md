# Module 2 — Configure network security groups

Learn module: [Configure network security groups](https://learn.microsoft.com/en-us/training/modules/configure-network-security-groups/) (9 units)

**Aim:** when to use an NSG, create one, write and evaluate rules, application security groups (ASGs).

This is **filter traffic**. It is not Azure Firewall, not a WAF, not User-Defined Routes (later module).

---

## What an NSG is

A **network security group** is a list of **allow/deny** rules for inbound and outbound traffic. You **associate** it to a **subnet** and/or a **NIC**. You do **not** associate it to the VM object or the VNet object.

| Association | Limit | Effect |
| --- | --- | --- |
| Subnet | **One** NSG per subnet | Every NIC in that subnet is filtered |
| NIC | **Zero or one** NSG per NIC | Only that interface |
| Same NSG | Can attach to **many** subnets and NICs | One rule set, many attachments |

Exam “lowest complexity”: put the NSG on the **subnet** unless one VM in the subnet needs a different filter. Avoid stacking subnet **and** NIC NSGs — both must allow inbound, and a deny at either layer blocks. Hard to troubleshoot.

---

## Rule anatomy

Each rule is a 5-tuple plus action and priority:

| Field | Exam values |
| --- | --- |
| Direction | Inbound or Outbound |
| Source / destination | IP, CIDR, **service tag** (`Internet`, `VirtualNetwork`, `AzureLoadBalancer`, `Storage`, …), or **ASG** |
| Ports | Source and destination (often `*` source, specific dest) |
| Protocol | TCP, UDP, ICMP, Any (`*`) |
| Access | **Allow** or **Deny** |
| Priority | **100–4096**, unique in that collection (inbound and outbound are separate) |

**Lower number = processed first.** First match **stops**. A Deny at 100 beats an Allow at 200 for the same traffic.

You **cannot delete** default rules. You **override** them with a custom rule in 100–4096.

---

## Default rules (every NSG)

**Inbound**

| Priority | Name | Meaning |
| --- | --- | --- |
| 65000 | AllowVNetInBound | VNet (and peered VNet, and `VirtualNetwork` tag) may talk in |
| 65001 | AllowAzureLoadBalancerInBound | Azure LB health probes |
| 65500 | DenyAllInbound | Everything else in is denied — **including the internet** |

**Outbound**

| Priority | Name | Meaning |
| --- | --- | --- |
| 65000 | AllowVNetOutBound | Out to the VNet |
| 65001 | AllowInternetOutBound | Out to the internet |
| 65500 | DenyAllOutBound | Everything else out is denied |

Internet **inbound** is denied until you add a custom Allow (e.g. TCP 443 from `Internet`). Internet **outbound** is allowed by default. That is why “I cannot RDP from home” is often a missing inbound rule (and a Standard public IP is closed until an NSG allows it — module 1).

If you Deny Azure Load Balancer inbound, **probes fail** and the backend looks unhealthy.

---

## Effective rules (subnet NSG + NIC NSG)

**Inbound:** subnet NSG **first**, then NIC NSG. **Both** must allow or the packet never reaches the VM. If the subnet denies, the NIC NSG is never asked.

**Outbound:** NIC NSG **first**, then subnet NSG. A deny at the NIC never reaches the subnet NSG. Either layer can deny.

**Intra-subnet:** default AllowVNet lets VMs in the same subnet talk. A subnet NSG Deny-all inbound/outbound **breaks** VM-to-VM in that subnet.

View the aggregate on the NIC: **effective security rules**. Network Watcher **IP flow verify** names which rule allowed or denied (later module’s tool; the idea is this module’s).

---

## Application security groups

An **ASG** is a **label on NICs** (same role: web, app, data). Use the ASG as source or destination in an NSG rule instead of hard-coded IPs.

| Constraint | Exam wording |
| --- | --- |
| Same VNet | Every NIC in one ASG must live in the **same VNet** as the first member |
| Source + dest ASGs | Both ASGs’ NICs must be in the **same VNet** |
| Not a firewall | ASG does nothing until an **NSG rule** names it |
| NIC membership | A NIC can belong to **more than one** ASG (within limits) |

Classic pattern: NSG on the subnet; `Internet → asg-web :80 Allow` at 100; `asg-web → asg-data :1433 Allow` at 110; `* → asg-data :1433 Deny` at 120. Default AllowVNet would otherwise let everyone hit SQL.

---

## Create (exam stack)

```bash
az network nsg create -g rg-net -n nsg-web --location eastus

az network nsg rule create -g rg-net --nsg-name nsg-web -n allow-https \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443

az network vnet subnet update -g rg-net --vnet-name vnet-app -n snet-web \
  --network-security-group nsg-web
```

```powershell
New-AzNetworkSecurityGroup -Name nsg-web -ResourceGroupName rg-net -Location eastus
# Add-AzNetworkSecurityRuleConfig then Set-AzNetworkSecurityGroup
Set-AzVirtualNetworkSubnetConfig ... -NetworkSecurityGroup $nsg
```

Bicep: `Microsoft.Network/networkSecurityGroups` with `securityRules[]`. Associate by setting the subnet (or NIC) `networkSecurityGroup.id`. ASG is `Microsoft.Network/applicationSecurityGroups`; the NIC lists `applicationSecurityGroups`.

---

## Enterprise scenarios

### 1. “Open 3389 to the internet on the web subnet”

Works, and is the wrong design. Jump host / Bastion (named subnet from module 1) plus inbound deny to the app subnet. If the exam only gives you an NSG, Allow 3389 from a **management CIDR**, not `Internet`.

### 2. Two NSGs — subnet denies 80, NIC allows 80

Inbound **does not** reach the VM. Subnet is evaluated first. Fix the **subnet** rule (or stop stacking).

### 3. SQL VMs still reachable from the web subnet after you “denied the internet”

Default **AllowVNetInBound**. Internet deny does not stop east-west. Add a higher-priority (lower number) rule that allows only `asg-web → asg-sql :1433` and denies other 1433.

### 4. “Attach the NSG to the VM”

The portal shortcut still hangs it on the **NIC**. ARM/Bicep/exam: subnet or NIC.

---

## Exam traps from this module

1. Associate **subnet** or **NIC**, not the VM or the VNet.
2. **One** NSG per subnet; **zero or one** per NIC; one NSG may attach **many** times.
3. Priority **100–4096**; **lower number wins**; first match stops.
4. Defaults **cannot be deleted**; inbound internet is **denied**; outbound internet is **allowed**.
5. Inbound effective: **subnet then NIC** (both must allow). Outbound: **NIC then subnet**.
6. ASG = NIC label in **one VNet**; rules still live on the **NSG**.
7. Service tag `VirtualNetwork` ≠ “this subnet only” — it includes the VNet (and peering, in the default-rule sense).
8. Azure Firewall / WAF / NSG are different products. This module is NSG.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/02-configure-network-security-groups/poc
./nsg.sh            # prints the plan (no deploy)
APPLY=1 ./nsg.sh    # NSG + HTTPS allow + subnet associate, then deletes
```
