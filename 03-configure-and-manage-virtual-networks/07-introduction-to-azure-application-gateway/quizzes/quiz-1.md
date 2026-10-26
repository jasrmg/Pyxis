# Module 7 (Introduction to Azure Application Gateway) — Quiz 1

Date issued: 2026-10-26
Scope: this Learn module — L7 vs the other balancers, frontend, listener vs routing rule, TLS to the pool, probes, WAF, when not to deploy one. v2 SKU only.
Pass: **9/10**. Closed notes. No mixed-exam paper.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. It round-robins HTTP requests across the servers in a backend pool.
B. It is a DNS balancer, so failover waits on the record TTL.
C. It can pin one client session to the same backend server.
D. It load-balances UDP the same way a public load balancer does.
E. Deploy it when the site does not need load balancing.

---

**2.** For each statement, answer **Yes** or **No**.

1. One gateway may have a public frontend, a private frontend, or both, and not a second public IP.
2. A default health probe treats only HTTP **200** as healthy.
3. With WAF turned on, WAF inspects the request before the listener.
4. Sending `/images/*` and `/video/*` to different pools is a path-based routing rule.

---

**3.** Exhibit. Goal: new gateway, **autoscaling**, current SKU, its own subnet.

```bash
az network application-gateway create -g rg-gw -n appgw \
  --sku Standard \
  --capacity 2 \
  --vnet-name vnet-app --subnet snet-appgw \
  --public-ip-address pip-appgw \
  --priority 100
```

What is true?

A. `Standard` with `--capacity 2` is the current autoscale setup.
B. Use `Standard_v2`, and min/max capacity instead of `--capacity`.
C. `--priority` is a probe property, so the SKU line can stay.
D. Drop `--subnet`. The gateway shares the web-VM subnet.

---

**4.** Fill in the blank. No options.

A default Application Gateway health probe treats an HTTP status as healthy for which **inclusive** range? Write it like `200-399`.

---

**5.** Put these in the order an HTTPS request traverses when WAF is enabled. Reply with the numbers, like `3 → 5 → 1 → 4 → 2`.

1. Listener (certificate, port, host)
2. A healthy server in the backend pool
3. Frontend IP
4. Routing rule and HTTP settings
5. Web application firewall

---

**6.** Case study — one region. Meet **all** of these, and do not add a global edge:

- `/images/*` and `/video/*` go to different VM pools.
- TLS ends at the gateway.
- SQL injection is blocked before the VMs.
- A shopper stays on the same VM for the session.

A. Public Standard Load Balancer, one pool, TCP 443, source-IP persistence.
B. Traffic Manager, performance routing, one endpoint in that region.
C. Application Gateway `WAF_v2`, path-based rule, cookie affinity.
D. Front Door with WAF and path routing, plus a second region.

---

**7.** Exhibit. Requirement: **re-encrypt** to the backend VMs on 443.

```bicep
properties: {
  port: 80
  protocol: 'Http'
  cookieBasedAffinity: 'Enabled'
  requestTimeout: 30
}
```

What do you change?

A. Set `cookieBasedAffinity` to `Disabled`.
B. Set `protocol` to `Https` and `port` to `443`.
C. Remove `requestTimeout` from the object.
D. Set `protocol` to `Tcp` and `port` to `0`.

---

**8.** Exhibit.

```json
"httpListeners": [
  { "name": "app1", "properties": { "hostName": "contoso.com", "protocol": "Https", "frontendPort": { "id": "port-443" } } },
  { "name": "app2", "properties": { "hostName": "fabrikam.com", "protocol": "Https", "frontendPort": { "id": "port-443" } } }
]
```

Each listener has its own rule and pool. What is this?

A. Path-based routing. `contoso.com` is a URL path.
B. Multiple-site routing. Each listener selects a pool by host.
C. One basic listener. The backend pool picks the host.
D. Traffic Manager. Those names replace the gateway.

---

**9.** Exhibit.

```json
"backendAddresses": [
  { "fqdn": "contoso.azurewebsites.net" }
]
```

What is true?

A. App Service backend. No cert upload on the gateway for that hop.
B. This address is the probe source `168.63.129.16`.
C. `fqdn` means the pool is UDP only.
D. The value must be a public IP resource ID.

---

**10.** One VM, low traffic, the VM already handles the load. Minimum change?

A. Add Application Gateway in front of the VM.
B. Do not add Application Gateway.
C. Add Traffic Manager in front of the VM.
D. Replace the VM with Azure Front Door.

---

## Submission — 2026-10-26

1. A, C
2. Yes, No, No, Yes
3. B
4. 200-399
5. 1 → 5 → 3 → 4 → 2
6. C
7. B
8. B
9. A
10. B

## Score: 9/10 (90%) — PASS (rescored 2026-10-26)

First mark was 8/10. That key followed the intro unit’s “WAF before the listener” sentence. The product article [How an application gateway works](https://learn.microsoft.com/en-us/azure/application-gateway/how-application-gateway-works) says the listener accepts the connection, then WAF inspects headers and body. Statement 3’s answer **No** matches the product article, so question 2 is correct.

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, C — round-robin inside the pool; cookie / session pin. Not DNS, not UDP, not “deploy when you do not need a balancer” |
| 2 | Correct | **Y N N Y** — one public and one private frontend; probe is not 200-only; WAF is **not** before the listener; `/images` vs `/video` is a path-based rule |
| 3 | Correct | B — `Standard_v2` and min/max capacity. v1 `Standard` is retired; `--capacity` is a fixed count |
| 4 | Correct | **200-399** inclusive |
| 5 | **Wrong** | **3 → 1 → 5 → 4 → 2** — frontend IP, listener, WAF, rule + HTTP settings, healthy server. `15342` puts the listener before the frontend IP |
| 6 | Correct | C — one region, path rule, TLS offload, WAF, cookie affinity. Front Door adds a global edge |
| 7 | Correct | B — re-encrypt is `Https` on **443** |
| 8 | Correct | B — multi-site: host header on the **listener** |
| 9 | Correct | A — App Service hop does not need that cert uploaded to the gateway |
| 10 | Correct | B — no load-balancing need, do not add a gateway |

Closed: L7 vs DNS/UDP, probe range, v2 autoscale, path-based + WAF case, end-to-end TLS, multi-site host, App Service cert, when not to deploy, WAF after the listener.

Open: the frontend IP is the hop **before** the listener. `15342` starts at the listener.
