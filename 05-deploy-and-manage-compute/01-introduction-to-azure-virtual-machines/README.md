# Module 1 — Introduction to Azure virtual machines

Learn module: [Introduction to Azure virtual machines](https://learn.microsoft.com/en-us/training/modules/intro-to-azure-virtual-machines/) (8 units)

**Aim:** The decisions before the first VM, then how you create and pay for it. Skill **3.2** (create, sizes, disks). Encryption at host is the same skill and is not named in the disk unit, so it is written out below. Availability sets are named in the unit and finished in the next module. ARM JSON is skill **3.1**.

---

## What Azure creates with the VM

The VM, disks, a virtual network, a NIC, an NSG, and a private IP. A public IP is optional. If you do not supply those resources, Azure builds them and names them from the VM name. There is no charge for the NIC or the NSG. The public IP has its own price. The VM size caps how many NICs you can add.

Plan the network before the VM. Address space is painful to change, and peered networks cannot overlap. Each subnet reserves the first four addresses and the last address. Subnets in one VNet can talk to each other until an NSG says otherwise.

---

## Name, region, size

The VM name is the computer name. **Windows is limited to 15 characters. Linux allows 64.** Changing it later is not a rename you should plan on.

The region sets latency, data residency, which sizes exist, and the price. Check more than one region when the workload is not pinned to a place.

| Workload | Pick | Not this |
| --- | --- | --- |
| Dev/test, small web, small database | General purpose | A GPU size |
| Network appliance, batch, app server | **Compute optimized** | Storage optimized |
| SQL, a large cache, in-memory analytics | **Memory optimized** | Compute optimized |
| A database that is limited by disk I/O | Storage optimized | General purpose just because it is cheaper |

A running VM can move to a new size only when that size is on the **same hardware cluster**. The portal hides the other sizes. The CLI returns an error. The VM **reboots** to finish the change, and a dynamic public IP can change. **Deallocate** the VM and every size in the region is available, because deallocation takes it off that cluster.

---

## What you pay

Compute is billed only while the VM is allocated. **Stopped (deallocated)** stops the compute charge. The disks are still billed. Shutting down from inside the operating system can leave the allocation in place, so compute billing continues. Auto-shutdown is the schedule that stops the VM when nobody is using it.

Linux is cheaper than Windows because the Windows price includes the OS license. **Azure Hybrid Benefit** applies a Windows Server or Linux license you already own and removes that license charge.

**Pay as you go** is for short or unpredictable work. A **reserved** instance is a one-year or three-year commit, up to 72% under pay-as-you-go, for a VM that stays on. You can exchange it or return it and pay an early termination fee.

---

## Disks

Every VM has an OS disk and a temporary disk. Put application data on a **data disk**. If the VM dies, detach that disk and attach it to a new VM. The OS disk is the wrong place for the only copy of the data.

The temporary disk is local storage. Azure does not bill it. Its contents do not survive deallocation, a resize, or host maintenance.

| Disk | OS disk? | Use |
| --- | --- | --- |
| Ultra | No | Highest IOPS. SAP HANA, top-tier databases |
| Premium SSD v2 | No | Production, low latency. The unit still says preview. The product is GA |
| Premium SSD | Yes | Production SSD |
| Standard SSD | Yes | Light web, dev/test |
| Standard HDD | Yes | Backup, infrequent, noncritical |

New disks are managed disks. Do not plan a new VM disk as a page blob.

### Encryption the unit does not name

Managed disks are encrypted at rest in the storage cluster. That encryption does not cover the temporary disk or the cache on the host.

**Encryption at host** encrypts on the host, before the bits are sent to storage. It covers the OS disk, data disks, the temporary disk, and the cache.

**Azure Disk Encryption** turns on BitLocker in Windows or dm-crypt in Linux. That is inside the guest, for the OS and data volumes. It is a different switch from encryption at host.

---

## How you create and change it

The portal is fine for one VM. Dozens of VMs want a template.

An **ARM template is JSON**. Export it from the VM under Automation. You can deploy that JSON again, or edit it and redeploy so Resource Manager changes the existing resources to match. Deleting the resource group deletes the VM and the resources that were created with it. Parameterize the VM name and the network so the same file builds test and production.

`az bicep decompile` turns that exported ARM into Bicep. The exam uses ARM and Bicep. The unit also shows Terraform. Do not use Terraform on this exam.

A VM extension is a small app that configures the guest after the VM exists. Azure Automation is the larger place for repeated tasks, configuration, and update management.

---

## Availability this module introduces

A single host can fail or reboot for maintenance. Azure moves the VM, and that takes minutes.

An **availability zone** is another datacenter in the same region, with its own power, network, and cooling. A supported region has **three** zones. Two VMs in two zones survive one datacenter. They do not survive the loss of the whole region.

A **scale set** is a group of VMs behind a load balancer. The count can follow demand or a schedule. You pay for the VM instances. You do not pay for the scale set resource. Instances can be placed in one zone, in several zones, or with no zone.

**Site Recovery** copies the VM to another region. You can test a failover without touching production, then fail over and later fail back. That is the regional plan. A zone is not a second region.

An availability set splits VMs across fault domains and update domains inside one datacenter. The next module is where that is scored in detail. A VM uses a set or zones, not both.

---

## Backup, in one pass

Azure Backup for an Azure VM uses a **Recovery Services vault** and a backup policy. Windows can take an application-consistent snapshot through VSS. Path 06 is where backup is scored. This module only needs the vault and the policy.

---

## Exam traps

- A network appliance is compute optimized. A big database cache is memory optimized.
- Deallocate to change to a size that is not on the current cluster. The disks stay billed. The temporary disk is wiped.
- Ultra and Premium SSD v2 are not OS disks.
- ARM is JSON. Terraform is not the exam tool.
- A zone is one datacenter. The region is Site Recovery’s problem. The scale set’s price is the VMs, not the set.
- Encryption at host covers the temporary disk. Azure Disk Encryption is BitLocker or dm-crypt in the guest.
