# Path 02 — Commands (Azure CLI ↔ Azure PowerShell)

Scope: **modules 1–3**. Grows as modules 4–6 (Policy, RBAC, SSPR) land.

Same rule as path 01: do not memorize every switch. Memorize the **noun and the verb**, and which tool can do a thing at all.

## Context / tenant

| Azure CLI | Azure PowerShell |
| --- | --- |
| `az account show` | `Get-AzContext` |
| `az account list --all --output table` | `Get-AzSubscription` |
| `az account set --subscription <id>` | `Set-AzContext -Subscription <id>` |
| `az account tenant list` | `Get-AzTenant` |
| `az ad signed-in-user show` | `Get-AzADUser -SignedIn` |

## Users

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create | `az ad user create --display-name "Abby Brown" --user-principal-name abby@contoso.com --password <pw>` | `New-AzADUser -DisplayName 'Abby Brown' -UserPrincipalName abby@contoso.com -MailNickname abby -Password $secure` |
| List | `az ad user list` | `Get-AzADUser` |
| Filter guests | `az ad user list --filter "userType eq 'Guest'"` | `Get-AzADUser -Filter "userType eq 'Guest'"` |
| Show | `az ad user show --id abby@contoso.com` | `Get-AzADUser -UserPrincipalName abby@contoso.com` |
| Update a property | `az ad user update --id abby@contoso.com --set usageLocation=PH` | `Update-AzADUser -UPNOrObjectId abby@contoso.com -UsageLocation PH` |
| Delete | `az ad user delete --id abby@contoso.com` | `Remove-AzADUser -UPNOrObjectId abby@contoso.com` |
| Groups the user is in | `az ad user get-member-groups --id abby@contoso.com` | `Get-AzADUser` + Graph |

`--password` is required by `az ad user create`. PowerShell needs a **SecureString**:

```powershell
$secure = ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force
```

Force a reset at first sign-in: CLI `--force-change-password-next-sign-in true`, PowerShell `-ForceChangePasswordNextLogin`.

## Groups and membership

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create (assigned) | `az ad group create --display-name Finance --mail-nickname finance` | `New-AzADGroup -DisplayName Finance -MailNickname finance -SecurityEnabled` |
| List | `az ad group list` | `Get-AzADGroup` |
| Show | `az ad group show --group Finance` | `Get-AzADGroup -DisplayName Finance` |
| Add member | `az ad group member add --group Finance --member-id <objectId>` | `Add-AzADGroupMember -TargetGroupObjectId <id> -MemberObjectId <id>` |
| List members | `az ad group member list --group Finance` | `Get-AzADGroupMember -GroupObjectId <id>` |
| Check membership | `az ad group member check --group Finance --member-id <id>` | `Get-AzADGroupMember` + filter |
| Remove member | `az ad group member remove --group Finance --member-id <id>` | `Remove-AzADGroupMember` |
| Delete | `az ad group delete --group Finance` | `Remove-AzADGroup -DisplayName Finance` |

**Dynamic groups (P1).** `az ad group create` has **no** flag for a membership rule. Two legal routes:

```powershell
New-AzADGroup -DisplayName 'Finance-Dynamic' -MailNickname financedyn -SecurityEnabled `
  -GroupType DynamicMembership `
  -MembershipRule '(user.department -eq "Finance")' `
  -MembershipRuleProcessingState On
```

```bash
az rest --method POST --url 'https://graph.microsoft.com/v1.0/groups' \
  --headers 'Content-Type=application/json' \
  --body '{"displayName":"Finance-Dynamic","mailNickname":"financedyn","mailEnabled":false,
           "securityEnabled":true,"groupTypes":["DynamicMembership"],
           "membershipRule":"(user.department -eq \"Finance\")",
           "membershipRuleProcessingState":"On"}'
```

If an exam answer shows `az ad group create --membership-rule ...`, that flag does not exist.

## Resource groups

| Azure CLI | Azure PowerShell |
| --- | --- |
| `az group create --name rg-app --location eastus` | `New-AzResourceGroup -Name rg-app -Location eastus` |
| `az group list --output table` | `Get-AzResourceGroup` |
| `az group delete --name rg-app --yes` | `Remove-AzResourceGroup -Name rg-app -Force` |
| `az resource list --resource-group rg-app` | `Get-AzResource -ResourceGroupName rg-app` |
| `az resource move --destination-group rg-new --ids <id>` | `Move-AzResource -DestinationResourceGroupName rg-new -ResourceId <id>` |

## Tags

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Tag an RG at create | `az group create -n rg-app -l eastus --tags env=prod owner=platform` | `New-AzResourceGroup -Name rg-app -Location eastus -Tag @{env='prod'}` |
| Merge tags | `az tag update --resource-id <id> --operation Merge --tags reviewed=2026-09` | `Update-AzTag -ResourceId <id> -Tag @{reviewed='2026-09'} -Operation Merge` |
| Replace all tags | `az tag update --resource-id <id> --operation Replace --tags env=dev` | `Update-AzTag -ResourceId <id> -Tag @{env='dev'} -Operation Replace` |
| Delete specific tags | `az tag update --resource-id <id> --operation Delete --tags env=dev` | `Update-AzTag -ResourceId <id> -Tag @{env='dev'} -Operation Delete` |

`Merge` keeps existing tags; **`Replace` drops the ones you did not list**. That difference is exam-grade.

Tags are **not inherited** by default — a resource does not automatically get its RG's tags. Making that happen is an **Azure Policy** job (module 4).

## Management groups

| Job | Azure CLI | Azure PowerShell |
| --- | --- | --- |
| Create | `az account management-group create --name mg-corp --display-name "Corp"` | `New-AzManagementGroup -GroupName mg-corp -DisplayName Corp` |
| Create with parent | `az account management-group create --name mg-prod --parent mg-corp` | `New-AzManagementGroup -GroupName mg-prod -ParentId <id>` |
| List | `az account management-group list --output table` | `Get-AzManagementGroup` |
| Show tree | `az account management-group show --name mg-corp -e -r` | `Get-AzManagementGroup -GroupName mg-corp -Expand -Recurse` |
| Move a subscription in | `az account management-group subscription add --name mg-prod --subscription <subId>` | `New-AzManagementGroupSubscription -GroupName mg-prod -SubscriptionId <subId>` |
| Remove a subscription | `az account management-group subscription remove --name mg-prod --subscription <subId>` | `Remove-AzManagementGroupSubscription -GroupName mg-prod -SubscriptionId <subId>` |
| Delete | `az account management-group delete --name mg-prod` | `Remove-AzManagementGroup -GroupName mg-prod` |

`--name` on a management group is the **ID/name**, not the display name. `az account management-group show` says so explicitly. Passing the display name is a common failure.

## Regions / limits

| Job | Command |
| --- | --- |
| Regions + region pairs | `az account list-locations --query "[?metadata.regionType=='Physical'].{region:name,paired:metadata.pairedRegion[0].name}" -o table` |
| Check quota/usage | `az vm list-usage --location eastus --output table` |

## Trap commands for this path

| Looks tempting | Why it is wrong |
| --- | --- |
| `az ad group create --membership-rule ...` | No such flag. Use PowerShell `New-AzADGroup` or Graph |
| `az ad user update` to fix a **synced** user | Synced attributes are read-only in the cloud; fix on-prem AD DS |
| `az tag update --operation Replace` to add one tag | Replace **removes** tags you did not list; you wanted `Merge` |
| `az account management-group create --name "Corp Prod"` | `--name` is the ID; display name goes in `--display-name` |
| `az group create` nested inside another RG | Resource groups cannot be nested |
