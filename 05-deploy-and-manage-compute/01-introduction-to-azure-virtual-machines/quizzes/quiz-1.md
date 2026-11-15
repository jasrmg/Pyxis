# Module 1 (Introduction to Azure virtual machines) — Quiz 1

Date issued: 2026-11-14
Scope: this Learn module — the VM checklist, size families, billing, disks, ARM templates, zones, scale sets, and Site Recovery. Availability-set fault domains are the next module. Not App Service.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. A network appliance belongs on a compute-optimized size.
B. A relational database with a large cache belongs on a memory-optimized size.
C. A network appliance belongs on a storage-optimized size.
D. An Ultra disk can be the OS disk.
E. The temporary disk is billed as a managed disk and keeps its files across deallocation.

---

**2.** For each statement, answer **Yes** or **No**.

1. Resource Manager templates are JSON files.
2. Stopping and deallocating a VM stops both the compute charge and the disk charge.
3. Resizing a running VM reboots it.
4. An availability zone is a separate datacenter in the region, with its own power, network, and cooling.

---

**3.** Exhibit. The new size was not available on the VM’s current hardware cluster.

```bash
az vm deallocate -g rg-app -n vm-web01
az vm resize -g rg-app -n vm-web01 --size Standard_D4s_v5
az vm start -g rg-app -n vm-web01
```

What is true of this sequence?

A. Deallocate lets you pick a size that exists in the region. Disks are still billed while it is deallocated.
B. Deallocate deletes the OS disk, so the start fails.
C. A deallocated VM cannot be resized. Only a running VM can change size.
D. Files on the temporary disk are still there after the deallocate.

---

**4.** Fill in the blanks. No options.

A Windows VM computer name can be at most ________ characters. A Linux VM computer name can be at most ________ characters.

---

**5.** Put these in the order the module uses before the VM exists. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Pick the size family for the workload.
2. Plan the virtual network and subnets.
3. Choose the region. It limits which sizes exist and what they cost.
4. Create the VM.

---

**6.** Case study. A Windows dev VM runs a few hours a day on an unpredictable schedule. The team can turn it off at night. The work is ordinary testing, not a network appliance and not a large database. Which choice meets that at the lowest commit?

A. Memory optimized, reserved for one year.
B. Storage optimized, pay as you go, because tests need the highest disk IOPS.
C. General purpose, pay as you go, and auto-shutdown after hours.
D. Compute optimized, reserved for three years, and left running.

---

**7.** Exhibit. A production VM needs an OS disk and a separate data disk. The data disk must be an SSD, and the same disk type must also be legal as an OS disk.

Which type meets both?

A. Premium SSD.
B. Ultra disk.
C. Premium SSD v2.
D. The temporary disk.

---

**8.** Exhibit.

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-07-01",
  "name": "vm-web01",
  "location": "eastus",
  "properties": {
    "hardwareProfile": { "vmSize": "Standard_D2s_v5" }
  }
}
```

What is this fragment?

A. A Bicep file. Bicep is stored as JSON.
B. An ARM template fragment. ARM templates are JSON.
C. A Terraform plan. This exam deploys it with terraform apply.
D. A scale set. vmSize is ignored on a single VM.

---

**9.** Select the **two** true statements.

A. You pay for each VM in a scale set. The scale set resource itself is free.
B. Site Recovery spreads VMs across fault domains in one datacenter.
C. One availability zone protects the VM from the loss of the whole region.
D. A supported region has three availability zones, each with its own power, network, and cooling.
E. A scale set is billed for the set even after every instance is deleted.

---

**10.** Case study. The temporary disk and the host cache must be encrypted. Managed disks are already encrypted at rest in storage. You do not want BitLocker or dm-crypt inside the guest. Which feature meets that?

A. Azure Disk Encryption.
B. A customer-managed key on an unmanaged page blob.
C. Deallocating the VM, which encrypts the temporary disk.
D. Encryption at host.

---

## Submission 2026-11-14

1. AB
2. YNYY
3. A
4. 15, 64
5. 2314
6. C
7. A
8. B
9. AD
10. D

## Score: 10/10 (100%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — a network appliance is compute optimized; a large database cache is memory optimized |
| 2 | Correct | Y N Y Y — ARM is JSON; deallocate stops compute billing and disks keep billing; a running resize reboots; a zone is its own datacenter |
| 3 | Correct | A — deallocate, then any size in the region; disks stay billed |
| 4 | Correct | **15**, **64** |
| 5 | Correct | **2 → 3 → 1 → 4** — network, region, size family, then create |
| 6 | Correct | C — general purpose, pay as you go, auto-shutdown |
| 7 | Correct | A — Premium SSD can be the OS disk. Ultra and Premium SSD v2 cannot |
| 8 | Correct | B — ARM JSON |
| 9 | Correct | A, D — the scale set is free and you pay for the VMs; three zones, each with its own power, network, and cooling |
| 10 | Correct | D — encryption at host covers the temporary disk and the cache |

Closed: size families, deallocate versus disk billing, name limits, create order, Premium SSD as an OS disk, ARM JSON, zones versus a region, encryption at host.
