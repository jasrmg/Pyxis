# Module 6 — Introduction to Azure Load Balancer

Learn module: [Introduction to Azure Load Balancer](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-load-balancer/) (6 units)

**Aim:** Layer 4 (TCP/UDP) distribution to VMs / VMSS. Public vs internal. Frontend, backend, probe, rule. Standard SKU.

This is **pass-through L4**. It is not Application Gateway (L7 / HTTP), not Traffic Manager (DNS), not Front Door. Skills measured **4.3**.

---

## What it is

Azure Load Balancer is the **frontend IP** clients hit. It hashes each flow and sends it to a **healthy** backend NIC (or IP) in **one VNet**. It does not terminate HTTP or look at URLs.

| Type | Frontend | Who can hit it |
| --- | --- | --- |
| **Public** | **Standard public IP** (must match LB SKU) | Internet (if NSG allows) |
| **Internal** (ILB) | Private IP in a **subnet** | VNet, peered VNets, on-prem via gateway — **not** the internet |

Same-region VM-to-VM through an ILB is private. **Global peering** cannot reach a **Basic** ILB frontend (peering module). Standard ILB **can**.

---

## SKU (exam: pick Standard)

**Basic Load Balancer retired 30 Sep 2025.** Production answer is **Standard**. Gateway SKU exists for NVA bump-in-the-wire — not this module’s default.

| | Standard | Basic (retired / trap) |
| --- | --- | --- |
| PIP | **Standard** static | Basic (mismatch fails) |
| Default inbound | **Closed** until an **NSG** allows | Open |
| Zones | Zone-redundant or zonal | No |
| Backend | NICs or IPs, any VMs in **one VNet** | NIC only; one AV set or one VMSS |
| Probes | TCP, HTTP, **HTTPS** | TCP, HTTP |
| HA ports | **Internal** Standard | No |
| Outbound rules | Yes (public) | No |
| SLA / metrics | 99.99%, Azure Monitor | None |

A VM / AV set / VMSS references **one** LB SKU, never both.

---

## The four pieces (must all exist)

1. **Frontend IP configuration** — public IP **or** subnet private IP.
2. **Backend pool** — NICs or IP addresses in the VNet. You add the **NIC** (or IP), not “the VM object” as the associate target.
3. **Health probe** — LB only sends **new** flows to instances that pass.
4. **Load-balancing rule** — frontend port + protocol → backend port + pool + **probe**.

Optional:

- **Inbound NAT rule** — one frontend port → **one** VM. **No** probe required.
- **Outbound rule** (Standard public) — SNAT for backends that have no instance-level PIP.

Distribution (session persistence):

| Mode | Hash |
| --- | --- |
| Default (none) | 5-tuple: src IP, src port, dest IP, dest port, protocol |
| Source IP | 2-tuple |
| Source IP protocol | 3-tuple |

**Floating IP** (DSR): backend keeps the frontend IP. SQL Always On / some HA ports. Normal web VMs leave it **off**.

**HA ports:** protocol **All**, frontend and backend port **0**. **Internal Standard** only. One probe must mean “this whole instance.”

---

## Health probes

| Protocol | Healthy | Fail |
| --- | --- | --- |
| TCP | Handshake succeeds | No listener / RST |
| HTTP / HTTPS | **200** | Anything else, or timeout |

Source of IPv4 probes: **`168.63.129.16`**. NSG service tag **`AzureLoadBalancer`** (default Allow at 65001). Do not Deny that tag if you want probes to work.

Unhealthy instance: **no new** connections. Standard: **existing TCP stays** until idle timeout. All probes down: no new flows.

HTTP `/` on port 80 that returns 200 is the usual web probe. Probe port **can** differ from the app port.

---

## NSG and Standard

Standard public LB + Standard PIP = **closed**. You still need an NSG Allow to the **backend** (subnet or NIC) for the data port (e.g. 80/443 from Internet) **and** you must not block probes.

Default **AllowAzureLoadBalancerInBound** is why probes work until you Deny them.

---

## When to use it (vs the others)

| Need | Product |
| --- | --- |
| TCP/UDP to VMs, same region, L4 | **Load Balancer** |
| HTTP path, TLS offload, WAF | Application Gateway (next Learn module; light on mixed papers) |
| DNS failover across regions | Traffic Manager |
| Global HTTP anycast / CDN-ish | Front Door |

Outbound to internet from VMs behind a public Standard LB: **outbound rules**, instance PIP, or **NAT Gateway** (cleaner at scale). Internal LB does **not** give internet outbound by itself.

---

## Create (exam stack)

```bash
az network public-ip create -g rg-lb -n pip-lb --sku Standard --allocation-method Static
az network lb create -g rg-lb -n lb-web --sku Standard \
  --public-ip-address pip-lb --frontend-ip-name fe --backend-pool-name be

az network lb probe create -g rg-lb --lb-name lb-web -n probe-http --protocol Http --port 80 --path /

az network lb rule create -g rg-lb --lb-name lb-web -n rule-http \
  --protocol Tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name fe --backend-pool-name be --probe-name probe-http

az network nic ip-config address-pool add -g rg-lb --nic-name nic-web1 \
  --ip-config-name ipconfig1 --lb-name lb-web --address-pool be
```

Internal: omit the public IP; `--vnet-name` + `--subnet` on `lb create` (private frontend).

```powershell
New-AzLoadBalancer -Name lb-web -ResourceGroupName rg-lb -Sku Standard -Location eastus
# Frontend + backend + probe + rule via Set-AzLoadBalancer*Config then Set-AzLoadBalancer
```

Bicep: `Microsoft.Network/loadBalancers` SKU `Standard`. Frontend `publicIPAddress.id` **or** `subnet.id`. `probes`, `backendAddressPools`, `loadBalancingRules` (rule names a probe).

| Flag | Meaning |
| --- | --- |
| `--sku Standard` | Production SKU |
| `--public-ip-address` | Public frontend (PIP SKU must match) |
| `--vnet-name` / `--subnet` | Internal frontend |
| `--protocol Http` + `--path` | HTTP probe (needs **200**) |
| `--probe-name` on the **rule** | Rule without a probe is a portal trap |
| `--load-distribution SourceIP` | Session affinity |
| `--frontend-port 0 --backend-port 0 --protocol All` | HA ports (ILB Standard) |

---

## Enterprise scenarios

### 1. “I created a Standard public LB, curl to the PIP times out”

NSG. Standard is closed. Allow 80/443 to the backend. Confirm probe is 200, not 404 on `/`.

### 2. “Internal LB so home laptops can hit the app”

ILB is not on the internet. Public LB, or App Gateway / Front Door, or VPN/Bastion into the VNet.

### 3. “Basic PIP on a Standard LB”

SKU mismatch. Frontend PIP **Standard**.

### 4. “App Gateway is overkill, we only need TCP 1433 to three SQL VMs”

Load Balancer. Floating IP if the vendor requires the frontend IP on the guest.

---

## Exam traps from this module

1. **L4** TCP/UDP. Not URL routing.
2. **Standard** + **Standard PIP**. Closed until **NSG**.
3. Public vs **internal** (subnet private IP). ILB ≠ internet.
4. Rule needs a **probe**. Unhealthy = no **new** flows.
5. Probe source `168.63.129.16` / tag **AzureLoadBalancer**. HTTP = **200**.
6. Backend = **same VNet**. Associate **NIC IP config** (or IP) to the pool.
7. Basic is **retired**; still a distractor (open, no zones, no HA ports).

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/06-introduction-to-azure-load-balancer/poc
./lb.sh            # prints the plan (no deploy)
APPLY=1 ./lb.sh    # Standard public LB + HTTP probe + rule, then deletes
```
