# Module 6 (Introduction to Azure Load Balancer) — Quiz 2

Date issued: 2026-10-23
Scope: this module — public vs internal frontend object, probe **path** vs probe **source IP**, Standard + NSG, HTTP 200. Not App Gateway/Front Door internals.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A public Standard LB frontend is a **Standard public IP**.
B. An internal LB frontend is a **Standard public IP**.
C. An internal LB frontend is a **private IP in a subnet**.
D. Internal LB frontends are reachable from coffee-shop Wi-Fi with no VPN.
E. You put `publicIPAddress` on the frontend when the requirement is “not on the internet.”

---

**2.** For each statement, answer **Yes** or **No**.

1. `--path /` is the HTTP probe **path**; `168.63.129.16` is the probe **source**.
2. Denying inbound `AzureLoadBalancer` is the supported way to hide backends.
3. HTTP **404** on the probe path marks the instance unhealthy.
4. Inbound NAT rules require a health probe.

---

**3.** Exhibit. Goal: **internal** Standard load balancer (private frontend).

```bash
az network lb create -g rg-lb -n lb-int --sku Standard \
  --public-ip-address pip-lb --frontend-ip-name fe --backend-pool-name be
```

What is true?

A. Correct ILB; `pip-lb` is allocated as a private IP.
B. This is a **public** LB. Internal needs `--vnet-name` and `--subnet` (no public IP).
C. Fails because Standard cannot be internal.
D. Succeeds and publishes `pip-lb` only inside the VNet.

---

**4.** Complete each blank.

1. Public frontend resource type: ________ ________ IP.
2. Internal frontend: private IP in a ________.
3. HTTP probe path in the usual web sample: ________. Probe source IPv4: ________.
4. HTTP healthy status code: ________.

---

**5.** Put these in textbook order for an **internal** SQL listener (TCP 1433), VNet already exists:

- Create probe + load-balancing rule on 1433.
- Create Standard **internal** LB with frontend in a subnet.
- Add NIC IP configs to the backend pool.
- Confirm there is **no** public IP on the frontend.

---

**6.** Case study — lowest complexity that meets **all**:

- Internet users must hit `https://app.contoso.com` on two VMs.
- One anycast/public IP in this region (not DNS global failover).
- L4 is enough (no URL routing).
- Production SKU.

A. Standard **internal** LB in `snet-web`.
B. Standard **public** LB; Standard PIP frontend; probe + rule; NSG Allow 443; NIC IP configs in the pool.
C. Basic public LB (retired) with a Basic PIP.
D. Traffic Manager only, no load balancer.

---

**7.** An admin adds an NSG rule: Deny inbound from source service tag `AzureLoadBalancer`, destination the backend NICs, priority 100. What happens?

A. Clients still work; probes use a different path.
B. Probes fail; backends go **unhealthy**; **new** flows stop. This is unsupported.
C. Only UDP probes fail; TCP rules ignore NSGs.
D. Standard LB bypasses NSGs for probe traffic.

---

**8.** Exhibit:

```bash
az network lb probe create -g rg-lb --lb-name lb-web -n probe-http \
  --protocol Http --port 80 --path /health
```

The app returns **200** on `/health` and **404** on `/`. What is true?

A. Instances are unhealthy; probes always use `/` regardless of `--path`.
B. Instances are healthy if `/health` returns **200**; `--path` is the probe URL path.
C. `--path` is the probe source IP.
D. HTTP probes ignore the path and only check TCP.

---

**9.** Select the **two** true statements.

A. Backend pool members are **NIC IP configs** (or IPs) in the **same VNet**.
B. You associate the backend pool to the VM resource, not the NIC.
C. Load-balancing **rules** name a **probe**; inbound NAT rules do not need one.
D. HA ports (protocol All, ports 0) are a Basic public-LB feature.
E. Probe source `168.63.129.16` is the VM’s private IP.

---

**10.** Exhibit — Bicep. Goal: **public** Standard LB for internet HTTP. Which frontend belongs **here**?

```bicep
resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: 'lb-web'
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

A. `subnet: { id: snetApp.id }` only
B. `publicIPAddress: { id: pipLb.id }` (Standard PIP)
C. `remoteVirtualNetwork: { id: vnetHub.id }`
D. `privateIPAllocationMethod: 'Dynamic'` with no subnet and no PIP

---

## Submission — 2026-10-23

1. A, C
2. Yes, No, Yes, No
3. B
4. Standard public; subnet; / , 168.63.129.16; 200
5. 2134
6. B
7. B
8. B
9. A, C
10. B

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — public = Standard PIP; ILB = private in a subnet |
| 2 | Correct | Yes / No / Yes / No |
| 3 | Correct | B — `--public-ip-address` is a public LB |
| 4 | Correct | Standard public IP; subnet; `/` + `168.63.129.16`; **200** |
| 5 | Correct | 2134 legal (ILB first, then rule, NICs, confirm no PIP) |
| 6 | Correct | B — internet = public Standard LB |
| 7 | Correct | B — Deny AzureLoadBalancer = probes fail |
| 8 | Correct | B — `--path` is the URL path |
| 9 | Correct | A, C — NIC IP config / same VNet; NAT has no probe |
| 10 | Correct | B — public frontend = `publicIPAddress` |

