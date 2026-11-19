# Module 3 — Configure Azure App Service plans

Learn module: [Configure Azure App Service plans](https://learn.microsoft.com/en-us/training/modules/configure-app-service-plans/) (7 units)

**Aim:** Pick the cheapest plan that has the features, then scale that plan. Skill **3.4** (plan, scale the plan). The app itself, slots, certificates, and custom DNS records are the next module. This module decides which tier makes those features exist.

---

## What you pay for

An App Service plan is the compute the apps run on. The SKU is the size and the feature set. Every app sits on **one** plan. One plan can hold many apps. The apps share the CPU, memory, and disk.

The bill is the **plan**, plus bandwidth. Adding a second app to the same plan does not add a second plan charge. A noisy app on that plan slows the others, because they share the instances.

The plan has a region and an operating system. Apps on it must be in that region. Windows apps and Linux apps do not share a plan.

Changing the tier or the instance count applies to **every app on the plan**. You do not redeploy. It takes seconds. Azure SQL and Storage that the app uses are **not** scaled by the plan. Scale those yourself.

---

## The tier ladder

The scale unit walks a hotel site up the ladder. Use the lowest tier that has the feature. A bigger size inside the same tier (S1 to S2, or P1V3 to P2V3) adds cores, memory, and storage. It does not unlock the next feature.

| Step | Tier | What you just gained |
| --- | --- | --- |
| Test, no plan charge | **Free** (F1) | Shared sandbox. No custom domain. No scale-out |
| A name of your own | **Shared** (D1) | Custom domain. Still shared compute |
| HTTPS on that name | **Basic** (B1) | Dedicated VM, SSL binding, manual scale-out. No slots. No autoscale |
| A staging copy | **Standard** (S1) | Deployment slots, autoscale, backup |
| More slots than Standard has | **Premium v3** (P1V3) | The assessment’s answer for **10** slots. Standard is not enough |
| A private stamp, up to 100 instances | **Isolated** | App Service Environment |

Standard gives you slots. It does not give you 10 of them. Premium v2 and Premium v3 do. Basic gives you none. Premium also costs more, so it is the wrong answer when one slot is enough. That case stops at Standard.

**Automatic scaling** (also called elastic scaling) is a different switch. The platform watches HTTP traffic, keeps warm instances, and you write no rules. It exists only on **Premium v2 and Premium v3**. A metric rule on Standard is ordinary autoscale, not this.

---

## Scale up and scale out

| | Scale up | Scale out |
| --- | --- | --- |
| Also called | Scale down, the reverse | Scale in, the reverse |
| What changes | The **tier or the VM size**. More CPU, memory, and disk, and the features in the table | The **number of instances** |
| How | Change the plan SKU | Manual count, or autoscale |
| Ceiling | The largest size in the tier | The tier’s instance limit. Isolated can reach **100** |

Autoscale only changes the instance count. It does not change the SKU.

---

## Autoscale rules

You set a **minimum**, a **maximum**, and a **default**.

- Minimum keeps at least that many instances when the load is gone.
- Maximum is the cost ceiling. Autoscale will not pass it.
- Minimum and maximum need a gap. If they are equal, a rule has nowhere to go.
- Default is the count used when the metrics are missing. Pick a safe number.
- Always pair a **scale-out** rule with a **scale-in** rule. Scale-out alone leaves the extra instances running after the spike. Scale-in alone never adds capacity when the spike arrives.
- Tell someone. Email or a webhook on the autoscale event.

| Trigger | Example | When to use it |
| --- | --- | --- |
| **Metric** | CPU above 70% for 5 minutes, average | Load you cannot clock |
| **Time** | 8:00 AM every Saturday | A rush you already know |

The statistic on a metric rule is Average, Minimum, Maximum, or Total. CPU is usually Average.

---

## Commands

```bash
az appservice plan create -g rg-app -n asp-hotel -l eastus --sku S1 --number-of-workers 1
az appservice plan update -g rg-app -n asp-hotel --sku P1V3 --number-of-workers 3
```

`--sku B1` is the SSL tier. `--sku S1` is the first tier with a staging slot. `--sku P1V3` is the tier for 10 slots, and it is one of the two families that can use automatic scaling.

---

## Exam traps

- The plan is the bill. The app count is not.
- Scale up is the tier. Scale out is the instance count. A bigger size in the same tier is still scale up, and it does not add slots.
- Shared is the custom domain. Basic is the SSL binding. Standard is the first staging slot. Ten slots is Premium v3, not S1 and not B1.
- 8:00 AM Saturday is a **time** rule. A CPU threshold is a **metric** rule.
- Automatic scaling with no rules is Premium v2 or Premium v3. It is not Standard autoscale.
- Isolated is how you get toward 100 instances. Do not pick it when Standard already has the slot and the autoscale.
- The SQL database does not grow because the plan did.
