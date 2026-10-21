#!/usr/bin/env bash
# Module 5 — route table + UDR to a Virtual appliance IP, associate to a subnet.
# Default is a dry print. Does not create an NVA VM.
set -euo pipefail

RG="${RG:-rg-az104-udr}"
LOC="${LOC:-eastus}"
VNET="${VNET:-vnet-az104}"
RT="${RT:-rt-web}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "VNet $VNET 10.30.0.0/16  snet-web 10.30.1.0/24  snet-nva 10.30.100.0/24"
echo "Route table $RT associated to snet-web (not NIC, not VM)"
echo "  UDR to-nva  0.0.0.0/0  next-hop VirtualAppliance  10.30.100.4"
echo "NVA would sit in snet-nva with IP forwarding on its NIC + OS"
echo "Do not put this 0.0.0.0/0 table on GatewaySubnet"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./routes.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create --resource-group "$RG" --name "$VNET" --location "$LOC" \
  --address-prefixes 10.30.0.0/16 --subnet-name snet-web --subnet-prefixes 10.30.1.0/24 --output none
az network vnet subnet create --resource-group "$RG" --vnet-name "$VNET" \
  --name snet-nva --address-prefixes 10.30.100.0/24 --output none

az network route-table create --resource-group "$RG" --name "$RT" --location "$LOC" --output none
az network route-table route create --resource-group "$RG" --route-table-name "$RT" \
  --name to-nva --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance --next-hop-ip-address 10.30.100.4 --output none
az network vnet subnet update --resource-group "$RG" --vnet-name "$VNET" --name snet-web \
  --route-table "$RT" --output none

az network route-table show --resource-group "$RG" --name "$RT" \
  --query '{name:name,bgp:disableBgpRoutePropagation,routes:routes[].{name:name,prefix:addressPrefix,hop:nextHopType,ip:nextHopIpAddress}}' -o json
az network vnet subnet show --resource-group "$RG" --vnet-name "$VNET" --name snet-web \
  --query '{name:name,routeTable:routeTable.id}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
