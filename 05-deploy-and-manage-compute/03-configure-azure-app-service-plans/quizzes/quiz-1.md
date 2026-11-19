# Module 3 (Configure Azure App Service plans) — Quiz 1

Date issued: 2026-11-19
Scope: this Learn module — plan billing, the pricing ladder, scale up and scale out, autoscale rules, automatic scaling. Not slot swap. Not certificate binding steps.
Pass: **9/10**. Closed notes.

Format: balanced option lengths, plausible distractors, mixed question types. The longest option is not the key.

Reply `1.` through `10.` in chat. Answer every part of multi-part questions.

---

**1.** Select the **two** true statements.

A. You pay for the App Service plan. Another app on that plan does not add a plan charge.
B. Scale up changes the plan tier and applies to every app on the plan. You do not redeploy.
C. Each web app is billed on its own, even when the apps share a plan.
D. Scale out is how you add deployment slots.
E. A scale-up requires a new code deployment before the size changes.

---

**2.** For each statement, answer **Yes** or **No**.

1. In this module’s ladder, a custom domain is the reason you leave Free for Shared.
2. In that same ladder, an SSL binding is the reason you move from Shared to Basic.
3. Basic includes staging slots.
4. A rule that fires at 8:00 AM every Saturday is a metric-based rule.

---

**3.** Exhibit. The production app needs **10** staging slots.

```bash
az appservice plan update -g rg-app -n asp-hotel --sku S1 --number-of-workers 1
```

What meets the slot count?

A. Leave the SKU at S1. Standard includes 10 slots.
B. Change the SKU to P1V3. Standard does not provide 10 slots.
C. Change the SKU to B1. Basic adds slots and autoscale.
D. Create nine more apps on the plan. Each app counts as one slot.

---

**4.** Fill in the blanks. No options.

An App Service Environment in the Isolated tier can scale out to ________ instances. A rule that fires at 8:00 AM Saturday is ________-based.

---

**5.** Put the module’s ladder in order, from the no-charge test up to the first staging slot. Reply with the numbers. A format example is `1 → 2 → 3 → 4`, and that example is not a hint.

1. Basic, when you need an SSL binding.
2. Free, to test with no plan charge.
3. Standard, when you need a staging slot.
4. Shared, when you need a custom domain name.

---

**6.** Case study. The hotel site needs a custom domain, an SSL binding, and one staging slot. Pick the lowest tier that has all three.

A. Free F1.
B. Shared D1.
C. Basic B1.
D. Standard S1.

---

**7.** Exhibit. Autoscale on the plan is configured like this.

```text
minimum: 2
maximum: 2
default: 2
rule: scale out 1 when CPU average > 70% for 5 minutes
```

There is no scale-in rule. What is wrong?

A. The minimum and the maximum are equal, so the rule has no room, and nothing scales the count back down.
B. Remove the scale-out rule. A scale-in rule alone covers a CPU spike.
C. Set the default to 0 so the app stops when metrics are missing.
D. This rule changes the pricing tier when CPU passes 70 percent.

---

**8.** Case study. The platform should add and remove instances from HTTP traffic. You do not want to write rules. Warm instances should already be up. Which plan family meets that?

A. Standard S1, with a metric rule on CPU.
B. Basic B1, with a manual instance count of 3.
C. Premium v3, using automatic scaling.
D. Free F1. HTTP traffic is covered on the free stamp.

---

**9.** Select the **two** true statements.

A. The maximum instance count is a cost ceiling. Autoscale does not pass it.
B. Scaling the App Service plan also resizes the Azure SQL database the app uses.
C. A scale-out rule with no scale-in rule can leave the extra instances running after the load drops.
D. 8:00 AM Saturday is a metric rule.
E. Scale out increases the size of the current instance.

---

**10.** Case study. Three apps share `asp-hotel`. You change the plan from S1 to P1V3. What is true?

A. Only the app you select moves to P1V3. The other two stay on S1.
B. The plan charge stays the same because you did not add an app.
C. Delete the three apps and recreate them. A plan SKU cannot change.
D. All three apps run on P1V3. No redeploy is required.

---

## Submission 2026-11-19

1. AB
2. YYNN
3. B
4. 100, metric
5. 2413
6. D
7. A
8. C
9. AC
10. D

## Score: 9/10 (90%) — PASS

| Q | Result | Key |
| --- | --- | --- |
| 1 | Correct | A, B — you pay for the plan; scale up applies to every app on it and needs no redeploy |
| 2 | Correct | **Y Y N N** — custom domain leaves Free for Shared; SSL binding leaves Shared for Basic; Basic has no staging slots; 8:00 AM Saturday is not a metric rule |
| 3 | Correct | B — 10 slots means `P1V3`. Standard does not provide 10. Basic adds none |
| 4 | **Wrong** | **100**, **time** — Isolated scale-out stops at 100 instances. 8:00 AM Saturday is a time-based rule. A CPU threshold is the metric rule |
| 5 | Correct | **2 → 4 → 1 → 3** — Free, Shared (custom domain), Basic (SSL binding), Standard (first staging slot) |
| 6 | Correct | D — Standard S1 is the lowest tier with a custom domain, an SSL binding, and one staging slot |
| 7 | Correct | A — minimum equals maximum, so the scale-out rule has no room, and there is no scale-in rule |
| 8 | Correct | C — automatic scaling, with no rules and warm instances, is Premium v2 or Premium v3 |
| 9 | Correct | A, C — the maximum is a ceiling autoscale will not pass; scale-out without scale-in can leave the extra instances running |
| 10 | Correct | D — all three apps move to P1V3 with the plan. No redeploy |

Closed: plan billing, the ladder through the first slot, 10 slots is P1V3, autoscale min/max, automatic scaling is Premium v2 or v3.

Open: a clock time is a **time** rule. You already marked that it is not a metric rule on question 2.
