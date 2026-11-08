#!/usr/bin/env bash
# Module 2 — private container plus blob versioning on a general-purpose v2 account.
# Default is a dry print. Object replication needs a second account; this script only prints that step.
set -euo pipefail

RG="${RG:-rg-az104-blob}"
LOC="${LOC:-eastus}"
NAME="${NAME:-staz104b$RANDOM}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Account $NAME kind StorageV2 SKU Standard_LRS (lab only; production choice is still the redundancy table)"
echo "Container images, private"
echo "Blob versioning on, soft delete 14 days"
echo "Object replication would be a second account, versioning on BOTH, then a container-to-container policy"
echo "Lifecycle example: images/ to Cool at 30 days, Archive at 90, delete at 365"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./blob.sh to create then delete."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az storage account create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --kind StorageV2 --sku Standard_LRS \
  --https-only true --min-tls-version TLS1_2 --output none
az storage container create --account-name "$NAME" --name images --auth-mode login --public-access off
az storage account blob-service-properties update --resource-group "$RG" --account-name "$NAME" \
  --enable-versioning true --enable-delete-retention true --delete-retention-days 14 --output none

az storage account blob-service-properties show --resource-group "$RG" --account-name "$NAME" \
  --query '{versioning:isVersioningEnabled,deleteRetention:deleteRetentionPolicy}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
