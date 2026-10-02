#!/usr/bin/env bash
# Module 6 — SSPR is an Entra portal feature. This script is READ-ONLY reconnaissance.
set -euo pipefail

echo "== Signed-in user / tenant (SSPR is tenant-wide, not a subscription resource) =="
az account show --query '{user:user.name, tenantId:tenantId, subscription:name}' -o json

echo
echo "== Cloud-only vs synced hint (onPremisesSyncEnabled) =="
az ad user list --query '[0:8].{upn:userPrincipalName, synced:onPremisesSyncEnabled}' -o table 2>/dev/null \
  || echo "(need User.Read.All or similar to list users)"

cat <<'EOF'

There is no az sspr enable. Configure in Entra admin center:

  Entra ID → Password reset
    Properties              None / Selected (pilot group) / All
    Authentication methods  1 or 2 methods to reset; which methods
    Registration            register on sign-in; reconfirm days
    Notifications           user reset / admin resets another admin
    On-premises integration writeback; unlock without reset

Exam splits:
- Cloud change they still know     → Free
- Synced reset that must hit AD DS → P1 + Entra Connect password writeback
- Admins                           → two methods, no security questions
- Test SSPR with a non-admin user
EOF
