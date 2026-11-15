#!/usr/bin/env bash
# Module 1 — one general-purpose Ubuntu VM. Default is a dry print.
# APPLY creates the VM, deallocates it, and deletes the lab group. Disks would still bill during deallocate.
set -euo pipefail

RG="${RG:-rg-az104-vm}"
LOC="${LOC:-eastus}"
NAME="${NAME:-vm-lab01}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Network first. Azure will create a VNet, NIC, and NSG named from $NAME if you do not pass existing ones."
echo "VM $NAME image Ubuntu2204 size Standard_B1s (lab only; a balanced app is general purpose, a network appliance is compute optimized)"
echo "Linux computer name may be 64 characters. A Windows computer name stops at 15."
echo "OS disk plus a temporary disk. The temporary disk is free and is wiped by deallocate."
echo "Deallocate stops compute billing. Managed disks keep billing."
echo "A running resize reboots the VM and only works on the current cluster."

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./vm.sh to create, deallocate, and delete the lab group."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az vm create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --image Ubuntu2204 --size Standard_B1s \
  --admin-username azureuser --generate-ssh-keys \
  --public-ip-sku Standard --output none

az vm show --resource-group "$RG" --name "$NAME" \
  --query '{name:name,size:hardwareProfile.vmSize,location:location}' -o json

echo "== Deallocate (compute billing stops, disks remain) =="
az vm deallocate --resource-group "$RG" --name "$NAME" --output none

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
