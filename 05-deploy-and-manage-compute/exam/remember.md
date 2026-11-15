# Path 05 — What to remember

## VM checklist (module 1)

- Plan the **network first**. Non-overlapping space if you will peer. A subnet reserves the first four addresses and the last one.
- The VM name becomes the computer name. **Windows 15** characters. **Linux 64**. It is painful to change later.
- Region limits which sizes exist and what they cost. Put the VM near the users when latency or data residency matters.

| Workload | Family | Fits |
| --- | --- | --- |
| Balanced CPU and memory | **General purpose** | Dev/test, small databases, low to medium web |
| High CPU-to-memory | **Compute optimized** | Network appliances, batch, app servers |
| High memory-to-CPU | **Memory optimized** | Relational databases, caches, in-memory analytics |
| High disk throughput | **Storage optimized** | Disk-heavy databases |
| Graphics or training | **GPU** | Rendering, video, deep learning |
| Fastest CPU | **HPC** | High-performance compute |

- A running resize **reboots** the VM and only works on the current cluster. **Deallocate**, then any size in the region is eligible.
- **Stopped (deallocated)** releases the hardware. Compute billing stops. Disk billing does not. Shutting down from inside the guest can leave the VM allocated, and compute billing continues.
- Auto-shutdown stops the VM on a schedule so you are not paying for idle compute.
- Pay as you go for short or unpredictable work. **Reserved** instances are 1 or 3 years, for a VM that stays on. **Azure Hybrid Benefit** reuses a Windows Server or Linux license you already own.

## Disks

- Every VM has an **OS disk** and a **temporary disk**. Add **data disks** for application data so you can detach them and attach them to a new VM.
- The temporary disk is local, not billed, and **not durable**. Resize, deallocate, and host maintenance wipe it.
- **Premium SSD**, **Standard SSD**, and **Standard HDD** can be OS disks. **Ultra** and **Premium SSD v2** cannot. The Learn unit still labels Premium SSD v2 as preview. The product is GA. Do not treat “preview” as the exam answer.
- New VM disks are **managed disks**. A page blob in a storage account is the old unmanaged disk.

## Encryption (skill 3.2, this module’s disk unit does not name it)

- Managed disks are encrypted at rest in storage. That does **not** cover the temporary disk or the host cache.
- **Encryption at host** encrypts on the host before data reaches storage, including the temporary disk and the cache.
- **Azure Disk Encryption** is BitLocker (Windows) or dm-crypt (Linux) inside the guest, for the OS and data disks. It is not encryption at host.

## How you create it

- Portal, **ARM JSON**, Azure CLI, Azure PowerShell. Export template from the VM’s Automation blade. Redeploying the template makes the resources match it. `az bicep decompile` turns exported ARM into Bicep.
- The unit also shows Terraform. This exam does not.

## Availability the unit introduces

- **Availability zone:** a separate datacenter in the region, with its own power, network, and cooling. Three zones in a supported region. Protects against one datacenter. Not against the whole region.
- **Scale set:** a group of VMs that can grow or shrink. The set itself is free. You pay for each instance. Instances can sit in one zone, several zones, or regionally.
- **Site Recovery:** replicates the VM to another region so you can fail over. A zone does not do that.
- An **availability set** (fault domains and update domains, one datacenter) is the next module. A VM is in a set or in zones, not both.
