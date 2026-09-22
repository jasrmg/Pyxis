#!/usr/bin/env bash
# Module 1 — read-only tenant / subscription reconnaissance.
# Creates nothing, changes nothing. Safe in any subscription, including production.
# Goal: see with your own eyes that a subscription trusts exactly one tenant.
set -euo pipefail

echo "== Signed-in context (which tenant is this subscription trusting?) =="
az account show --query '{subscription:name, subscriptionId:id, tenantId:tenantId, user:user.name}' --output json

echo
echo "== Every subscription this identity can see, grouped by tenant =="
# One tenant can hold many subscriptions. A subscription maps to exactly one tenantId.
az account list --all --query '[].{name:name, subscriptionId:id, tenantId:tenantId, state:state}' --output table

echo
echo "== Tenants this identity can authenticate against =="
az account tenant list --query '[].{tenantId:tenantId}' --output table 2>/dev/null \
  || echo "(az account tenant list unavailable in this CLI version — read tenantId from the table above)"

echo
echo "== Who am I in the directory? (Microsoft Graph via Azure CLI) =="
# Entra ID is queried over Graph/HTTPS, not LDAP. This is that point, demonstrated.
az ad signed-in-user show --query '{displayName:displayName, upn:userPrincipalName, id:id, type:userType}' --output json

echo
echo "== Verified domains in the tenant (a UPN must use one of these) =="
az rest --method GET \
  --url 'https://graph.microsoft.com/v1.0/domains' \
  --query 'value[].{domain:id, isVerified:isVerified, isDefault:isDefault}' \
  --output table 2>/dev/null \
  || echo "(needs Directory.Read.All consent — skip, portal: Entra ID > Custom domain names)"

cat <<'EOF'

== Module 1 talking points ==
- Entra ID is flat: no OUs, no GPOs, no LDAP, no Kerberos.
- Query path is Microsoft Graph over HTTPS (that is what az ad / az rest just used).
- Auth protocols: SAML, WS-Federation, OpenID Connect. Authorization: OAuth 2.0.
- P1: Conditional Access, dynamic groups, group-based licensing, SSPR writeback.
- P2: Entra ID Protection (risk-based CA) and Privileged Identity Management.
- Domain join / Kerberos / LDAP / GPO with no DCs to manage = Entra Domain Services
  (separate namespace, no two-way trust, no schema extension).
EOF
