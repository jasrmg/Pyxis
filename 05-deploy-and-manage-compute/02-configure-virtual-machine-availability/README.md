# Module 2 — Configure virtual machine availability

Learn module: [Configure virtual machine availability](https://learn.microsoft.com/en-us/training/modules/configure-virtual-machine-availability/) (12 units)

**Aim:** Keep the app up through a rack failure, a rolling reboot, and a datacenter loss, and add or remove VMs when the load changes. Skill **3.2** (availability sets, availability zones, VM Scale Sets). A whole-region loss is still Site Recovery, from module 1.

---

## What takes the VM down

| Event | What Azure does | What you lose |
| --- | --- | --- |
| **Predicted** hardware failure | **Live migration** to a healthy host. The VM pauses briefly | Not the VM. Performance can dip |
| **Unexpected** rack or host failure | The platform heals the VM onto a healthy host. The VM **reboots** | The **temporary disk** can be empty |
| **Planned** platform maintenance | The host is patched. One update domain reboots at a time | Not the guest OS. Microsoft does **not** patch your operating system |

You own guest patches. An availability plan does not turn that on.

---

## Availability set

One datacenter. Use it when the requirement is a **rack** failure or a **rolling reboot**, not the loss of the datacenter.

Each VM in the set sits in one **fault domain** and one **update domain**.

| | Fault domain | Update domain |
| --- | --- | --- |
| What it is | A rack: shared power and network switch | VMs that reboot together |
| Planned maintenance | Not the reboot group | **One** update domain reboots at a time |
| How many | **2** by default, **3** in some regions | **5** by default. You may set **1 to 20** |
| After create | The count is fixed. Delete the set and create another to change it | Same |

A VM **joins the set only when the VM is created**. You cannot assign a running VM to a set. Recreate it.

A VM is in an availability set **or** in an availability zone. The create fails if you pass both.

Put a **Standard load balancer** in front so clients are not sent to the VM that is rebooting. Two tiers, such as web and SQL, are **two sets**, each with a VM in each fault domain. One set does not cover both tiers by itself.

Managed disks line up with the fault domains. You do not place the disks yourself.

SLA worth saying later: two or more VMs in a set is **99.95%**. Two or more zones is **99.99%**. A single VM on a Premium SSD is **99.9%**.

---

## Availability zones

A zone is one or more datacenters in the region with its own power, cooling, and network. Every region that offers zones has **at least three**.

Two VMs in two zones survive one datacenter. They do not survive the loss of the region. Pair zones with the **regional pair** (Site Recovery for the VM) when the requirement is the whole region.

| Kind | What it means | Examples |
| --- | --- | --- |
| **Zonal** | You pin the resource to a zone | VM, managed disk |
| **Zone-redundant** | The platform copies it across the zones | ZRS storage, Azure SQL |

A Standard public IP can be zone-redundant, pinned to one zone, or regional with no zone. Zone-redundant is the one that stays up when a zone drops.

VMs you spread across zones are treated as spread across fault domains and update domains. The platform does not update every zone at once.

---

## Vertical and horizontal

| | Vertical | Horizontal |
| --- | --- | --- |
| Also called | Scale **up** / scale **down** | Scale **out** / scale **in** |
| What changes | The **size** of the existing VM | The **number** of VMs |
| Cost of the change | Usually a **restart**. The size has to exist in the region | Add or remove an instance. No size ceiling as tight as one VM |
| On a scale set | Not what autoscale does | What autoscale does |

Scale-up hits a hardware limit and reboots. Scale-out is the flexible one. If you rebuild a VM, the data disk has to be moved on purpose. It does not come along by itself.

---

## Scale sets and autoscale

A scale set is a group of VMs. The set is free. You pay for the instances. Module 1 already had that price.

**Flexible** orchestration is the default for a new set. Use it unless you have a reason to want identical instances managed the old way. **Uniform** is that older mode.

Spreading, on the Advanced tab:

- **Max spreading** puts VMs in as many fault domains as the zone has. This is the one to pick. If five fault domains are not there, the set still creates.
- **Fixed spreading** demands **exactly five** fault domains. The create **fails** when the region cannot give five.

Autoscale changes the **instance count**, between a minimum and a maximum you set. It will not pass the maximum. A rule that is never created does nothing, no matter how high the CPU goes.

| Rule | When it fires | Use |
| --- | --- | --- |
| **Metric** | After the signal stays past the threshold, such as CPU above 75% for 5 minutes | Load you cannot predict |
| **Schedule** | At a clock time | Thursday evening is always busy. Monday morning is always quiet |

A metric rule adds VMs **after** the CPUs are already hot. A schedule adds them **before** the rush. The assessment’s “CPU is full and nothing new appears” is autoscale not turned on. Lowering the threshold does not help if there is no rule.

---

## Commands

```bash
az vm availability-set create -g rg-app -n avset-web -l eastus \
  --platform-fault-domain-count 2 --platform-update-domain-count 5

az vm create -g rg-app -n vm-web01 --image Ubuntu2204 \
  --availability-set avset-web --size Standard_D2s_v5 \
  --admin-username azureuser --generate-ssh-keys

az vmss create -g rg-app -n vmss-web --image Ubuntu2204 \
  --orchestration-mode Flexible --zones 1 2 3 \
  --vm-sku Standard_D2s_v5 --instance-count 2
```

Do not pass `--zone` and `--availability-set` on the same `az vm create`.

---

## Exam traps

- Fault domain = rack. Update domain = who reboots together. Default update domains is **5**, max **20**, and you cannot edit it later.
- A running VM does not join a set. A set and a zone on the same VM is rejected.
- A set does not survive a datacenter. A zone does not survive the region.
- Horizontal adds instances. Vertical changes the size and usually restarts. Autoscale is horizontal.
- Thursday-known peak = **schedule**. CPU already at 75% and you want more VMs = **metric**, and autoscale has to be on, under the maximum.
- Fixed spreading fails without five fault domains. Max spreading does not.
- Live migration is not a reboot that wipes the temp disk. Unexpected healing can.
