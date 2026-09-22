#!/usr/bin/env bash
# Module 3 — walk the scope hierarchy: management group -> subscription -> RG -> resource.
# Default run is READ-ONLY. APPLY=1 creates a demo RG (and deletes it again).
set -euo pipefail

PREFIX="${PREFIX:-az104}"
RG_NAME="${RG_NAME:-rg-${PREFIX}-hierarchy-demo}"
RG_LOCATION="${RG_LOCATION:-southeastasia}"
# Deliberately different from the RG location, to prove they are independent.
RESOURCE_LOCATION="${RESOURCE_LOCATION:-eastus}"

echo "== Scope 4: management groups (governance above subscriptions) =="
# Needs Microsoft.Management registered and read access at the MG scope.
az account management-group list \
  --query '[].{name:name, displayName:displayName, id:id}' --output table 2>/dev/null \
  || echo "(no management group access, or Microsoft.Management not registered)"

echo
echo "== Scope 3: subscriptions (billing + access boundary, one Entra tenant each) =="
az account list --all \
  --query '[].{name:name, subscriptionId:id, tenantId:tenantId, state:state}' --output table

echo
echo "== Scope 2: resource groups in the current subscription =="
# RG location is metadata for the group itself, not a constraint on its resources.
az group list --query '[].{name:name, rgLocation:location}' --output table

echo
echo "== Scope 1: resources, showing RG vs resource location can differ =="
az resource list \
  --query '[0:20].{name:name, type:type, resourceGroup:resourceGroup, location:location}' \
  --output table

echo
echo "== Regions available to this subscription (availability differs per region) =="
az account list-locations \
  --query '[?metadata.regionType==`Physical`].{region:name, geography:metadata.geographyGroup, pairedWith:metadata.pairedRegion[0].name}' \
  --output table

if [[ "${APPLY:-0}" != "1" ]]; then
  cat <<'EOF'

Read-only walk complete. To create a demo RG with tags and then delete it:
  APPLY=1 ./hierarchy.sh

Exam notes visible above:
- Scope order: resource < resource group < subscription < management group.
- RBAC and Azure Policy assignments inherit DOWNWARD through that order.
- Resource groups cannot be nested; each resource lives in exactly one RG.
- The pairedWith column is the region pair (same geography, sequential updates).
EOF
  exit 0
fi

echo
echo "== Create RG in $RG_LOCATION, with governance tags =="
az group create \
  --name "$RG_NAME" \
  --location "$RG_LOCATION" \
  --tags environment=demo costCenter=training owner=az104 \
  --output table

echo
echo "== Show the tags (tags are a governance skill: 'apply and manage tags') =="
az group show --name "$RG_NAME" --query '{name:name, location:location, tags:tags}' --output json

echo
echo "== Place a resource in a DIFFERENT region than the RG =="
# Proves the point: RG location != resource location.
az network public-ip create \
  --resource-group "$RG_NAME" \
  --name "pip-${PREFIX}-demo" \
  --location "$RESOURCE_LOCATION" \
  --sku Standard \
  --output none
az resource list --resource-group "$RG_NAME" \
  --query '[].{name:name, type:type, resourceLocation:location}' --output table
echo "RG is in $RG_LOCATION, the public IP is in $RESOURCE_LOCATION. Both legal."

echo
echo "== Merge one more tag (Merge keeps existing tags; Replace would drop them) =="
RG_ID="$(az group show --name "$RG_NAME" --query id --output tsv)"
az tag update --resource-id "$RG_ID" --operation Merge --tags reviewed=2026-09 --output none
az group show --name "$RG_NAME" --query tags --output json

echo
echo "== Cleanup: deleting the RG deletes everything inside it =="
az group delete --name "$RG_NAME" --yes --no-wait
echo "delete submitted for $RG_NAME (that is the blast-radius lesson, on purpose)."
