#!/usr/bin/env bash
# Module 4 — Hot SMB share on general-purpose v2, share soft delete, one snapshot.
# Default is a dry print. File Sync needs a Windows Server; this script only prints that topology.
set -euo pipefail

RG="${RG:-rg-az104-files}"
LOC="${LOC:-eastus}"
NAME="${NAME:-staz104f$RANDOM}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Account $NAME kind StorageV2 SKU Standard_LRS (lab only)"
echo "  A premium share would be kind FileStorage and Premium_LRS or Premium_ZRS, not Standard_GRS"
echo "Share dept, SMB, access tier Hot, quota 100 GiB"
echo "Share soft delete 14 days (allowed range is 1-365, on the account file service)"
echo "One share snapshot. Restore one file from it. Up to 200 snapshots. Not account-wide"
echo "SMB mount uses TCP 445. A SAS is REST only. Identity is AD DS, Entra Domain Services, or Entra Kerberos, plus a share role and NTFS"
echo "File Sync: Storage Sync Service in $LOC, register the server, sync group with this share as the only cloud endpoint, then cloud tiering on the server endpoint"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./files.sh to create the share, then delete the lab group."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az storage account create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --kind StorageV2 --sku Standard_LRS \
  --https-only true --min-tls-version TLS1_2 --output none
az storage share-rm create --resource-group "$RG" --storage-account "$NAME" \
  --name dept --quota 100 --access-tier Hot --output none
az storage account file-service-properties update --resource-group "$RG" --account-name "$NAME" \
  --enable-delete-retention true --delete-retention-days 14 --output none
az storage share snapshot --account-name "$NAME" --name dept --auth-mode login --output none

az storage share-rm show --resource-group "$RG" --storage-account "$NAME" --name dept \
  --query '{name:name,tier:accessTier,quota:shareQuota}' -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
