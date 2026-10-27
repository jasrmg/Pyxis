# Module 8 — Introduction to Azure Network Watcher

Learn module: [Introduction to Azure Network Watcher](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-network-watcher/) (6 units)

**Aim:** Pick the Network Watcher tool that answers the question. NSG verdict, route next hop, one-time TCP test, ongoing Connection Monitor, packet capture, VPN gateway health.

Skills measured: **4.1** troubleshoot connectivity, and **5.1** Network Watcher and **Connection monitor**. This is IaaS on a VNet (VMs, VM scale sets, application gateways, load balancers, VPN gateways). It does not diagnose PaaS or web analytics. For those, use Azure status or Service health.

---

## What it is

Network Watcher is **regional**. Create a VNet in East US and Network Watcher becomes available **in East US**. A watcher in East US does not test a VM in West Europe. You do not create one watcher per VNet. The usual resource group is `NetworkWatcherRG`.

Three groups:

| Group | Tools |
| --- | --- |
| Monitoring | **Topology**, **Connection monitor** |
| Diagnostic | **IP flow verify**, **NSG diagnostics**, **Next hop**, **Effective security rules**, **Connection troubleshoot**, **Packet capture**, **VPN troubleshoot** |
| Traffic | **Flow logs**, **Traffic analytics** |

---

## Which tool

| Question | Tool | What comes back |
| --- | --- | --- |
| Did this 5-tuple get allowed, and which **rule**? | **IP flow verify** | Logical test of the NSG rules. Direction, protocol, local IP:port, remote IP:port, VM, NIC. Does not send the packet. |
| Same question for a VM, a scale set, or an application gateway, including a prefix or service tag, and maybe add a rule | **NSG diagnostics** | Allow or deny, the rule, and a place to add a higher-priority rule |
| What route does this VM use toward that IP? | **Next hop** | Next hop type, IP, route table id. A UDR returns that route. Otherwise **System Route**. |
| Which NSG rules apply at all? | **Effective security rules** | NIC rules, subnet rules, and the **aggregate**. Not a single-packet verdict. |
| Can TCP connect **right now**? | **Connection troubleshoot** | Point in time. Latency, probes, hops. Faults include `CPU`, `Memory`, `GuestFirewall`, `DNSResolution`, `NetworkSecurityRule`, `UserDefinedRoute`. |
| Is the path healthy **over time**, including hybrid? | **Connection monitor** | Ongoing samples. Azure VMs need the **Network Watcher** extension (this module). Detects NSG and config changes. |
| I need the packets themselves | **Packet capture** | Extension on the VM or scale set. Filter is a 5-tuple. File on the VM disk or a storage blob. |
| Is the VPN gateway or its connection sick? | **VPN troubleshoot** | Long-running. `UnHealthy` if any diagnosis fails, plus recommended actions. |
| What is connected to what? | **Topology** | Map: subnets, NICs, NSGs, load balancers, probes, public IPs, peerings, gateways, VMs, scale sets. |
| Log the IP traffic, then draw it | **Flow logs** to a **storage account**, then **Traffic analytics** | |

IP flow verify and effective security rules are not substitutes. One says **this packet, this rule**. The other lists **every rule that applies**. Next hop does not change the route table.

Connection monitor and connection troubleshoot are not substitutes. Monitor is **over time**. Troubleshoot is **once**.

---

## Flow logs (current)

The module allows logs on an NSG or on a VNet, stored in a storage account. **VNet flow logs** are the ones you create now. New **NSG flow logs** stopped **30 Jun 2025**. Existing NSG flow logs retire **30 Sep 2027**. Traffic analytics reads those logs. It is not the tool that names the denying rule.

---

## When the module says yes

- VM-to-VM remote PowerShell (TCP **5986**) fails in the same VNet. **IP flow verify** reports the NSG rule. That is a logical check, not a capture.
- Site-to-site VPN from on-premises fails. **VPN troubleshoot** on the gateway connection.
- You need latency between regions, or between an Azure VM and an on-premises host, sampled over time. **Connection monitor**.

## When it says no

PaaS (Azure SQL, App Service) and web analytics. Third-party tools if you need a capture or analysis Network Watcher does not have. Service health covers platform incidents.

---

## Create (exam stack)

```bash
az network watcher test-ip-flow -g rg-app --vm vm-app \
  --direction Inbound --protocol TCP \
  --local 10.0.1.4:5986 --remote 10.0.2.4:*

az network watcher show-next-hop -g rg-app --vm vm-app \
  --source-ip 10.0.1.4 --dest-ip 10.0.2.4

az network watcher test-connectivity -g rg-app \
  --source-resource vm-app --dest-address 10.0.2.4 --dest-port 5986

az network watcher flow-log create -g rg-app -l eastus -n flow-app \
  --vnet vnet-app --storage-account stflow
```

Inbound IP flow verify may use `*` for the **remote** port. Outbound may use `*` for the **local** port. `--nic` is required when the VM has more than one NIC and IP forwarding is on.

```powershell
Test-AzNetworkWatcherIPFlow -NetworkWatcher $nw -TargetVirtualMachineId $vm.Id `
  -Direction Inbound -Protocol TCP -LocalIPAddress 10.0.1.4 -LocalPort 5986 `
  -RemoteIPAddress 10.0.2.4 -RemotePort *
Get-AzNetworkWatcherNextHop -NetworkWatcher $nw -TargetVirtualMachineId $vm.Id `
  -SourceIPAddress 10.0.1.4 -DestinationIPAddress 10.0.2.4
Test-AzNetworkWatcherConnectivity -NetworkWatcher $nw -SourceId $vm.Id `
  -DestinationAddress db.contoso.internal -DestinationPort 1433
```

| Flag / field | Meaning |
| --- | --- |
| `--direction Inbound` | Packet relative to the target VM |
| `--local` / `--remote` | `IP:port` 5-tuple ends |
| `nextHopType` | `VirtualAppliance`, `Internet`, `VirtualNetworkGateway`, `VnetLocal`, `None`, … |
| `NetworkSecurityRule` | Connection-troubleshoot fault: an NSG blocked the TCP test |
| `UserDefinedRoute` | Connection-troubleshoot fault: the route is wrong |
| `DNSResolution` | The destination name did not resolve |
| `--vnet` on `flow-log create` | VNet flow log. `--nsg` is the retiring target |

---

## Enterprise scenarios

### 1. “WinRM to the new Windows VM times out. Same VNet.”

IP flow verify, inbound TCP 5986, local = the Windows VM’s private IP. The result names the rule (`DenyAllInbound` until you allow 5986). Next hop only if the deny is not the story and the packet is routed at an NVA.

### 2. “Next hop is VirtualAppliance 10.0.100.4 and the app still fails”

The UDR is doing what it says. Check the NVA (other subnet, IP forwarding on NIC and OS). IP flow verify on the NVA’s NIC if an NSG there drops the forwarded packet.

### 3. “Connection troubleshoot says DNSResolution”

The name never became an IP. Fix DNS (public zone, private zone, or the VM’s DNS servers) before you edit an NSG.

### 4. “We need a week of latency from the branch to the Azure web VM”

Connection monitor, with the Network Watcher extension on the Azure VM. Connection troubleshoot is one sample, not the week.

---

## Exam traps from this module

1. **Regional**, automatic with the first VNet in that region. Not one watcher per VNet. Not PaaS.
2. **IP flow verify** = one packet, the **rule**. **Effective security rules** = the rule **list**. **Next hop** = the **route**.
3. **Connection troubleshoot** = once. **Connection monitor** = over time, agent on the VM, hybrid included.
4. Fault names: `NetworkSecurityRule`, `UserDefinedRoute`, `DNSResolution`, `GuestFirewall`. Guest firewall is the OS, not the NSG.
5. Packet capture is the packets. VPN troubleshoot is the **gateway**. Topology is the map.
6. Flow logs land in a **storage account**. New logs are **VNet** flow logs. Traffic analytics visualizes them.
7. IP flow verify does not transmit the packet. A Deny there is a rule verdict.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/08-introduction-to-azure-network-watcher/poc
./watcher.sh            # prints the plan (no deploy)
APPLY=1 ./watcher.sh    # creates a VNet, lists the regional watcher, deletes the lab group only
```
