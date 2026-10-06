# Path 03 — What to remember

## CIDR visual method (non-octet prefixes)

`/n` = paint the first **n boxes** from the left. Four octets, eight boxes each. Your map is `/1`–`/8` . `/9`–`/16` . `/17`–`/24` . `/25`–`/32` (not `0–8`; `/0` paints nothing).

**Bits used in that octet** = how many boxes in the incomplete row are painted. The unpainted boxes in that same row set the **block** (how far that octet jumps): 1 unpainted → 2, 2 → 4, 3 → 8, 4 → 16, 5 → 32, 6 → 64, 7 → 128, 8 → 256 (the whole octet is host).

```
10.0.0.0/20   paint 20 boxes

octet 1  ██ ██ ██ ██ ██ ██ ██ ██    10
octet 2  ██ ██ ██ ██ ██ ██ ██ ██    0
octet 3  ██ ██ ██ ██ ░░ ░░ ░░ ░░    4 painted, 4 empty → block 16 → 0–15
octet 4  ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░    0–255

range    10.0.0.0 – 10.0.15.255
next     10.0.16.0/20
```

```
10.0.1.0/27   paint 27 boxes

octet 1  ██ ██ ██ ██ ██ ██ ██ ██    10
octet 2  ██ ██ ██ ██ ██ ██ ██ ██    0
octet 3  ██ ██ ██ ██ ██ ██ ██ ██    1
octet 4  ██ ██ ██ ░░ ░░ ░░ ░░ ░░    3 painted, 5 empty → block 32 → 0–31

range    10.0.1.0 – 10.0.1.31
next     10.0.1.32/27
```

Worked: quiz overlap — `10.0.1.128/25` vs `10.0.1.0/24`

- `/25` block in last octet = 128 → `10.0.1.128` – `10.0.1.255`
- `/24` is `10.0.1.0` – `10.0.1.255`
- The `/25` sits **inside** the `/24` → create fails

## Exam block sizes (glance this)

| Prefix | Block | Addresses | Azure usable if this is a subnet (`− 5`) |
| --- | --- | --- | --- |
| `/8` | 1 in 1st octet | 16,777,216 | VNet-sized, not a VM subnet |
| `/12` | 16 in 2nd (`172.16.0.0/12` → `172.16`–`172.31`) | 1,048,576 | RFC1918 block, not a subnet |
| `/16` | 1 in 2nd | 65,536 | typical VNet |
| `/20` | 16 in 3rd | 4,096 | small VNet / large subnet |
| `/24` | 1 in 3rd | 256 | typical subnet, **251** usable |
| `/25` | 128 in 4th | 128 | 123 usable |
| `/26` | 64 | 64 | **59** usable — Bastion / Firewall minimum |
| `/27` | 32 | 32 | **27** usable — GatewaySubnet minimum |
| `/28` | 16 | 16 | 11 usable |
| `/29` | 8 | 8 | **3** usable — too small for most workloads |

Containment test (do this, not `2^n − 5`): write both ranges. If they share any address, they overlap. A subnet must sit **entirely inside** the VNet prefix.

The `− 5` is **per subnet after you carve it**. Do not subtract it from the VNet prefix when checking whether a subnet fits.

## NSG (module 2)

- Associate to **subnet** or **NIC**, not the VM or the VNet. One NSG per subnet; zero or one per NIC; one NSG may attach many times.
- Priority **100–4096**. **Lower number first.** First match stops. Defaults cannot be deleted (65000 / 65001 / 65500).
- Inbound internet = **denied** until a custom Allow. Outbound internet = **allowed**.
- Inbound effective: **subnet NSG then NIC NSG** (both must allow). Outbound: **NIC then subnet**.
- ASG = label on NICs in **one VNet**. The **NSG rule** names the ASG. ASG is not a firewall.

