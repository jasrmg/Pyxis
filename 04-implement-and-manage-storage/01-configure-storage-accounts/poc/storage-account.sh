#!/usr/bin/env bash
# Module 1 — Standard general-purpose v2, GZRS, HTTPS only. Default is a dry print.
set -euo pipefail

RG="${RG:-rg-az104-stor}"
LOC="${LOC:-eastus}"
NAME="${NAME:-staz104$RANDOM}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Account $NAME kind StorageV2 SKU Standard_GZRS"
echo "  HTTPS only, minimum TLS 1.2"
echo "  name must be 3-24 lowercase letters and numbers, globally unique"
echo "Premium files would be --kind FileStorage --sku Premium_LRS (or Premium_ZRS), not Standard_GRS"
echo "Firewall lock-down is a separate update: --default-action Deny, then network-rule add"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./storage-account.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az storage account create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --kind StorageV2 --sku Standard_GZRS \
  --https-only true --min-tls-version TLS1_2 --output none

az storage account show --resource-group "$RG" --name "$NAME" \
  --query '{name:name,kind:kind,sku:sku.name,https:enableHttpsTrafficOnly}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
