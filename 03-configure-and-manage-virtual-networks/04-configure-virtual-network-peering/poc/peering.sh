#!/usr/bin/env bash
# Module 4 — two VNets, both peering directions. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-peer}"
LOC="${LOC:-eastus}"
HUB="${HUB:-vnet-hub}"
SPOKE="${SPOKE:-vnet-app}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Hub   $HUB   10.0.0.0/16  snet-hub 10.0.1.0/24"
echo "Spoke $SPOKE 10.1.0.0/16  snet-app 10.1.1.0/24"
echo "Peerings both ways --allow-vnet-access (status must be Connected on both)"
echo "Overlapping CIDR would fail. A-B plus B-C is not A-C."

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./peering.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create --resource-group "$RG" --name "$HUB" --location "$LOC" \
  --address-prefixes 10.0.0.0/16 --subnet-name snet-hub --subnet-prefixes 10.0.1.0/24 --output none
az network vnet create --resource-group "$RG" --name "$SPOKE" --location "$LOC" \
  --address-prefixes 10.1.0.0/16 --subnet-name snet-app --subnet-prefixes 10.1.1.0/24 --output none

az network vnet peering create --resource-group "$RG" --name hub-to-app \
  --vnet-name "$HUB" --remote-vnet "$SPOKE" --allow-vnet-access --output none
az network vnet peering create --resource-group "$RG" --name app-to-hub \
  --vnet-name "$SPOKE" --remote-vnet "$HUB" --allow-vnet-access --output none

az network vnet peering list --resource-group "$RG" --vnet-name "$HUB" \
  --query '[].{name:name,state:peeringState,remote:remoteVirtualNetwork.id}' -o json
az network vnet peering list --resource-group "$RG" --vnet-name "$SPOKE" \
  --query '[].{name:name,state:peeringState,remote:remoteVirtualNetwork.id}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
