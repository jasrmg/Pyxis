#!/usr/bin/env bash
# Module 1 — create a VNet, a second subnet, and a Standard public IP. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-vnet}"
LOC="${LOC:-eastus}"
VNET="${VNET:-vnet-az104}"
PREFIX="${PREFIX:-10.20.0.0/16}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "VNet $VNET $PREFIX"
echo "  snet-web  10.20.1.0/24"
echo "  snet-data 10.20.2.0/24"
echo "Public IP pip-az104 SKU=Standard Allocation=Static"
echo "Azure reserves 5 IPs in each subnet (.0 .1 .2 .3 and broadcast)."

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./vnet.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create \
  --resource-group "$RG" --name "$VNET" --location "$LOC" \
  --address-prefixes "$PREFIX" \
  --subnet-name snet-web --subnet-prefixes 10.20.1.0/24 --output none
az network vnet subnet create \
  --resource-group "$RG" --vnet-name "$VNET" \
  --name snet-data --address-prefixes 10.20.2.0/24 --output none
az network public-ip create \
  --resource-group "$RG" --name pip-az104 \
  --sku Standard --allocation-method Static --location "$LOC" --output none

az network vnet show --resource-group "$RG" --name "$VNET" \
  --query '{name:name,space:addressSpace.addressPrefixes,subnets:subnets[].{name:name,prefix:addressPrefix}}' -o json
az network public-ip show --resource-group "$RG" --name pip-az104 \
  --query '{name:name,sku:sku.name,alloc:publicIPAllocationMethod,ip:ipAddress}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
