# Module 8 (Introduction to Azure Network Watcher) — Quiz 1

Date issued: 2026-10-27
Scope: this Learn module — which tool answers an NSG, a route, a one-time TCP test, or an ongoing Connection Monitor. IaaS only. Skills **4.1** and **5.1**.
Pass: **9/10**. Closed notes. Path exam comes after this quiz passes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. IP flow verify names the rule that allowed or denied that packet.
B. Next hop writes a route so the packet can reach the destination.
C. Effective security rules list the NIC rules, the subnet rules, and the aggregate.
D. Packet capture returns the VPN gateway health code.
E. Topology changes NSG priority from the diagram.

---

**2.** For each statement, answer **Yes** or **No**.

1. Creating a VNet in East US makes Network Watcher available in East US.
2. Connection monitor and connection troubleshoot are the same one-time test.
3. Next hop returns the next hop type and the user-defined route when one matches; otherwise a system route.
4. Network Watcher is how you diagnose an Azure SQL PaaS connection failure.

---

**3.** Exhibit. The command returns Access **Deny** and a rule name.

```bash
az network watcher test-ip-flow -g rg-app --vm vm-app \
  --direction Inbound --protocol TCP \
  --local 10.0.1.4:5986 --remote 10.0.2.4:*
```

What did this test tell you?

A. The next hop IP from the route table.
B. The security rule that denied this packet.
C. A capture file stored for this VM.
D. VPN health code UnHealthy.

---

**4.** Fill in the blank. No options.

Connection troubleshoot blocked a TCP test because of an NSG. The fault type string is ________.

---

**5.** Put these in the order you stand up ongoing latency checks between two new Azure VMs. Reply with the numbers, like `2 → 1 → 4 → 3`.

1. Install the Network Watcher extension on both VMs.
2. Create the VNet in East US.
3. Read latency samples over time.
4. Create a Connection Monitor test between those VMs.

---

**6.** Case study. Meet **all** of these with one check:

- `vm-dev` and `vm-app` are in the same VNet.
- TCP **5986** to `vm-app` (`10.0.1.4`) times out.
- You need the **NSG rule name** that dropped it.
- You do not need a week of samples.

A. VPN troubleshoot against the virtual network gateway.
B. IP flow verify for inbound TCP 5986 on `vm-app`.
C. Traffic analytics as the only check you run.
D. Connection monitor for a week, then infer the rule.

---

**7.** Exhibit. Next hop from `vm-app` toward `10.0.2.4`.

```json
{
  "nextHopType": "VirtualAppliance",
  "nextHopIpAddress": "10.0.100.4",
  "routeTableId": "/subscriptions/000/resourceGroups/rg-app/providers/Microsoft.Network/routeTables/rt-app"
}
```

What is true?

A. System route to Internet. No appliance is on this path.
B. A user-defined route whose next hop is 10.0.100.4.
C. An NSG deny. 10.0.100.4 is the rule priority.
D. VPN troubleshoot marked that address UnHealthy.

---

**8.** Exhibit. Destination `db.contoso.internal`, port 1433. Fault type **DNSResolution**.

```powershell
Test-AzNetworkWatcherConnectivity -NetworkWatcher $nw -SourceId $vm.Id `
  -DestinationAddress "db.contoso.internal" -DestinationPort 1433
```

What do you do first?

A. An NSG denied port 1433. Change that rule.
B. DNS did not resolve the name. Fix DNS first.
C. A route with next hop None dropped it. Remove that UDR.
D. The VPN gateway is UnHealthy. Run VPN troubleshoot.

---

**9.** Select the **two** true statements.

A. Connection troubleshoot is a one-time TCP test and can name an NSG or UDR fault.
B. Connection monitor checks the path over time and supports hybrid endpoints.
C. Flow logs are stored only in a SQL database.
D. Packet capture runs inside Azure SQL.
E. Effective security rules return Allow or Deny for one packet.

---

**10.** App Service cannot reach Azure SQL. Both are PaaS. What do you use?

A. IP flow verify on the App Service plan.
B. Service health for this PaaS failure.
C. VPN troubleshoot on a gateway that was never deployed.
D. Packet capture on the Azure SQL server.

---

## Submission — 2026-10-27

1. A, C
2. Yes, No, Yes, No
3. B
4. NetworkSecurityRule
5. 2 → 1 → 4 → 3
6. B
7. B
8. B
9. A, E
10. B

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — IP flow verify names the rule; effective security rules are the NIC + subnet + aggregate list |
| 2 | Correct | Y N Y N — regional with the VNet; monitor ≠ one-time test; next hop reads the route; not PaaS |
| 3 | Correct | B — Deny plus the rule name |
| 4 | Correct | `NetworkSecurityRule` |
| 5 | Correct | 2 → 1 → 4 → 3 — VNet (watcher in that region), extension, Connection Monitor, then samples |
| 6 | Correct | B — IP flow verify, inbound TCP 5986 |
| 7 | Correct | B — UDR, next hop 10.0.100.4 |
| 8 | Correct | B — `DNSResolution` means fix DNS before the NSG |
| 9 | **Wrong** | **A, B**. E describes **IP flow verify**, not effective security rules. B is Connection Monitor: over time, hybrid included |
| 10 | Correct | B — PaaS goes to Service health |

Closed: tool pick for rule vs route vs one TCP test vs DNS fault, regional watcher, VNet-then-extension-then-monitor, PaaS out of scope.

Open: **Connection monitor** is the ongoing hybrid check. Effective security rules do not return Allow or Deny for one packet.
