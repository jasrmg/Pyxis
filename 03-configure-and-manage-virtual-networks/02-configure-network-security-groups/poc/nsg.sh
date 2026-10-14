#!/usr/bin/env bash
# Module 2 — NSG, inbound HTTPS allow, associate to a subnet. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-nsg}"
LOC="${LOC:-eastus}"
VNET="${VNET:-vnet-az104}"
NSG="${NSG:-nsg-web}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "VNet $VNET 10.20.0.0/16  snet-web 10.20.1.0/24"
echo "NSG $NSG"
echo "  inbound allow-https  priority=100  TCP 443 from Internet"
echo "  associate NSG to snet-web (not to the VM object)"
echo "Defaults stay: DenyAllInbound 65500, AllowInternetOutBound 65001"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./nsg.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az network vnet create \
  --resource-group "$RG" --name "$VNET" --location "$LOC" \
  --address-prefixes 10.20.0.0/16 \
  --subnet-name snet-web --subnet-prefixes 10.20.1.0/24 --output none
az network nsg create --resource-group "$RG" --name "$NSG" --location "$LOC" --output none
az network nsg rule create \
  --resource-group "$RG" --nsg-name "$NSG" --name allow-https \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443 --output none
az network vnet subnet update \
  --resource-group "$RG" --vnet-name "$VNET" --name snet-web \
  --network-security-group "$NSG" --output none

az network nsg show --resource-group "$RG" --name "$NSG" \
  --query '{name:name,rules:securityRules[].{name:name,pri:priority,dir:direction,access:access,dest:destinationPortRange}}' -o json
az network vnet subnet show --resource-group "$RG" --vnet-name "$VNET" --name snet-web \
  --query '{name:name,nsg:networkSecurityGroup.id}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
