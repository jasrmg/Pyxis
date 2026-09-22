# Module 3 — Describe the core architectural components of Azure

Learn module: [Describe the core architectural components of Azure](https://learn.microsoft.com/en-us/training/modules/describe-core-architectural-components-of-azure/) (7 units)

**Aim:** regions, region pairs, sovereign regions, availability zones, datacenters, resources and resource groups, subscriptions, management groups, and **the hierarchy**.

Borrowed from AZ-900, but it is the backbone of the governance domain: **every RBAC assignment, policy, lock, and tag decision is a scope decision**, and this module is where scopes are defined.

---

## Physical infrastructure

### Datacenters, regions, region pairs

- **Datacenter** — a physical building. You never target one directly.
- **Region** — a set of datacenters inside a latency-defined perimeter. This is what you pick when you deploy.
- **Region pair** — each region is paired with another in the **same geography**, usually **at least 300 miles apart**. Purpose:
  - **Sequential platform updates** — Azure does not update both halves of a pair at the same time.
  - **Prioritized recovery** — in a broad outage, one region of the pair gets restored first.
  - Some services replicate to the pair automatically (for example **GRS** storage).
- **Sovereign / specialized regions** — separate instances of Azure: **Azure Government** (US) and **Azure China (21Vianet)**. Not just another region in the normal cloud; separate compliance boundary and sometimes separate feature set.

Not every service is in every region. "Feature X is unavailable" is often a region problem, not a permission problem.

### Availability zones

Physically separate locations **within one region**, with independent **power, cooling, and networking**. A region that supports zones has a **minimum of three**.

Three deployment shapes to keep straight:

| Shape | Meaning |
| --- | --- |
| **Zonal** | You pin the resource to a specific zone (e.g. VM in zone 2). You handle redundancy yourself across zones. |
| **Zone-redundant** | The platform spreads it across zones for you (e.g. ZRS storage, zone-redundant load balancer) |
| **Always available** | Global / non-regional services (Entra ID, Azure DNS, Traffic Manager) |

Zones protect against a **datacenter** failure. They do **not** protect against a whole-**region** failure — that needs a second region (and often the paired region).

## Management infrastructure — the hierarchy

Four levels, top to bottom:

```
Management group(s)
  └── Subscription
        └── Resource group
              └── Resource
```

**Role assignments and Azure Policy assignments inherit downward.** That single sentence is most of the governance domain.

### Resources

Anything you create: a VM, a NIC, a storage account, a public IP. Each resource lives in **exactly one resource group**.

### Resource groups

A logical container for lifecycle and permissions.

- **Cannot be nested.** No resource group inside a resource group.
- A resource belongs to **one** RG at a time, but **can be moved** to another RG (or another subscription) — not every resource type supports move.
- **Resources in one RG do not have to be in the same region as the RG** or as each other. The RG's own location only stores its **metadata**.
- **Deleting an RG deletes everything in it.** This is the blast radius argument for one RG per workload/lifecycle.

### Subscriptions

A **billing boundary** and an **access-control boundary**.

- Every subscription trusts **one Entra tenant** (from module 1).
- **Quotas and limits are largely per subscription** — this is why "we hit the vCPU limit" is solved either by a quota increase or by another subscription.
- Common splits: by environment (prod / non-prod), by department for chargeback, or to isolate a billing/limit boundary.

### Management groups

Containers **above** subscriptions, for governance at scale.

- Apply an RBAC assignment or a policy once at a management group and every subscription under it inherits it.
- Up to **10,000** management groups per directory.
- Tree depth: **6 levels**, not counting the **root** management group and not counting the subscription level.
- A management group or subscription has **exactly one parent**.
- Everything starts under the **root management group**, which contains all subscriptions in the directory.

### Tags do not inherit

Tag an RG `env=prod` and the VM inside it has **no tags**. A resource does **not** inherit tags from its resource group or subscription. This surprises people because the hierarchy inherits *permissions and policy* downward — but not tags.

Ways inheritance is actually achieved:

- **Azure Policy** — the built-in **"Inherit a tag from the resource group"** policy uses the **`modify`** effect to stamp tags onto resources. A deliberate assignment, not a default (module 4).
- **Cost Management tag inheritance** — a billing setting that copies RG/subscription tags onto child resources' **cost records** for reporting only; the resource's real tags are unchanged.

Also: not every resource type supports tags, and a resource caps at **50** tags.

### Scope, smallest to largest

```
Resource  <  Resource group  <  Subscription  <  Management group
```

Read that in both directions. Assign **at the smallest scope that does the job** (least privilege). Expect exam questions where the "correct" answer is the narrower scope, and others where the point is that an inherited assignment from above **cannot be removed at the child** — you have to change it where it was assigned.

---

## Enterprise scenarios

### 1. Where does the RBAC assignment go?

A data team needs Reader on 14 subscriptions. Assigning Reader 14 times is the wrong answer — put the subscriptions under a **management group** and assign Reader once there. Inheritance covers the rest, and new subscriptions added later inherit automatically.

### 2. The RG that deleted production

"Playground" RG holds test VMs plus a production database someone created by hand. An admin deletes the RG to clean up costs and takes the database with it. Same lesson as path 01's `--mode Complete`: **RG = blast radius**. One RG per workload and lifecycle, locks on anything that must survive human error (locks arrive in a later module).

### 3. Region pair vs availability zone

Business asks for "high availability." Two different answers:

- Survive a datacenter failure inside the region → **availability zones** (zone-redundant, or zonal spread across 3 zones).
- Survive the whole region going down → **second region**, ideally the **paired region** for sequential updates and prioritized recovery.

Selling zones as regional disaster recovery is the classic mistake.

### 4. Hitting a subscription quota mid-project

A deployment fails at 40 vCPUs in West Europe. It is not RBAC and not a template bug — it is a **per-subscription quota** in that region. Options: request an increase, deploy in another region, or split the workload into another subscription. Know that limits are mostly a **subscription** concept.

### 5. Data residency

A Philippine bank must keep customer data in-country and reports to a regulator. Region choice is a compliance decision, and you check **service availability per region** before designing, because the pretty architecture is worthless if the service is not in the region you are legally allowed to use. Government/sovereign workloads may need **Azure Government** or **Azure China**, which are separate clouds.

---

## Exam traps from this module

1. Resource groups **cannot be nested**.
2. A resource lives in **one** RG, but can be **moved**; the RG location is just metadata, and resources in an RG can be in **different regions**.
3. Deleting an RG **deletes its resources**.
4. Region pairs: same geography, **~300+ miles**, sequential updates, prioritized recovery.
5. A zone-enabled region has **at least 3 zones**; zones protect a datacenter failure, **not** a region failure.
6. Management group tree: **6 levels** deep excluding root, up to **10,000** groups, **one parent** each.
7. Scope order: **resource < RG < subscription < management group**, and assignments **inherit down**.
8. Limits/quotas are largely **per subscription**; billing boundary is the **subscription**.
9. **Tags are not inherited.** RBAC and Policy inherit downward; tags do not. Use the `modify` policy "Inherit a tag from the resource group" if you need it.

## Lab in this folder

`poc/hierarchy.sh` — walks the live hierarchy (management groups → subscriptions → resource groups → resources) read-only, then optionally builds a small tagged RG so you can see that RG location and resource location are independent.

```bash
cd 02-identities-and-governance/03-core-architectural-components/poc
./hierarchy.sh              # read-only walk of your scopes
APPLY=1 ./hierarchy.sh      # create a demo RG + tags, then clean up
```
