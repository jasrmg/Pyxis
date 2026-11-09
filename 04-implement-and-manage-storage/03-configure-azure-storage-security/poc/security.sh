#!/usr/bin/env bash
# Module 3 — container stored access policy on a general-purpose v2 account.
# Default is a dry print. A SAS URI is minted only if you opt in; the account key is not printed.
set -euo pipefail

RG="${RG:-rg-az104-sec}"
LOC="${LOC:-eastus}"
NAME="${NAME:-staz104s$RANDOM}"
EXP="${EXP:-$(date -u -v+1d +%Y-%m-%dT%H:%MZ)}"

echo "== Plan =="
echo "RG=$RG location=$LOC"
echo "Account $NAME kind StorageV2 SKU Standard_LRS (lab only)"
echo "  HTTPS only, minimum TLS 1.2"
echo "Container images, private"
echo "Stored access policy read-2h on that container, permission r, expiry $EXP"
echo "A service SAS would set si=read-2h. Delete the policy to revoke it. Do not regenerate key1 for that."
echo "User delegation SAS is Entra, Blob/Data Lake only, and ignores key1/key2."
echo "CMK vault must be in $LOC. A different subscription is allowed. That key is not key1."

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Read-only. APPLY=1 ./security.sh to create the policy, then delete the lab group."
  exit 0
fi

az group create --name "$RG" --location "$LOC" --output none
az storage account create --resource-group "$RG" --name "$NAME" --location "$LOC" \
  --kind StorageV2 --sku Standard_LRS \
  --https-only true --min-tls-version TLS1_2 --output none
az storage container create --account-name "$NAME" --name images --auth-mode login --public-access off
az storage container policy create --account-name "$NAME" --container-name images \
  --name read-2h --permissions r --expiry "$EXP" --auth-mode login

az storage container policy show --account-name "$NAME" --container-name images \
  --name read-2h --auth-mode login -o json

echo "== Cleanup =="
az group delete --name "$RG" --yes --no-wait
echo "Delete started for $RG"
