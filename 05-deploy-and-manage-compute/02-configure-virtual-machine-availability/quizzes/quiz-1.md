# Module 2 (Configure virtual machine availability) — Quiz 1

Date issued: 2026-11-17
Scope: this Learn module — maintenance, availability sets, fault and update domains, zones, vertical and horizontal scale, scale sets, autoscale. Not App Service. Not guest-patch tooling.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. Update domains default to 5. You can set 1 to 20, and you cannot change that count later.
B. During planned maintenance, only one update domain reboots at a time.
C. Fault domains default to 20.
D. A running VM can be moved into an availability set without being recreated.
E. An availability set keeps the VMs up when the whole datacenter is lost.

---

**2.** For each statement, answer **Yes** or **No**.

1. Live migration for a predicted hardware failure keeps the VM and pauses it only briefly.
2. Unexpected downtime can leave the temporary disk empty.
3. Planned platform maintenance patches the guest operating system for you.
4. Vertical scale-up usually restarts the VM.

---

**3.** Exhibit.

```bash
az vm availability-set create -g rg-app -n avset-web \
  --platform-fault-domain-count 3 --platform-update-domain-count 5
az vm create -g rg-app -n vm-web01 --image Ubuntu2204 \
  --availability-set avset-web --zone 1 \
  --admin-username azureuser --generate-ssh-keys
```

What is the result of the VM create?

A. The VM is in the set and in zone 1. Both protections apply.
B. Rejected. A VM cannot be in an availability set and an availability zone.
C. The VM is created, and the update domain count becomes 20 because a zone was set.
D. The zone wins. The availability set is stored and ignored.

---

**4.** Fill in the blanks. No options.

The default number of update domains is ________. The most you can set is ________.

---

**5.** Put these in the order that adds instances for a CPU spike and for a known Thursday peak. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Add a metric rule that scales out when CPU stays above 75 percent.
2. Create the scale set with flexible orchestration.
3. Enable autoscale on the scale set.
4. Add a schedule rule that scales out before the Thursday peak.

---

**6.** Case study. Thursday evening is always the busy shift. Monday morning is always quiet. You want extra VMs in place before the rush, and fewer after it, without watching the chart. Which feature meets that?

A. A metric rule only. It adds VMs after the CPUs are already full.
B. Vertical scale-up every Thursday. That adds instances before the rush.
C. Schedule-based autoscale. Scale out before Thursday evening and scale in early Monday.
D. Twenty update domains. They add VMs on a clock.

---

**7.** Case study. Two web VMs in East US must keep serving when one datacenter in that region is lost. The region itself stays up. Which build meets that?

A. Two VMs in two availability zones in East US, plus a Standard load balancer.
B. One availability set with three fault domains. Both VMs stay in one datacenter.
C. Both VMs pinned to zone 1 so they share power and cooling.
D. Site Recovery only. That covers one datacenter inside East US.

---

**8.** Exhibit. Every instance is at full CPU. No new VM appears. This command has never been run.

```bash
az monitor autoscale rule create -g rg-app --autoscale-name scale-web \
  --condition "Percentage CPU > 75 avg 5m" --scale out 1
```

What is missing?

A. Autoscale, with a metric rule that adds an instance when CPU stays high.
B. A larger VM size. A scale-out rule changes the size.
C. More update domains. They create instances when CPU is high.
D. A condition of CPU greater than 100, so the rule is able to fire.

---

**9.** Select the **two** true statements.

A. Horizontal scale-out adds instances. Vertical scale-up changes the size and usually restarts the VM.
B. Flexible orchestration is only for identical instances. Uniform is the default for new sets.
C. A zonal service copies the VM across every zone by itself.
D. Max spreading is the recommended algorithm. Fixed spreading fails when five fault domains are not available.
E. Planned maintenance reboots every fault domain at the same time.

---

**10.** Case study. `vm-sql01` is already running. A second SQL VM must share an availability set with it so one rack cannot take both down. You also asked for a zone. Which action meets the constraints Azure actually enforces?

A. Assign the availability set on the running VM. The OS disk stays attached.
B. Add both VMs to the set and pin them to zone 2.
C. Raise the update domain count to 20 and move the running VM in.
D. Recreate `vm-sql01` into a new set with the new VM. It cannot join while it is running, and it cannot also use a zone.

---

## Submission 2026-11-17

1. AB
2. NYNY
3. B
4. 5, 20
5. 2314 or 2341
6. C
7. A
8. A
9. AD
10. D

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — update domains default to 5, range 1–20, immutable; planned maintenance reboots one update domain at a time |
| 2 | **Wrong** | **Y Y N Y** — live migration keeps the VM and pauses it briefly; unexpected downtime can wipe the temporary disk; planned maintenance does not patch the guest OS; vertical scale-up usually restarts the VM |
| 3 | Correct | B — a VM cannot be in an availability set and a zone |
| 4 | Correct | **5**, **20** |
| 5 | Correct | **2 → 3 → 1 → 4** or **2 → 3 → 4 → 1** — create the scale set, enable autoscale, then the two rules in either order |
| 6 | Correct | C — schedule-based autoscale for a known Thursday peak |
| 7 | Correct | A — two zones in the region, plus a Standard load balancer |
| 8 | Correct | A — autoscale was never turned on |
| 9 | Correct | A, D — horizontal adds instances and vertical changes the size; max spreading is the one that still creates when five fault domains are missing |
| 10 | Correct | D — recreate the running VM into the set. It cannot join while running, and it cannot also use a zone |

Closed: update-domain limits, set versus zone, schedule versus metric, two zones for a datacenter, autoscale must exist, max spreading, a running VM cannot join a set.

Open: predicted hardware failure is **live migration**. The VM stays. The temporary disk is what an **unexpected** heal can wipe.
