#!/usr/bin/env bash
# Module 6 — Standard public load balancer + HTTP probe + rule. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-lb}"
LOC="${LOC:-eastus}"
PIP="${PIP:-pip-lb}"
LB="${LB:-lb-web}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Standard public IP $PIP (SKU must match the LB)"
echo "LB $LB SKU Standard  frontend=fe  backend pool=be"
echo "  probe HTTP :80 path /"
echo "  rule TCP 80 -> 80 using that probe"
echo "Standard is closed until an NSG allows 80 to the backend NICs"
echo "Internal LB would use --vnet-name + --subnet instead of a public IP"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./lb.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network public-ip create --resource-group "$RG" --name "$PIP" \
  --sku Standard --allocation-method Static --location "$LOC" --output none
az network lb create --resource-group "$RG" --name "$LB" --sku Standard --location "$LOC" \
  --public-ip-address "$PIP" --frontend-ip-name fe --backend-pool-name be --output none
az network lb probe create --resource-group "$RG" --lb-name "$LB" --name probe-http \
  --protocol Http --port 80 --path / --output none
az network lb rule create --resource-group "$RG" --lb-name "$LB" --name rule-http \
  --protocol Tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name fe --backend-pool-name be --probe-name probe-http --output none

az network lb show --resource-group "$RG" --name "$LB" \
  --query '{name:name,sku:sku.name,fe:frontendIPConfigurations[0].name,be:backendAddressPools[0].name}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
