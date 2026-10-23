# Module 6 (Introduction to Azure Load Balancer) — Quiz 1

Date issued: 2026-10-23
Scope: this module — L4 public vs internal LB, Standard SKU, frontend/backend/probe/rule, NSG closed-by-default, health probe 200 / AzureLoadBalancer. Not Application Gateway internals, Front Door, or Traffic Manager algorithms.
Pass: **9/10**. Closed notes. Skim `../README.md` first.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Azure Load Balancer routes HTTP by URL path and host header.
B. Azure Load Balancer distributes **TCP/UDP** (Layer 4) to backends in one VNet.
C. A Standard public load balancer is open to the internet with no NSG.
D. A Standard public load balancer is **closed** until an NSG allows the traffic.
E. An internal load balancer’s frontend is a Standard public IP.

---

**2.** For each statement, answer **Yes** or **No**.

1. The public IP SKU on a public LB frontend must match the load balancer SKU.
2. Basic Load Balancer is the current production SKU (SLA 99.99%).
3. HTTP health probes are healthy on status **200**.
4. An inbound NAT rule requires a health probe.

---

**3.** Exhibit:

```bash
az network public-ip create -g rg-lb -n pip-lb --sku Basic --allocation-method Static
az network lb create -g rg-lb -n lb-web --sku Standard \
  --public-ip-address pip-lb --frontend-ip-name fe --backend-pool-name be
```

What happens?

A. Succeeds; SKUs may be mixed.
B. Fails or is invalid; Standard LB needs a **Standard** public IP.
C. Succeeds and silently converts the PIP to Standard.
D. Succeeds because Basic PIP is required for Standard LB.

---

**4.** Complete each blank.

1. Load Balancer is OSI layer ________ (TCP/UDP).
2. Public frontend = ________ IP; internal frontend = ________ IP in a subnet.
3. HTTP probe healthy code is ________. IPv4 probe source is ________.
4. Associate backends on the ________ ________ config (or IP), not the VM object.

---

**5.** You need a public website on two VMs behind one IP. Nothing exists yet. Textbook order:

- Create an HTTP probe and a load-balancing **rule** that names that probe.
- Create a **Standard** public IP.
- Add each VM’s **NIC IP config** to the backend pool; NSG Allow 80 (and do not Deny AzureLoadBalancer).
- Create a **Standard** public load balancer using that PIP as frontend.

---

**6.** Case study — lowest complexity that meets **all**:

- Three VMs in `vnet-app` must share one **private** IP for TCP 1433 from other subnets and from on-prem via VPN.
- Internet clients must **not** reach that IP.
- Production SKU, zone-redundant ready.
- Do not deploy Application Gateway.

A. Standard **internal** load balancer; frontend in a subnet; probe + rule on 1433.
B. Standard **public** load balancer; NSG Deny all; hope on-prem uses the PIP.
C. Application Gateway WAF_v2 with a private frontend.
D. Basic public load balancer (retired) with a Basic public IP.

---

**7.** A Standard public LB rule uses an HTTP probe on `/` port 80. All backends return **404**. What happens to **new** client connections to the frontend?

A. Distributed anyway; probes are optional on rules.
B. No new flows to the pool; instances are unhealthy (not 200).
C. Azure converts the probe to TCP automatically.
D. Only UDP is affected; TCP still works.

---

**8.** Exhibit:

```powershell
New-AzPublicIpAddress -Name pip-lb -ResourceGroupName rg-lb -Sku Standard `
  -AllocationMethod Static -Location eastus
New-AzLoadBalancer -Name lb-web -ResourceGroupName rg-lb -Sku Standard `
  -Location eastus
```

The LB has a Standard SKU but **no** frontend IP config pointing at `pip-lb`. What is true?

A. Internet clients can already hit `pip-lb` and reach VMs.
B. `pip-lb` is unused until it is the LB **frontend**; VMs are not in a backend until you add NIC IP configs; a **rule + probe** still required.
C. `New-AzLoadBalancer` auto-associates every PIP in the RG.
D. Internal mode is implied, so `pip-lb` becomes a private IP.

---

**9.** Select the **two** true statements about probes and NSGs.

A. IPv4 probes come from `168.63.129.16` (`AzureLoadBalancer` tag).
B. Denying `AzureLoadBalancer` inbound is the supported way to hide backends.
C. Default NSG rule AllowAzureLoadBalancerInBound (65001) allows probes until you override it.
D. HTTPS probes are available on Basic SKU only.
E. Inbound NAT rules fail unless they reference a probe.

---

**10.** Exhibit — Bicep. Goal: **internal** Standard ILB. Which frontend is correct?

```bicep
resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: 'lb-int'
  location: 'eastus'
  sku: { name: 'Standard' }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fe'
        properties: {
          ???
        }
      }
    ]
  }
}
```

A. `publicIPAddress: { id: pip.id }`
B. `subnet: { id: snetApp.id }` (private IP allocated in the subnet)
C. `publicIPPrefix: { id: pipPrefix.id }` and SKU Basic
D. `remoteVirtualNetwork: { id: vnetHub.id }`

---

## Submission — 2026-10-23

1. B, D
2. Yes, No, Yes, No
3. B
4. 4; public, private; 200, / ; NICs and IP addresses
5. 2431
6. A
7. B
8. B
9. A, B
10. A

## Score: 7/10 (70%) — FAIL — NEEDS REVIEW

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | B, D — L4; Standard public is **closed** until NSG |
| 2 | Correct | Yes / No / Yes / No — SKU match; Basic ≠ production; HTTP **200**; NAT rule needs **no** probe |
| 3 | Correct | B — Standard LB + Standard PIP |
| 4 | **Wrong** | layer **4**; public / private; **200** and **`168.63.129.16`** (not `/` — `/` is the probe **path**); **NIC IP** config |
| 5 | Correct | 2431 is legal (PIP → LB → NICs → rule). Textbook 2413 puts probe/rule before NICs |
| 6 | Correct | A — Standard **internal** LB |
| 7 | Correct | B — 404 ≠ 200, no new flows |
| 8 | Correct | B — still need frontend + pool members + rule/probe |
| 9 | **Wrong** | **A, C** — probe source / default AllowAzureLoadBalancerInBound. **B is unsupported** (Denying the probe tag breaks health) |
| 10 | **Wrong** | **B** — ILB frontend is a **subnet** (private IP). A is a **public** LB |

Closed: L4, Standard closed+SKU match, 404 unhealthy, case study ILB, NAT no probe.

Open: probe **source IP** vs probe **path**; **internal = subnet**, not PIP; do not Deny `AzureLoadBalancer`.

