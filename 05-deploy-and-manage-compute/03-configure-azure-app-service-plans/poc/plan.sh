#!/usr/bin/env bash
# Module 3 — one Basic App Service plan. Default is a dry print.
# Staging slots need S1. Ten slots need P1V3. APPLY creates B1 and deletes the group.
set -euo pipefail

RG="${RG:-rg-az104-plan}"
LOC="${LOC:-eastus}"
NAME="${NAME:-aspaz104$RANDOM}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "App Service plan $NAME SKU B1 (dedicated VM, SSL, no slots, no autoscale)"
echo "  Shared D1 would be the custom-domain step. Free F1 is the no-charge test."
echo "  One staging slot is S1. Ten slots is P1V3, not S1."
echo "  Scale up changes the SKU for every app on the plan. No redeploy."
echo "  Scale out changes the instance count. Autoscale needs a min, a higher max, and both a scale-out and a scale-in rule."
echo "  8:00 AM Saturday is a time rule. CPU is a metric rule."
echo "  Automatic scaling with no rules is Premium v2 or Premium v3 only."
echo "  Isolated is the tier that can reach 100 instances."

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./plan.sh to create the B1 plan, then delete the lab group."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az appservice plan create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --sku B1 --number-of-workers 1 --output none

az appservice plan show --resource-group "$RG" --name "$NAME" \
  --query '{name:name,sku:sku.name,tier:sku.tier,workers:sku.capacity}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
