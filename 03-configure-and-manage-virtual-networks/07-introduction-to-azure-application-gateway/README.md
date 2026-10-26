# Module 7 — Introduction to Azure Application Gateway

Learn module: [Introduction to Azure Application Gateway](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-application-gateway/) (6 units)

**Aim:** Layer 7 HTTP(S) load balancing. Listeners, routing rules, backend pools, TLS offload, optional WAF, health probes, when to pick it vs Load Balancer / Traffic Manager / Front Door.

Not a skills-measured heading (snapshot domain **4.3** is Azure DNS plus internal or public **Load Balancer**). Learn it so you can reject it on a “TCP only” item. Mixed papers stay light. v1 SKUs (**Standard**, **WAF**) retired **28 Apr 2026**. New work is **Standard_v2** or **WAF_v2**.

---

## What it is

Application Gateway is the HTTP front door **in one region**. Clients hit a frontend IP. The gateway looks at **host** and **path**, then round-robins across a **healthy** backend pool.

Pools can be VMs, a VM scale set, App Service, or on-premises servers (IP or FQDN). Servers in one pool should be configured the same way.

It is not a DNS balancer and it does not load-balance arbitrary UDP.

| Need | Product |
| --- | --- |
| HTTP path, host header, TLS offload, cookie affinity, regional | **Application Gateway** |
| Those, plus block SQLi / XSS before the app | **WAF_v2** (or Standard_v2 is not enough) |
| TCP/UDP, no URL | **Load Balancer** |
| Fail over by DNS name across regions | **Traffic Manager** (slowed by TTL and caching) |
| Global HTTP, edge, multi-region web | **Front Door** |
| One small app, no load-balancing need | **None of these** |

---

## Request path

Product article [How an application gateway works](https://learn.microsoft.com/en-us/azure/application-gateway/how-application-gateway-works). The intro Learn unit also says the listener is the first thing traffic meets, and elsewhere says WAF runs before the listener. Those two sentences disagree. Use this order:

1. **DNS** returns the **frontend IP** (public, private, or both — at most one of each).
2. **Listener** accepts the connection on that IP: protocol, port, optional **hostname**, optional certificate. TLS ends here. **Multi-site** host (`jasrmg-dev.com` vs another name) is chosen here.
3. **WAF**, if it is on — inspects headers and body **after** the listener has the HTTP request. Prevention **blocks**. Detection logs and still forwards.
4. **Routing rule** on that listener. **Basic** = one pool. **Path-based** = `/images/*` and `/video/*` go to different pools. The path map is the **rule**.
5. **HTTP settings** — protocol and port **to the backend**, cookie affinity, connection draining, request timeout, which probe. The gateway opens a new session.
6. **Healthy backend** only. Round-robin inside the pool.

Learn’s sentence “a basic listener routes on the path” mixes the listener with the rule. On the exam, **host** lives on the listener; **path** lives on the rule.

Also on the rule side: redirect (HTTP→HTTPS or another site), rewrite headers, custom error pages.

---

## TLS

| Pattern | Where the cert is | Backend sees |
| --- | --- | --- |
| **Termination** | Listener. CPU stays off the VMs. VMs need no cert. | HTTP |
| **End-to-end** | Listener decrypts, HTTP settings **re-encrypt** | HTTPS |

End-to-end to **VMs**: HTTP settings `protocol = Https`, backend port **443**, and a cert the gateway uses to authenticate those servers.

End-to-end to **App Service**: do **not** upload the App Service certificate onto the gateway. Azure encrypts that hop and the gateway trusts the platform.

---

## Health probes

Default probe if you configure none.

| | Application Gateway | Load Balancer (module 6) |
| --- | --- | --- |
| Healthy HTTP | **200–399** inclusive | **200** only |
| Default interval | **30** seconds | you set it |
| Source | Gateway **instance private IPs** in its subnet | `168.63.129.16` |

Unhealthy members get no new requests. A custom probe can narrow status codes or match a string in the body.

Cookie affinity (session stickiness) pins a client to one server. Use it when session state is on the box. It is not Load Balancer’s source-IP hash.

---

## SKU and subnet (current)

| SKU | WAF | Autoscale |
| --- | --- | --- |
| **Standard_v2** | No | `--min-capacity` / `--max-capacity` (not a fixed `--capacity`) |
| **WAF_v2** | Yes | same |

This Learn unit still says the WAF default rule set is **CRS 3.1** (also lists 2.2.9, 3.0, 3.2). New policies often start on a newer Microsoft default rule set. Read the policy’s rule-set **name** on the item.

- Dedicated subnet. Recommend **/24** so autoscale (up to 125 instances) plus the five reserved addresses fit. Do not mix the gateway with web VMs.
- v2 NSG on that subnet (unless private-only / network isolation): allow **GatewayManager** inbound **TCP 65200–65535**, plus **AzureLoadBalancer**, plus your listeners (80/443). Backend NSG must allow the **gateway subnet**, not `168.63.129.16`.

---

## When the module says yes

- Probe on-premises (or Azure) web servers and stop sending traffic at a dead one.
- Terminate TLS so the pool spends CPU on the app.
- WAF in front of XSS / SQL injection.
- Cookie affinity because session state is local to each server.

## When it says no

The app does not need load balancing (one small site, current servers already cope). Front Door if the requirement is **global multi-region** HTTP. Traffic Manager if the requirement is **DNS**. Load Balancer if the requirement is **TCP/UDP**.

---

## Create (exam stack)

```bash
az network public-ip create -g rg-gw -n pip-appgw --sku Standard --allocation-method Static
az network vnet subnet create -g rg-gw --vnet-name vnet-app -n snet-appgw --address-prefixes 10.0.255.0/24

az network application-gateway create -g rg-gw -n appgw --sku Standard_v2 \
  --min-capacity 1 --max-capacity 3 \
  --vnet-name vnet-app --subnet snet-appgw \
  --public-ip-address pip-appgw \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http \
  --priority 100
```

WAF: `--sku WAF_v2` plus a WAF policy. Private frontend: `--private-ip-address` in the gateway subnet (still only one private).

```powershell
New-AzApplicationGatewayProbeHealthResponseMatch -StatusCode 200-399
```

Bicep: `Microsoft.Network/applicationGateways`. `sku.name` = `Standard_v2` or `WAF_v2`. `httpListeners` (host, port, protocol, cert) and `requestRoutingRules` (basic or path-based) are separate. `backendHttpSettingsCollection.protocol` is the hop **to the pool**.

| Flag | Meaning |
| --- | --- |
| `--sku Standard_v2` | Current non-WAF SKU. `Standard` is retired v1 |
| `--min-capacity` / `--max-capacity` | Autoscale. Do not also pass `--capacity` |
| `--subnet snet-appgw` | Dedicated gateway subnet |
| `--http-settings-protocol Https` | Re-encrypt to the backend |
| `--priority` | Routing rule priority (required on v2) |
| `--servers` | Backend IPs or FQDNs |

---

## Enterprise scenarios

### 1. “`/images` and `/video` must hit different VM pools, TLS offloaded, SQLi blocked, one region”

**WAF_v2**, path-based rule, listener cert, cookie affinity only if the app needs it. Load Balancer cannot see the path. Front Door also can, and it adds a global edge this requirement did not ask for.

### 2. “SQL Always On on TCP 1433”

Load Balancer. Application Gateway is HTTP.

### 3. “Two regions, users should enter one hostname, fail over when a region dies”

Front Door (HTTP, fast) or Traffic Manager (DNS, slower because of TTL). One regional Application Gateway does not span regions. You can put Traffic Manager or Front Door **in front of** regional gateways.

### 4. “Backend probes fail, NSG allows `168.63.129.16`”

That source is the **load balancer** probe. Allow the **Application Gateway subnet** to the backend port. Healthy codes are **200–399**, so a 302 can still be healthy.

---

## Exam traps from this module

1. **L7** host + path. Not UDP. Not DNS TTL.
2. Listener ≠ routing rule. Multi-site = **host**. Path-based = **rule**.
3. Frontend: one public, one private, or both.
4. Probe **200–399**, default **30s**, source = gateway subnet, not `168.63.129.16`.
5. TLS terminate **or** re-encrypt. App Service backend: no cert upload on the gateway.
6. WAF is optional and runs **after** the listener accepts the request. **WAF_v2** when the item requires a firewall. Prevention blocks; Detection logs and forwards.
7. No load-balancing requirement → do not deploy one. v1 SKU is retired.

## Lab in this folder

```bash
cd 03-configure-and-manage-virtual-networks/07-introduction-to-azure-application-gateway/poc
./appgw.sh            # prints the plan (no deploy)
APPLY=1 ./appgw.sh    # Standard_v2 + dedicated /24 + autoscale, then deletes
```
