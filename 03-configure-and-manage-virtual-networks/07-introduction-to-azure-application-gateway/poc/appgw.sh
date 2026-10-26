#!/usr/bin/env bash
# Module 7 — Standard_v2 Application Gateway, dedicated subnet, autoscale. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-appgw}"
LOC="${LOC:-eastus}"
VNET="${VNET:-vnet-app}"
SUBNET="${SUBNET:-snet-appgw}"
PIP="${PIP:-pip-appgw}"
GW="${GW:-appgw}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "VNet $VNET 10.0.0.0/16"
echo "Dedicated subnet $SUBNET 10.0.255.0/24 (gateway only, not the web VMs)"
echo "Standard public IP $PIP"
echo "Application Gateway $GW SKU Standard_v2  min=1 max=3"
echo "  listener HTTP :80"
echo "  HTTP settings HTTP :80 to the pool, cookie affinity off"
echo "  routing rule priority 100"
echo "WAF would be SKU WAF_v2 plus a WAF policy"
echo "Healthy probe codes are 200-399. Probe source is the gateway subnet, not 168.63.129.16"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./appgw.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create --resource-group "$RG" --name "$VNET" --location "$LOC" \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name "$SUBNET" --subnet-prefixes 10.0.255.0/24 --output none
az network public-ip create --resource-group "$RG" --name "$PIP" --location "$LOC" \
  --sku Standard --allocation-method Static --output none
az network application-gateway create --resource-group "$RG" --name "$GW" --location "$LOC" \
  --sku Standard_v2 --min-capacity 1 --max-capacity 3 \
  --vnet-name "$VNET" --subnet "$SUBNET" \
  --public-ip-address "$PIP" \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http \
  --priority 100 --output none

az network application-gateway show --resource-group "$RG" --name "$GW" \
  --query '{name:name,sku:sku.name,tier:sku.tier}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
