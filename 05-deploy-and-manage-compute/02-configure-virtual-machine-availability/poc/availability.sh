#!/usr/bin/env bash
# Module 2 — an availability set only. Default is a dry print.
# A scale set and autoscale are printed. APPLY does not create VMs.
set -euo pipefail

RG="${RG:-rg-az104-avail}"
LOC="${LOC:-eastus}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Availability set avset-web: 2 fault domains, 5 update domains"
echo "  Fault domain = rack. Update domain = reboot group. Default update domains is 5, max 20, immutable"
echo "  Create the set first. A VM joins only at az vm create --availability-set"
echo "  Do not also pass --zone. A set and a zone on one VM is rejected"
echo "Scale set vmss-web: Flexible orchestration, zones 1 2 3, max spreading"
echo "  Fixed spreading fails unless the region has five fault domains"
echo "Autoscale: metric CPU > 75 for 5 minutes scales out. A Thursday schedule scales out before the peak"
echo "  Instance count stays between the minimum and the maximum"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./availability.sh to create the set, then delete the lab group."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az vm availability-set create --resource-group "$RG" --name avset-web --location "$LOC" \
  --platform-fault-domain-count 2 --platform-update-domain-count 5 --output none

az vm availability-set show --resource-group "$RG" --name avset-web \
  --query '{name:name,faultDomains:platformFaultDomainCount,updateDomains:platformUpdateDomainCount}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
