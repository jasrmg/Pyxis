#!/usr/bin/env bash
# Module 8 — Network Watcher is regional and appears when a VNet is created.
# Diagnostic commands need a VM; this script only prints them unless APPLY=1.
set -euo pipefail

RG="${RG:-rg-az104-watcher}"
LOC="${LOC:-eastus}"
VNET="${VNET:-vnet-app}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "VNet $VNET 10.0.0.0/16 in $LOC makes Network Watcher available in $LOC"
echo "Watcher resource lives in NetworkWatcherRG (do not delete that group)"
echo
echo "IP flow verify (logical NSG test, inbound TCP 5986):"
echo "  az network watcher test-ip-flow -g $RG --vm vm-app --direction Inbound --protocol TCP --local 10.0.1.4:5986 --remote 10.0.2.4:*"
echo "Next hop:"
echo "  az network watcher show-next-hop -g $RG --vm vm-app --source-ip 10.0.1.4 --dest-ip 10.0.2.4"
echo "Connection troubleshoot (one TCP test):"
echo "  az network watcher test-connectivity -g $RG --source-resource vm-app --dest-address 10.0.2.4 --dest-port 5986"
echo "VNet flow log to a storage account:"
echo "  az network watcher flow-log create -g $RG -l $LOC -n flow-app --vnet $VNET --storage-account stflow"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./watcher.sh to create a VNet, list the regional watcher, then delete $RG only."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create --resource-group "$RG" --name "$VNET" --location "$LOC" \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name snet-app --subnet-prefixes 10.0.1.0/24 --output none

echo "== Watchers in $LOC =="
az network watcher list --query "[?location=='$LOC'].{name:name,rg:resourceGroup,location:location}" -o json

echo "== Cleanup (lab group only) =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
