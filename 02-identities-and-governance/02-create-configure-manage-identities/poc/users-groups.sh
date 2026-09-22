#!/usr/bin/env bash
# Module 2 — users, groups, membership, licenses (Azure CLI).
#
# WARNING: Entra ID objects are tenant-wide. There is no MS Learn sandbox for them.
# Default run is READ-ONLY. Writes require APPLY=1 and are cleaned up at the end.
# Needs: User Administrator (or Groups Administrator) in the tenant.
set -euo pipefail

PREFIX="${PREFIX:-az104}"

echo "== Context =="
az account show --query '{subscription:name, tenantId:tenantId, signedInAs:user.name}' --output json

echo
echo "== Verified domains (a UPN must use one of these) =="
DEFAULT_DOMAIN="$(az rest --method GET --url 'https://graph.microsoft.com/v1.0/domains' \
  --query "value[?isDefault].id | [0]" --output tsv 2>/dev/null || true)"
if [[ -n "$DEFAULT_DOMAIN" ]]; then
  echo "default verified domain: $DEFAULT_DOMAIN"
else
  echo "(could not read domains — needs Directory.Read.All; portal: Entra ID > Custom domain names)"
fi

echo
echo "== Users (userType shows Member vs Guest) =="
az ad user list --query '[0:15].{displayName:displayName, upn:userPrincipalName, type:userType}' --output table

echo
echo "== Guests only (external / B2B) =="
az ad user list --filter "userType eq 'Guest'" \
  --query '[].{displayName:displayName, upn:userPrincipalName}' --output table

echo
echo "== Groups (membershipRule non-empty => dynamic, which needs P1) =="
az ad group list --query '[0:15].{displayName:displayName, id:id, dynamicRule:membershipRule}' --output table

if [[ "${APPLY:-0}" != "1" ]]; then
  cat <<'EOF'

Read-only run complete. To create a demo user + group and then delete them:
  APPLY=1 ./users-groups.sh

Exam notes you can verify above:
- userType is Member or Guest, and it is a property you can change (guest -> member).
- Dynamic membership is a group property (membershipRule) and requires P1.
- az ad group create cannot set a dynamic rule; that needs Graph (az rest) or PowerShell.
EOF
  exit 0
fi

if [[ -z "$DEFAULT_DOMAIN" ]]; then
  echo "Cannot create a user without a verified domain. Stopping."
  exit 1
fi

USER_UPN="${PREFIX}-demo-user@${DEFAULT_DOMAIN}"
GROUP_NAME="${PREFIX}-demo-group"
TEMP_PASSWORD="$(openssl rand -base64 18)Aa1!"

echo
echo "== Create user: $USER_UPN =="
# --force-change-password-next-sign-in models real onboarding.
USER_ID="$(az ad user create \
  --display-name "AZ104 Demo User" \
  --user-principal-name "$USER_UPN" \
  --password "$TEMP_PASSWORD" \
  --mail-nickname "${PREFIX}demouser" \
  --force-change-password-next-sign-in true \
  --query id --output tsv)"
echo "created user id: $USER_ID"

echo
echo "== Set usageLocation (required before some licenses can be assigned) =="
az ad user update --id "$USER_ID" --set usageLocation=PH

echo
echo "== Create assigned security group: $GROUP_NAME =="
GROUP_ID="$(az ad group create \
  --display-name "$GROUP_NAME" \
  --mail-nickname "${PREFIX}demogroup" \
  --description "AZ-104 module 2 demo. Safe to delete." \
  --query id --output tsv)"
echo "created group id: $GROUP_ID"

echo
echo "== Add the user to the group, then prove membership =="
az ad group member add --group "$GROUP_ID" --member-id "$USER_ID"
az ad group member check --group "$GROUP_ID" --member-id "$USER_ID" --output json
az ad group member list --group "$GROUP_ID" \
  --query '[].{displayName:displayName, upn:userPrincipalName}' --output table

echo
echo "== Transitive groups for the user (this is what nesting looks like to RBAC) =="
az ad user get-member-groups --id "$USER_ID" --query '[].displayName' --output table

echo
echo "== Available license SKUs in the tenant (consumed vs enabled) =="
az rest --method GET --url 'https://graph.microsoft.com/v1.0/subscribedSkus' \
  --query 'value[].{sku:skuPartNumber, enabled:prepaidUnits.enabled, consumed:consumedUnits}' \
  --output table 2>/dev/null || echo "(needs Directory.Read.All)"

cat <<'EOF'

== Dynamic group (reference only — needs P1, not executed) ==
Azure CLI has no flag for this. Graph does:

az rest --method POST \
  --url 'https://graph.microsoft.com/v1.0/groups' \
  --headers 'Content-Type=application/json' \
  --body '{
    "displayName": "az104-finance-dynamic",
    "mailNickname": "az104financedynamic",
    "mailEnabled": false,
    "securityEnabled": true,
    "groupTypes": ["DynamicMembership"],
    "membershipRule": "(user.department -eq \"Finance\")",
    "membershipRuleProcessingState": "On"
  }'

Remember: converting an Assigned group to Dynamic discards existing manual members.
EOF

echo
echo "== Cleanup (leaving the tenant as we found it) =="
az ad group delete --group "$GROUP_ID"
az ad user delete --id "$USER_ID"
echo "deleted demo group and user."
echo "Note: the user is soft-deleted for 30 days and can be restored."
echo "      A deleted security group cannot be restored the same way."
