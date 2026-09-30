#!/usr/bin/env bash
# Module 5 — inspect Azure RBAC assignments. Default is READ-ONLY.
set -euo pipefail

echo "== Who am I, which subscription, which tenant =="
az account show --query '{user:user.name, subscription:name, subscriptionId:id, tenantId:tenantId}' -o json

echo
echo "== Role assignments at this subscription (direct) =="
az role assignment list --include-inherited false \
  --query '[].{principal:principalName, role:roleDefinitionName, scope:scope}' -o table

echo
echo "== Same list INCLUDING inherited (MG / parent) =="
az role assignment list --include-inherited \
  --query '[].{principal:principalName, role:roleDefinitionName, scope:scope}' -o table

echo
echo "== Built-in roles you will mix up on the exam =="
az role definition list --name Owner --query '[].{name:roleName, assignRoles:permissions[0].actions}' -o json --only-show-errors | head -c 400
echo
az role definition list --name Contributor --query '[].roleName' -o tsv
az role definition list --name Reader --query '[].roleName' -o tsv
az role definition list --name "User Access Administrator" --query '[].roleName' -o tsv

echo
echo "Exam notes:"
echo "- Assignment = principal + role + scope. Inherit down. Cannot delete at child."
echo "- Contributor cannot assign roles. Owner can. UAA assigns roles only."
echo "- Global Admin is not Owner."
echo "- --include-inherited is how a parent MG assignment becomes visible here."
if [[ "${APPLY:-0}" != "1" ]]; then
  echo "- APPLY=1 is intentionally unused here: creating assignments writes to the real subscription."
fi
