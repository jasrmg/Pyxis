#!/usr/bin/env bash
# AZ-104 exam path: Azure CLI + ARM JSON (Learn module 2) or Bicep.
# Default is what-if. Set APPLY=1 only in a sandbox / dedicated RG.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

TEMPLATE="${TEMPLATE:-arm}" # arm | bicep
RG_NAME="${RG_NAME:-rg-pyxis-dev-prereq}"
LOCATION="${LOCATION:-eastus}"

echo "== Identity =="
az account show --output table

echo
echo "== Cloud Shell operator notes =="
cat <<'EOF'
- Host is a temporary Linux container. Idle timeout is 20 minutes of no interactive activity.
- Persistent files need an Azure Files share. $HOME is a 5 GB image on that share.
- clouddrive is the share mounted at $HOME/clouddrive.
- Ephemeral sessions discard files when the session ends.
- Do not park production secrets in $HOME on a storage account the subscription can read.
- Long, quiet jobs do not belong here. Use a workstation or a pipeline.
EOF

case "$TEMPLATE" in
  arm)
    TEMPLATE_FILE="azuredeploy.json"
    PARAM_ARGS=(--parameters azuredeploy.parameters.json)
    ;;
  bicep)
    TEMPLATE_FILE="main.bicep"
    PARAM_ARGS=(--parameters azuredeploy.parameters.json)
    ;;
  *)
    echo "TEMPLATE must be arm or bicep"
    exit 1
    ;;
esac

echo
echo "== Resource group (idempotent) =="
az group create --name "$RG_NAME" --location "$LOCATION" --output table

echo
echo "== what-if ($TEMPLATE_FILE, incremental) =="
az deployment group what-if \
  --resource-group "$RG_NAME" \
  --template-file "$TEMPLATE_FILE" \
  "${PARAM_ARGS[@]}"

if [[ "${APPLY:-0}" == "1" ]]; then
  echo
  echo "== APPLY=1 — deploying (sandbox only, incremental mode) =="
  az deployment group create \
    --name prereq-storage \
    --resource-group "$RG_NAME" \
    --template-file "$TEMPLATE_FILE" \
    "${PARAM_ARGS[@]}" \
    --mode Incremental \
    --output table

  echo
  echo "== Outputs =="
  az deployment group show \
    --resource-group "$RG_NAME" \
    --name prereq-storage \
    --query properties.outputs \
    --output json

  echo
  echo "Export this RG as ARM JSON (exam skill): az group export --name $RG_NAME"
  echo "Convert ARM JSON to Bicep (exam skill): az bicep decompile --file azuredeploy.json"
else
  echo
  echo "what-if complete. Sandbox deploy: APPLY=1 ./deploy.sh"
  echo "Bicep instead of ARM JSON: TEMPLATE=bicep APPLY=1 ./deploy.sh"
  echo "Do not use --mode Complete on a shared resource group."
fi
